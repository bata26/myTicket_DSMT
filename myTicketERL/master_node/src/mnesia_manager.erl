-module(mnesia_manager).

-export([create_auction/2]).


create_auction(UserID, AuctionID) ->
    mnesia:transaction(fun() ->
        %% Inserisci il record nella tabella
        mnesia:write({auction, AuctionID, UserID})
    end).