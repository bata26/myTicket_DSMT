-module(master_node_app).
-behaviour(application).

-export([start/2, stop/1, print_all_records/0]).

%% Funzione per ottenere tutti i record dalla tabella
get_all_records() ->
    mnesia:transaction(fun() ->
        %% Utilizza mnesia:select/2 per ottenere tutti i record
		Records = mnesia:select(auction, [{'_', [], ['$_']}]),
        Records
    end).
print_all_records() ->
    case get_all_records() of
        [] ->
            io:format("La tabella è vuota.~n");
        Records ->
            io:format("Contenuto della tabella: ~p~n", [Records])
    end.

start(_StartType, _StartArgs) ->
    case os:getenv("PORT") of
        false ->
            {_Status, Port} = application:get_env(ws, port);
        Other ->
            Port = Other
    end,
    {ok, Nodes} = application:get_env(ws, nodes),
    io:format("Hello from ~p~n", [self()]),
    io:format("Cowboy started on port ~p~n", [Port]),
    io:format("[master_node_app] start => Nodes ~p~n", [Nodes]),
    connect_nodes(Nodes),

    % Configure mnesia
    io:format("[master_node_app] start => config mnesia~n"),
    start_mnesia(Nodes),

    % Start nodes
    io:format("[master_node_app] start =>  start_nodes~n"),
    start_nodes(Nodes),

    % Print info about mnesia DB
    timer:sleep(5000),
    mnesia:info(),
    Dispatch = cowboy_router:compile([
        {'_', [
            % {"/", cowboy_static, {priv_file, ws, "index.html"}},
            {"/auction", master_node_handler, []},
            {"/auction/history" , history_handler , []}
            %{"/auctionpost", master_node_handler, []}
            % {"/[...]", cowboy_static, {priv_dir, ws, "", [{mimetypes, cow_mimetypes, all}]}}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(
        http_listener,
        [{port, Port}],
        #{env => #{dispatch => Dispatch}}
    ),
    io:format("Cowboy started on port ~p~n", [Port]),

    % Return current Pid and state
    {ok, self(), Nodes}.

stop(Nodes) ->
    io:format("[master_node_app] stop => master_node:stop(~p)~n", [Nodes]),
    % Stop mnesia (in another thread)
    spawn(mnesia, stop, []),
    % Stop remote nodes
    stop_nodes(Nodes),
    ok.

%% Connect to remote nodes
connect_nodes([]) ->
    ok;
connect_nodes([H | T]) when is_atom(H), is_list(T) ->
    io:format("[master_node_app] connect_nodes => Connect node ~p~n", [H]),
    true = net_kernel:connect_node(H),
    connect_nodes(T).
%% Start remote nodes
start_nodes([]) ->
    ok;
start_nodes([Node | T]) ->
    io:format("[master_node_app] start_nodes => ~p~n", [Node]),
    % application:start(chat_server)
    spawn(Node, application, start, [worker_node]),
    start_nodes(T).

%% Stop remote nodes
stop_nodes([]) ->
    ok;
stop_nodes([Node | T]) ->
    io:format("[master_node_app] stop_nodes => ~p~n", [Node]),
    spawn(Node, application, stop, [worker_node]),
    stop_nodes(T).

%%% MNESIA

-record(auction, {auction_id, owner_id, timer}).
-record(bid, {auction_id, user_id, username, amount, ts}).
-record(users, {auction_id, user_pid, user_id}).

start_mnesia(Nodes) when is_list(Nodes) ->
    % Create mnesia schema if doesn't exists
    Result1 = mnesia:create_schema([node() | Nodes]),
    io:format("[master_node_app] start_mnesia => create_schema(~p) => ~p~n", [Nodes, Result1]),

    % Start mnesia application
    mnesia:start(),
    io:format("[master_node_app] start_mnesia => start()~n"),

    % Create table
    Result2 = mnesia:create_table(
        users,
        [
            {attributes, record_info(fields, users)},
            {type, bag},
            {ram_copies, Nodes}
        ]
    ),
    Result3 = mnesia:create_table(
        auction,
        [
            {attributes, record_info(fields, auction)},
            {type, bag},
            {ram_copies, Nodes}
        ]
    ),
    Result4 = mnesia:create_table(
        bid,
        [
            {attributes, record_info(fields, bid)},
            {type, bag},
            {ram_copies, Nodes}
        ]
    ),
    io:format("[master_node_app] start_mnesia => create_table result: ~p~n", [Result2]),
    ok.
