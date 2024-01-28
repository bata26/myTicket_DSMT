-module(bid_server).

-export([join_auction/3, add_bid/6]).

-record(auction, {auction_id, owner_id}).
-record(users, {auction_id, user_pid, user_id}).
-record(bid, {auction_id, user_id, username, amount, ts}).

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
                            io:format("error: ~p~n", [Reason]),
                            []
                    end,
                io:format("RESULTLIST : ~p~n", [ResultList]),
                io:format("La lista non è vuota.~n"),
                {ResultList};
            false ->
                io:format("La lista è vuota.~n"),
                []
        end,
    JsonString = jiffy:encode(Result),
    BinString = iolist_to_binary([JsonString]),
    Pid ! {result, BinString}.

send_message_to_users(Message, UsersList, SenderID) ->
    lists:foreach(
        fun(#users{user_pid = Pid, user_id = UserID} = User) ->
            io:format("SENDER : ~p~n" , [SenderID]),
            io:format("USER : ~p~n" , [UserID]),
            case UserID == SenderID of
                false ->
                    Pid ! {result, Message};
                true ->
                    io:format("Skip sender~n")
            end
        end,
        UsersList
    ).

add_bid(Pid, UserID, AuctionID, BidAmount, Username, Timestamp) ->
    mnesia_manager:insert_bid(UserID, AuctionID, BidAmount, Username, Timestamp),
    Pid ! {result, "OK"},
    io:format("Update All other users~n"),
    Users = mnesia_manager:get_users_from_auction_id(AuctionID),
    io:format("Users : ~p~n", [Users]),
    Msg = jiffy:encode(
        #{
            <<"opcode">> => <<"RECV BID">>,
            <<"username">> => Username,
            <<"ts">> => Timestamp,
            <<"amount">> => BidAmount
        }
    ),
    io:format("msg : ~p~n", [Msg]),
    send_message_to_users(Msg, Users, UserID),
    io:format("ONLINE USERS : ~p~n", [Users]).
