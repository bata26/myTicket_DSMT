-module(mnesia_manager).
-export([
    get_bids_from_auction_id/1,
    insert_bid/5,
    join_auction/3,
    get_users_from_auction_id/1,
    get_auction_from_auction_id/1,
    update_timer_from_auction_id/3
]).

-record(auction, {auction_id, owner_id, timer}).
-record(bid, {auction_id, user_id, username, amount, ts}).
-record(users, {auction_id, user_pid, user_id}).

get_bids_from_auction_id(AuctionID) ->
    Fun =
        fun() ->
            mnesia:match_object({bid, AuctionID, '_', '_', '_', '_'})
        end,
    {atomic, Result} = mnesia:transaction(Fun),
    io:format("[WORKER NODE MNESIA MANAGER] get_bids_from_auction_id => bids: ~p~n", [Result]),
    Result.

join_auction(Pid, AuctionID, UserID) ->
    Fun = fun() ->
        % Tenta di leggere il record esistente dal database
        ExistingRecord = mnesia:match_object({users, AuctionID, '_', UserID}),
        case ExistingRecord of
            % Se il record esiste, aggiorna il campo user_pid
            [#users{user_id = UserID} = OldRecord] ->
                UpdatedRecord = OldRecord#users{user_pid = Pid},
                mnesia:write(UpdatedRecord);
            % Se il record non esiste, crea un nuovo record
            [] ->
                NewRecord = #users{auction_id = AuctionID, user_pid = Pid, user_id = UserID},
                mnesia:write(NewRecord)
        end
    end,
    {atomic, Result} = mnesia:transaction(Fun),
    io:format("[WORKER NODE MNESIA MANAGER] join_auction => join request returned response: ~p~n", [
        Result
    ]),
    mnesia:transaction(fun() ->
        Users = mnesia:select(users, [{'_', [], ['$_']}])
    end).

insert_bid(UserID, AuctionID, BidAmount, Username, Timestamp) ->
    Fun = fun() ->
        io:format("[WORKER NODE MNESIA MANAGER] insert_bid => Inserting bid for UserID: ~p, AuctionID: ~p, BidAmount: ~p, Username: ~p~n",[UserID, AuctionID, BidAmount, Username]),
        mnesia:write(
            #bid{
                auction_id = AuctionID,
                user_id = UserID,
                username = Username,
                amount = BidAmount,
                ts = Timestamp
            }
        )
    end,
    {atomic, Result} = mnesia:transaction(Fun),
    io:format("[WORKER NODE MNESIA MANAGER] insert_bid => insert bid returned response: ~p~n", [
        Result
    ]),
    mnesia:transaction(fun() ->
        Bids = mnesia:select(bid, [{'_', [], ['$_']}])
    end),
    Result.

get_users_from_auction_id(AuctionID) ->
    Fun =
        fun() ->
            mnesia:match_object({users, AuctionID, '_', '_'})
        end,
    {atomic, Result} = mnesia:transaction(Fun),
    io:format("[WORKER NODE MNESIA MANAGER] get_users_from_auction_id => users: ~p~n", [Result]),
    Result.

get_auction_from_auction_id(AuctionID) ->
    Fun =
        fun() ->
            mnesia:match_object({auction, AuctionID, '_', '_'})
        end,
    {atomic, Result} = mnesia:transaction(Fun),
    io:format("[WORKER NODE MNESIA MANAGER] get_auction_from_auction_id => Auction: ~p~n", [Result]),
    Result.

update_timer_from_auction_id(AuctionID, NewTimerRef, OldTimerRef) ->
    Fun =
        fun() ->
            Auction = mnesia:match_object({auction, AuctionID, '_', '_'}),
            AuctionHd = hd(Auction),
            OwnerID = AuctionHd#auction.owner_id,
            RecordsToDelete = mnesia:match_object({auction, AuctionID, OwnerID, OldTimerRef}),
            mnesia:delete_object({auction, AuctionID, OwnerID, OldTimerRef}),
            mnesia:write(
                #auction{
                    auction_id = AuctionID,
                    owner_id = OwnerID,
                    timer = NewTimerRef
                }
            )
        end,
    {atomic, Result} = mnesia:transaction(Fun),
    io:format("[WORKER NODE MNESIA MANAGER] RESULT POST UPDATE ~p~n", [Result]).
