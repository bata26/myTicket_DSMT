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
    io:format("Handling request in handle/2~n", []),
    {ok, Body, Req2} = cowboy_req:read_body(Req, #{length => infinity}),
    io:format("Body length: ~p~n", [byte_size(Body)]),
    io:format("Received body: ~p~n", [Body]),
    
    {ParsedBody} = jiffy:decode(Body),
    io:format("Parsed JSON: ~p~n", [ParsedBody]),
    AuctionID = proplists:get_value(<<"auctionID">>, ParsedBody),
    UserID = proplists:get_value(<<"userID">>, ParsedBody),
    io:format("auctionID : ~p, userID: ~p~n", [AuctionID, UserID]),
    io:format("Inserisco nella tabella~n"),
    mnesia_manager:create_auction(UserID, AuctionID),
    RespHeaders = #{<<"content-type">> => <<"text/plain; charset=utf-8">>},
    master_node_app:print_all_records(),
    Resp = cowboy_req:reply(200, 
    %#{<<"content-type">> => <<"text/plain">>}, 
    RespHeaders,
    "OK", Req2),
    io:format("Response sent from handle/2~n");
handle(_, _, Req) ->
    cowboy_req:reply(
        200,
        #{},
        <<>>,
        Req
    ).

%%handle(Req, State) ->
%%    io:format("Handling request in handle/2~n", []),
%%    {ok, Body, Req2} = cowboy_req:read_body(Req, #{length => infinity}),
%%    io:format("Body length: ~p~n", [byte_size(Body)]),
%%    io:format("Received body: ~p~n", [Body]),
%%    try
%%        {ParsedBody} = jiffy:decode(Body),
%%        io:format("Parsed JSON: ~p~n", [ParsedBody]),
%%        AuctionID = proplists:get_value(<<"auctionID">>, ParsedBody),
%%        UserID = proplists:get_value(<<"userID">>, ParsedBody),
%%        io:format("auctionID : ~p, userID: ~p~n", [AuctionID, UserID]),
%%        Req3 = cowboy_req:reply(
%%            200, Req2
%%        ),
%%        io:format("Response sent from handle/2~n"),
%%        {ok, Req3, State}
%%    catch
%%        % Cattura solo le eccezioni Jiffy
%%        exit:{json, _} ->
%%            {error, Req2, State};
%%        Error:Reason ->
%%            io:format("Error in handle/2: ~p, Reason: ~p~n", [Error, Reason]),
%%            {error, Req2, State}
%%    end.
