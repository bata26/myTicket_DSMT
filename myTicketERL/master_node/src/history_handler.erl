-module(history_handler).
-behaviour(cowboy_rest).

%% Callback Callbacks
-export([allowed_methods/2]).
-export([content_types_accepted/2]).
%-export([content_types_provided/2]).
-export([resource_exists/2]).
-export([commands/2]).

-export([handle/3, init/2]).

%% Helpes
-import(helper, [get_body/2, get_model/3, reply/3]).

-record(bid, {auction_id, user_id, username, amount, ts}).

init(Req, State) ->
    Method = cowboy_req:method(Req),
    HasBody = cowboy_req:has_body(Req),
    Reply = handle(Method, HasBody, Req),
    {ok, Reply, State},
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"GET">>], Req, State}.

commands(Req, State) ->
    {reply, State, Req}.

content_types_accepted(Req, State) ->
    {
        [
            {<<"application">>, <<"json">>, handle},
            {<<"application/json">>, handle}
        ],
        Req,
        State
    }.

resource_exists(Req, State) ->
    {false, Req, State}.

iter_bid_list(Bids) ->
    io:format("1~n"),
    iter_bid_list(Bids, []).

iter_bid_list([], Acc) ->
    io:format("2~n"),
    lists:reverse(Acc);
iter_bid_list([Bid | Rest], Acc) ->
    io:format("3~n"),
    #bid{auction_id = AuctionID, user_id = UserID, username = Username, amount = Amount, ts = Ts} =
        Bid,
    AuctionTuple = {<<"auction_id">>, AuctionID},
    UserTuple = {<<"user_id">>, UserID},
    UsernameTuple = {<<"username">>, Username},
    AmountTuple = {<<"amount">>, Amount},
    TsTuple = {<<"ts">>, Ts},
    iter_bid_list(Rest, [AuctionTuple, UserTuple, UsernameTuple, AmountTuple, TsTuple | Acc]).

handle(<<"GET">>, true, Req) ->
    io:format("Handling request in handle/2~n", []),
    {ok, Body, Req2} = cowboy_req:read_body(Req, #{length => infinity}),

    {ParsedBody} = jiffy:decode(Body),
    io:format("Parsed JSON: ~p~n", [ParsedBody]),
    AuctionID = proplists:get_value(<<"auctionID">>, ParsedBody),
    io:format("auctionID : ~p~n", [AuctionID]),
    io:format("Inserisco nella tabella~n"),
    History = mnesia_manager:get_auction_history(AuctionID),
    io:format("HISTORY : ~p~n", [History]),
    ResultList = {iter_bid_list(History)},
    io:format("RESULTLIST : ~p~n", [ResultList]),
    JsonString = jiffy:encode(ResultList),
    io:format("ENCODED HISTORY : ~p~n", [JsonString]),
    BinString = iolist_to_binary([JsonString]),
    Resp = cowboy_req:reply(
        200,
        #{<<"content-type">> => <<"text/plain">>},
        BinString,
        Req
    ),
    io:format("Response sent from handle/2~n");
handle(_, _, Req) ->
    cowboy_req:reply(
        200,
        #{},
        <<>>,
        Req
    ).
