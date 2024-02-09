-module(history_handler).
-behaviour(cowboy_rest).

%% Callback Callbacks
-export([allowed_methods/2]).
-export([content_types_accepted/2]).
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
    {[<<"GET">> , <<"POST">>], Req, State}.

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
    iter_bid_list(Bids, []).

iter_bid_list([], Acc) ->
    lists:reverse(Acc);
iter_bid_list([Bid | Rest], Acc) ->
    #bid{auction_id = AuctionID, user_id = UserID, username = Username, amount = Amount, ts = Ts} =
        Bid,
    AuctionTuple = {<<"auction_id">>, AuctionID},
    UserTuple = {<<"user_id">>, UserID},
    UsernameTuple = {<<"username">>, Username},
    AmountTuple = {<<"amount">>, Amount},
    TsTuple = {<<"ts">>, Ts},
    iter_bid_list(Rest, [AuctionTuple, UserTuple, UsernameTuple, AmountTuple, TsTuple | Acc]).

handle(_, true, Req) ->
    io:format("[HISTORY HANDLER] Handling request in handle/3~n", []),
    {ok, Body, Req2} = cowboy_req:read_body(Req, #{length => infinity}),

    {ParsedBody} = jiffy:decode(Body),
    AuctionID = proplists:get_value(<<"auctionID">>, ParsedBody),
    History = mnesia_manager:get_auction_history(AuctionID),
    ResultList = {iter_bid_list(History)},
    JsonString = jiffy:encode(ResultList),
    BinString = iolist_to_binary([JsonString]),
    Resp = cowboy_req:reply(
        200,
        #{<<"content-type">> => <<"text/plain">>},
        BinString,
        Req2
        ),
    io:format("HISTORY HANDLER] Response sent from handle/3~n");
handle(_, _, Req) ->
    cowboy_req:reply(
        200,
        #{},
        <<>>,
        Req
    ).
