-module(master_node_handler).
-behaviour(cowboy_rest).

%% Callback Callbacks
-export([allowed_methods/2]).
-export([content_types_accepted/2]).
-export([resource_exists/2]).
-export([commands/2]).

-export([handle/3, init/2]).

%% Helpes
-import(helper, [get_body/2, get_model/3, reply/3]).

init(Req, State) ->
    Method = cowboy_req:method(Req),
    HasBody = cowboy_req:has_body(Req),
    Reply = handle(Method, HasBody, Req),
    {ok, Reply, State},
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"POST">>], Req, State}.

commands(Req, State) ->
    {reply, State, Req}.


content_types_accepted(Req, State) ->
    {
        [
            {<<"application">> , <<"json">>, handle},
            {<<"application/json">>, handle}
        ],
        Req,
        State
    }.

resource_exists(Req, State) ->
    {false, Req, State}.

handle(<<"POST">>, true, Req) ->
    io:format("[MASTER NODE HANDLER] Handling request in handle/3~n", []),
    {ok, Body, Req2} = cowboy_req:read_body(Req, #{length => infinity}),
    {ParsedBody} = jiffy:decode(Body),
    AuctionID = proplists:get_value(<<"auctionID">>, ParsedBody),
    UserID = proplists:get_value(<<"userID">>, ParsedBody),
    mnesia_manager:create_auction(UserID, AuctionID),
    RespHeaders = #{<<"content-type">> => <<"text/plain; charset=utf-8">>},
    Resp = cowboy_req:reply(200, 
    RespHeaders,
    "OK", Req2),
    io:format("[MASTER NODE HANDLER] Response sent from handle/3~n");
handle(_, _, Req) ->
    cowboy_req:reply(
        200,
        #{},
        <<>>,
        Req
    ).
