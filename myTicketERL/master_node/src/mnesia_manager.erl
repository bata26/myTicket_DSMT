-module(mnesia_manager).

-export([create_auction/2]).

-record(auction, {auction_id, owner_id, timer}).
create_auction(UserID, AuctionID) ->
    mnesia:transaction(fun() ->
        %% Inserisci il record nella tabella
        mnesia:write({auction, AuctionID, UserID, -1})
    end).