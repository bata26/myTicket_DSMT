%%%-------------------------------------------------------------------
%% @doc myTicketERL public API
%% @end
%%%-------------------------------------------------------------------

-module(worker_node_app).

-behaviour(application).

-export([start/2, stop/1, start_worker_node/0]).

start_worker_node() ->
    %% Avvia il worker node
    application:ensure_all_started(worker_node_app),
    ok.

start(_StartType, _StartArgs) ->
    io:format("WORKER node started on port 8082~n"),
    case os:getenv("PORT") of
        false ->
            {_Status, Port} = application:get_env(ws, port);
        Other ->
            Port = Other
    end,        
    {_Status2, SInterval} = application:get_env(ws, stats_interval),


    Dispatch = cowboy_router:compile([
        {'_', [
            % {"/", cowboy_static, {priv_file, ws, "index.html"}},
            {"/websocket", worker_node_handler, [{stats_interval, list_to_integer(SInterval)}]}
%            {"/[...]", cowboy_static, {priv_dir, ws, "", [{mimetypes, cow_mimetypes, all}]}}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(
        http,
        [{port, 8081}],
        #{env => #{dispatch => Dispatch}}
    ),
    worker_node_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
