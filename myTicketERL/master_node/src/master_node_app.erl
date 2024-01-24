%%%-------------------------------------------------------------------
%% @doc master_node public API
%% @end
%%%-------------------------------------------------------------------

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
    io:format("Cowboy started on port ~p~n", [Port]),
    io:format("[master_node_app] start => Nodes ~p~n", [Nodes]),
	connect_nodes(Nodes),
    % Start nodes
	io:format("[master_node_app] start =>  start_nodes~n"),
	start_nodes(Nodes),

    Dispatch = cowboy_router:compile([
        {'_', [
            % {"/", cowboy_static, {priv_file, ws, "index.html"}},
            {"/auction", master_node_handler, []}
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
    master_node_sup:start_link().

stop(_State) ->
    ok.

%% Connect to remote nodes
connect_nodes([]) ->
	ok;

connect_nodes([H | T]) when is_atom(H), is_list(T) ->
	io:format("[master_node_app] connect_nodes => Connect node ~p~n", [H]),
	true = net_kernel:connect_node(H),
	connect_nodes(T).
%% internal functions
%% Start remote nodes
start_nodes([]) ->
	ok;

start_nodes([Node | T]) ->
	io:format("[master_node_app] start_nodes => ~p~n", [Node]),
	Pid = spawn(Node, application, start, [chat_server]), % application:start(chat_server)
    io:format("Hello from ~p~n", [Pid]),
	start_nodes(T).