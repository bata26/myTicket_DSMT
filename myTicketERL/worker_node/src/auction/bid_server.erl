-module(bid_server).

-export([get_all_bids/2, add_bid/5]).

-record(auction, {auction_id, owner_id}).
-record(bid, {auction_id, user_id, username, amount}).

get_all_bids(Pid, AuctionID) ->
    Bids = mnesia_manager:get_bids_from_auction_id(AuctionID),
    io:format("BIDS : ~p~n" , [Bids]).

add_bid(Pid,UserID,AuctionID,BidAmount,Username) ->
    mnesia_manager:insert_bid(UserID,AuctionID,BidAmount,Username),
    io:format("ADDED BID~n").