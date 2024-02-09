-module(mnesia_manager).

-export([create_auction/2, get_auction_history/1]).

-record(auction, {auction_id, owner_id, timer}).
-record(bid, {auction_id, user_id, username, amount, ts}).

create_auction(UserID, AuctionID) ->
    mnesia:transaction(fun() ->
        mnesia:write({auction, AuctionID, UserID, -1})
    end).

get_auction_history(AuctionID) ->
    Fun = fun()->
        mnesia:match_object({bid, AuctionID, '_', '_', '_', '_'})
    end,
    {atomic, Result} = mnesia:transaction(Fun),
    io:format("[MASTER MNESIA MANAGER] get_auction_history => BIDS: ~p~n", [Result]),
    Result.