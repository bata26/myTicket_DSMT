-module(mnesia_manager).
-export([get_bids_from_auction_id/1, insert_bid/4]).

-record(auction, {auction_id, owner_id}).
-record(bid, {auction_id, user_id, username, amount}).

get_bids_from_auction_id(AuctionID) ->
    Fun = fun() ->
        io:format(
            "[mnesia_manager] get_online_students => Get all the online students for the auction: ~p~n",
            [AuctionID]
        ),
        Query = #bid{auction_id = '$1', user_id = '$2', username = '$3', amount = '$4'},
        Guard = {'==', '$1', AuctionID},
        mnesia:select(bid, [{Query , [Guard], ['$4' ]}])
    end,

    {atomic, Result} = mnesia:transaction(Fun),
    io:format("[mnesia_manager] get_online_students => Online students: ~p~n", [Result]),
    Result.

insert_bid(UserID, AuctionID, BidAmount, Username) ->
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
                amount = BidAmount
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
