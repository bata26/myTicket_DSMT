%%%-------------------------------------------------------------------
%% @doc myTicketERL public API
%% @end
%%%-------------------------------------------------------------------

-module(myTicketERL_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
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
            {"/websocket", myTicketERL_handler, [{stats_interval, list_to_integer(SInterval)}]}
%            {"/[...]", cowboy_static, {priv_dir, ws, "", [{mimetypes, cow_mimetypes, all}]}}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(
        http,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
    ),
    myTicketERL_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
