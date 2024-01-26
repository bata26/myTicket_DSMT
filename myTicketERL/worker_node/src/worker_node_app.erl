%%%-------------------------------------------------------------------
%% @doc myTicketERL public API
%% @end
%%%-------------------------------------------------------------------

-module(worker_node_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    mnesia:start(),
    ok = mnesia:wait_for_tables([auction], 300000),
    io:format("[chat_server_app] start => mnesia is ready~n"),
    % Start supervisor
    worker_node_sup:start_link().

stop(_State) ->
    mnesia:stop(),
    ok.
