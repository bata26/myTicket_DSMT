-module(bid_server).

-export([join_auction/3, add_bid/6, end_auction/3, check_if_can_bid/2]).

-record(auction, {auction_id, owner_id, timer}).
-record(users, {auction_id, user_pid, user_id}).
-record(bid, {auction_id, user_id, username, amount, ts}).

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

join_auction(Pid, AuctionID, UserID) ->
    mnesia_manager:join_auction(Pid, AuctionID, UserID),
    Bids = mnesia_manager:get_bids_from_auction_id(AuctionID),
    Length = length(Bids),
    Result =
        case Length > 0 of
            true ->
                ResultList =
                    try
                        iter_bid_list(Bids)
                    catch
                        error:Reason ->
                            io:format("[BID SERVER] join_auction => error: ~p~n", [Reason]),
                            []
                    end,
                {ResultList};
            false ->
                []
        end,
    JsonString = jiffy:encode(Result),
    BinString = iolist_to_binary([JsonString]),
    Pid ! {result, BinString}.

send_message_to_users(Message, UsersList, SenderID) ->
    lists:foreach(
        fun(#users{user_pid = Pid, user_id = UserID} = User) ->
            case UserID == SenderID of
                false ->
                    Pid ! {result, Message};
                true ->
                    io:format("[BID SERVER] send_message_to_users =>  Skip sender~n")
            end
        end,
        UsersList
    ).

update_timer(AuctionID, Pid, UserID, BidAmount) ->
    io:format("[BID SERVER] update_timer~n"),
    Res = mnesia_manager:get_auction_from_auction_id(AuctionID),
    Auction = hd(Res),
    ActualTimerRef = Auction#auction.timer,
    case ActualTimerRef of
        -1 ->
            TimerRef = erlang:send_after(30000, Pid, {bid_timeout, {AuctionID, UserID, BidAmount}});
        _ ->
            erlang:cancel_timer(ActualTimerRef),
            TimerRef = erlang:send_after(30000, Pid, {bid_timeout, {AuctionID, UserID, BidAmount}})
    end,
    mnesia_manager:update_timer_from_auction_id(AuctionID, TimerRef, ActualTimerRef).

check_if_can_bid(UserID, AuctionID) ->
    Res = mnesia_manager:get_auction_from_auction_id(AuctionID),
    Auction = hd(Res),
    OwnerID = Auction#auction.owner_id,
    Ret = 
        case OwnerID == UserID of
            true -> false;
            false -> true
        end,
    Ret.
add_bid(Pid, UserID, AuctionID, BidAmount, Username, Timestamp) ->
    mnesia_manager:insert_bid(UserID, AuctionID, BidAmount, Username, Timestamp),
    Users = mnesia_manager:get_users_from_auction_id(AuctionID),
    Msg = jiffy:encode(
        #{
            <<"opcode">> => <<"RECV BID">>,
            <<"username">> => Username,
            <<"ts">> => Timestamp,
            <<"amount">> => BidAmount
        }
    ),
    update_timer(AuctionID, Pid, UserID, BidAmount),
    send_message_to_users(Msg, Users, UserID),
    Pid ! {result, "OK"}.

send_message_to_users(Message, UsersList) ->
    lists:foreach(
        fun(#users{user_pid = Pid, user_id = UserID} = User) ->
            Pid ! {result, Message}
        end,
        UsersList
    ).
end_auction(AuctionID, WinnerID, BidAmount) ->
    Users = mnesia_manager:get_users_from_auction_id(AuctionID),
    Msg = jiffy:encode(
        #{
            <<"opcode">> => <<"END BID">>,
            <<"winnerID">> => WinnerID,
            <<"amount">> => BidAmount
        }
    ),
    send_message_to_users(Msg, Users).
