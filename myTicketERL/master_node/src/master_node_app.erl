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
    io:format("Cowboy started on port ~p~n", [Port]),
    %{ok, _} = application:ensure_all_started(cowboy),
    % {_Status2, SInterval} = application:get_env(ws, stats_interval),

    Dispatch = cowboy_router:compile([
        {'_', [
            % {"/", cowboy_static, {priv_file, ws, "index.html"}},
            {"/auction", master_node_handler, []}
            %{"/auctionpost", master_node_handler, []}
            % {"/[...]", cowboy_static, {priv_dir, ws, "", [{mimetypes, cow_mimetypes, all}]}}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http_listener,
        [{port, Port}],
        #{env => #{dispatch => Dispatch}}
    ),
    io:format("Cowboy started on port ~p~n", [Port]),
    master_node_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
