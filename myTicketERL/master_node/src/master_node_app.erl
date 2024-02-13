-module(master_node_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    case os:getenv("PORT") of
        false ->
            {_Status, Port} = application:get_env(ws, port);
        Other ->
            Port = Other
    end,
    {ok, Nodes} = application:get_env(ws, nodes),
    io:format("Hello from ~p~n", [self()]),
    io:format("[MASTER NODE] Cowboy started on port ~p~n", [Port]),
    io:format("[MASTER NODE] start => Nodes ~p~n", [Nodes]),
    connect_nodes(Nodes),

    % Configure mnesia
    io:format("[MASTER NODE] start => config mnesia~n"),
    start_mnesia(Nodes),

    % Start nodes
    io:format("[MASTER NODE] start =>  start_nodes~n"),
    start_nodes(Nodes),

    % Print info about mnesia DB
    timer:sleep(5000),
    mnesia:info(),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/auction", master_node_handler, []},
            {"/auction/history" , history_handler , []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(
        http_listener,
        [{port, Port}],
        #{env => #{dispatch => Dispatch}}
    ),
    io:format("[MASTER NODE] Cowboy started on port ~p~n", [Port]),

    % Return current Pid and state
    {ok, self(), Nodes}.

stop(Nodes) ->
    io:format("[MASTER NODE] stop => master_node:stop(~p)~n", [Nodes]),
    % Stop mnesia (in another thread)
    spawn(mnesia, stop, []),
    % Stop remote nodes
    stop_nodes(Nodes),
    ok.

%% Connect to remote nodes
connect_nodes([]) ->
    ok;
connect_nodes([H | T]) when is_atom(H), is_list(T) ->
    io:format("[MASTER NODE] connect_nodes => Connect node ~p~n", [H]),
    true = net_kernel:connect_node(H),
    connect_nodes(T).
%% Start remote nodes
start_nodes([]) ->
    ok;
start_nodes([Node | T]) ->
    io:format("[MASTER NODE] start_nodes => ~p~n", [Node]),
    % application:start(chat_server)
    spawn(Node, application, start, [worker_node]),
    start_nodes(T).

%% Stop remote nodes
stop_nodes([]) ->
    ok;
stop_nodes([Node | T]) ->
    io:format("[MASTER NODE] stop_nodes => ~p~n", [Node]),
    spawn(Node, application, stop, [worker_node]),
    stop_nodes(T).

%%% MNESIA

-record(auction, {auction_id, owner_id, timer}).
-record(bid, {auction_id, user_id, username, amount, ts}).
-record(users, {auction_id, user_pid, user_id}).

start_mnesia(Nodes) when is_list(Nodes) ->
    % Create mnesia schema if doesn't exists
    Result1 = mnesia:create_schema([node() | Nodes]),
    io:format("[MASTER NODE] start_mnesia => create_schema(~p) => ~p~n", [Nodes, Result1]),

    % Start mnesia application
    mnesia:start(),
    io:format("[MASTER NODE] start_mnesia => start()~n"),

    % Create table
    Result2 = mnesia:create_table(
        users,
        [
            {attributes, record_info(fields, users)},
            {type, bag},
            {ram_copies, Nodes},
            {disc_copies, node()}
        ]
    ),
    Result3 = mnesia:create_table(
        auction,
        [
            {attributes, record_info(fields, auction)},
            {type, bag},
            {ram_copies, Nodes},
            {disc_copies, node()}
        ]
    ),
    Result4 = mnesia:create_table(
        bid,
        [
            {attributes, record_info(fields, bid)},
            {type, bag},
            {ram_copies, Nodes},
            {disc_copies, node()}
        ]
    ),
    io:format("[MASTER NODE] start_mnesia => create_table result: ~p~n", [Result2]),
    ok.
