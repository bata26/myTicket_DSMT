-module(master_node_handler).
-behaviour(cowboy_handler).


%-export([init/2]).
-export([handler/2]).


%init(Req, State) ->
%    io:format("connection initiated~n~p~n~nstate: ~p~n", [Req, State]),
%    {cowboy_handler, Req, State}.

handler(Req, State) ->
    Body = cowboy_req:body(Req),
    ParsedBody = jiffy:decode(Body),
    ResponseBody = io_lib:format("Received JSON: ~p", [ParsedBody]),
    {ok, Req2} = cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>}, ResponseBody, Req),
    {ok, Req2, State}.