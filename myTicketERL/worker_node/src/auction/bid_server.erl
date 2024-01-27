-module(bid_server).

-export([get_all_bids/2, add_bid/6]).

-record(auction, {auction_id, owner_id}).
-record(bid, {auction_id, user_id, username, amount, ts}).

get_all_bids(Pid, AuctionID) ->
    Bids = mnesia_manager:get_bids_from_auction_id(AuctionID),
    io:format("BIDS : ~p~n" , [Bids]).

add_bid(Pid,UserID,AuctionID,BidAmount,Username,Timestamp) ->
    mnesia_manager:insert_bid(UserID,AuctionID,BidAmount,Username,Timestamp),
    io:format("ADDED BID~n").