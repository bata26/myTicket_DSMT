-module(mnesia_manager).
-export([get_bids_from_auction_id/1, insert_bid/5, join_auction/3,get_users_from_auction_id/1]).

-record(auction, {auction_id, owner_id}).
-record(bid, {auction_id, user_id, username, amount, ts}).
-record(users, {auction_id, user_pid, user_id}).

get_bids_from_auction_id(AuctionID) ->
    Fun =
        fun() ->
            mnesia:match_object({bid, AuctionID, '_', '_', '_', '_'})
        end,
    {atomic, Result} = mnesia:transaction(Fun),
    io:format("[mnesia_manager] get_online_students => Online students: ~p~n", [Result]),
    Result.

join_auction(Pid, AuctionID, UserID) -> 
    Fun = fun() ->
        %io:format("[mnesia_manager] join_course => Check if the pid of the student: ~p is already in a chatroom ~n", [StudentPid]),
        %NewStudent = #online_students{course_id='$1', student_pid = '$2', student_name = '$3', hostname = 'S4'},
        %Guard = {'==', '$2', StudentPid},
        %NewStudentCheck = mnesia:select(online_students, [{NewStudent, [Guard], ['$2']}]),
        io:format(
            "[mnesia_manager] insert_bid => Add USER Pis: ~p, AuctionID: ~p, UserID : ~p~n",
            [Pid, AuctionID, UserID]
        ),
        %io:format("[mnesia_manager] join_auction => Check result: ~p~n", [AuctionID]),
        %io:format("[mnesia_manager] join_auction => Student not in any chatroom, student can be join this chat ~n"),
        mnesia:write(
            #users{
                auction_id = AuctionID,
                user_pid = Pid,
                user_id = UserID
            }
        )
    end,
    {atomic, Result} = mnesia:transaction(Fun),
    io:format("[mnesia_manager] join_course => Chatroom join request returned response: ~p~n", [
        Result
    ]),
    mnesia:transaction(fun() ->
        io:format("[mnesia_manager] join_auction => All users after insertion:~n"),
        Users = mnesia:select(users, [{'_', [], ['$_']}]),
        io:format("[mnesia_manager] join_auction => All users after insertion: ~p~n", [Users])
    end).
insert_bid(UserID, AuctionID, BidAmount, Username, Timestamp) ->
    Fun = fun() ->
        %io:format("[mnesia_manager] join_course => Check if the pid of the student: ~p is already in a chatroom ~n", [StudentPid]),
        %NewStudent = #online_students{course_id='$1', student_pid = '$2', student_name = '$3', hostname = 'S4'},
        %Guard = {'==', '$2', StudentPid},
        %NewStudentCheck = mnesia:select(online_students, [{NewStudent, [Guard], ['$2']}]),
        io:format(
            "[mnesia_manager] insert_bid => Inserting bid for UserID: ~p, AuctionID: ~p, BidAmount: ~p, Username: ~p~n",
            [UserID, AuctionID, BidAmount, Username]
        ),
        %io:format("[mnesia_manager] join_auction => Check result: ~p~n", [AuctionID]),
        %io:format("[mnesia_manager] join_auction => Student not in any chatroom, student can be join this chat ~n"),
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
    io:format("[mnesia_manager] join_course => Chatroom join request returned response: ~p~n", [
        Result
    ]),
    mnesia:transaction(fun() ->
        io:format("[mnesia_manager] insert_bid => All bids after insertion:~n"),
        Bids = mnesia:select(bid, [{'_', [], ['$_']}]),
        io:format("[mnesia_manager] insert_bid => All bids after insertion: ~p~n", [Bids])
    end),
    Result.

get_users_from_auction_id(AuctionID) ->
    Fun =
        fun() ->
            mnesia:match_object({users, AuctionID, '_', '_'})
        end,
    {atomic, Result} = mnesia:transaction(Fun),
    io:format("[mnesia_manager] get_online_students => Online users: ~p~n", [Result]),
    Result.
