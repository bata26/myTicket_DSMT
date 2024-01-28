-module(ws_handler).

-export([init/2, websocket_handle/2, websocket_info/2, terminate/2]).

% Cowboy will call init/2 whenever a request is received,
% in order to establish a websocket connection.
init(Req, _State) ->
    % Switch to cowboy_websocket module
    {cowboy_websocket, Req, none}.

% Cowboy will call websocket_handle/2 whenever a text, binary, ping or pong frame arrives from the client.
websocket_handle({text, Message}, State) ->
    % io:format("[chatroom_websocket] websocket_handle => Frame: ~p, State: ~p~n", [Frame, State]),
    % io:format("[chatroom_websocket] websocket_handle => Received ~p~n", [Frame]),
    io:format("[chatroom_websocket] websocket_handle => Received ~p~n", [Message]),

    try
        {DecodedMessage} = jiffy:decode(Message),
        io:format("[ws_handler] Decoded Message: ~p~n", [DecodedMessage]),
        handle_websocket_frame(DecodedMessage, State)
    catch
        error:Reason ->
            io:format("[ws_handler] websocket_handle => error: ~p~n", [Reason]),
            {ok, State}
    end.

% websocket_handle(_Frame, State) ->
% 	{ok, State}.
% Handle a frame after JSON decoding
handle_websocket_frame(Map, State) ->
    io:format("[ws_handler] handle_websocket_frame => Map is ~p~n", [Map]),
    Opcode = proplists:get_value(<<"opcode">>, Map),
    case Opcode of
        <<"JOIN">> ->
            io:format("JOIN~n"),
            handle_join(Map, State);
        <<"BID">> ->
            handle_bid(Map, State);
        _ ->
            io:format("[ws_handler] handle_websocket_frame => Unknown opcode~n"),
            {ok, State}
    end.

% Handle a login request
handle_join(Map, _State) ->
    UserID = proplists:get_value(<<"userID">>, Map),
    Username = proplists:get_value(<<"username">>, Map),
    AuctionID = proplists:get_value(<<"auctionID">>, Map),
    io:format(
        "[ws_handler] handle_login => login request received for course ~p by user ~p auction: ~p ~n",
        [UserID, Username, AuctionID]
    ),
    bid_server:join_auction(self(), AuctionID, UserID),
    bid_server:get_all_bids(self(), AuctionID),
    {ok, {UserID, Username, AuctionID}}.

% Handle a request for updating online users
handle_bid(Map, _State) ->
    UserID = proplists:get_value(<<"userID">>, Map),
    AuctionID = proplists:get_value(<<"auctionID">>, Map),
    BidAmount = proplists:get_value(<<"amount">>, Map),
    Username = proplists:get_value(<<"username">>, Map),
    Timestamp = proplists:get_value(<<"ts">>, Map),
    io:format(
        "[ws_handler] handle_login => userID: ~p , auctionID: ~p , amount: ~p ts: ~p ~n",
        [UserID, AuctionID, BidAmount, Timestamp]
    ),
    bid_server:add_bid(self(), UserID, AuctionID, BidAmount, Username, Timestamp),
    {ok, {UserID, AuctionID, BidAmount}}.

% Handle a new message sent in the chatroom
handle_chat_message(Map, State = {Course, Username}) ->
    io:format(
        "[ws_handler] handle_chat_message => message received from Pid: ~p in the course: ~p ~n", [
            self(), Course
        ]
    ),
    {ok, Text} = maps:find(<<"text">>, Map),
    chatroom_server:send_message(
        self(),
        binary_to_list(Username),
        Course,
        binary_to_list(Text)
    ),
    {ok, State}.

% Cowboy will call websocket_info/2 whenever an Erlang message arrives
% (=> from another Erlang process).
websocket_info({bids, []}, _State) ->
    io:format("[ws_handler] websocket_handle => Empty bids list~n"),
    {ok, _State};
websocket_info({res, Bids}, _State) ->
    io:format("[ws_handler] websocket_info({result, Bids}, State) => Sending message: ~p~n", [Bids]),
    {[{binary, Bids}], _State};
websocket_info({result, Msg}, State) ->
    io:format("[ws_handler] websocket_info({send_message, Msg}, State) => Send message ~p~n", [Msg]),
    {[{text, Msg}], State};
websocket_info(Info, State) ->
    io:format("ws_handler:websocket_info(Info, State) => Received info ~p~n", [Info]),
    {ok, State}.

terminate({crash, error, undef}, State) ->
    % Aggiungi qui la logica necessaria per gestire l'errore senza terminare il processo.
    % Ad esempio, puoi registrare l'errore, inviare un messaggio di avviso, o eseguire altre azioni necessarie.
    io:format("Errore in ws_handler, ma non termino il processo. Stato corrente: ~p~n", [State]),
    {noreply, State};
terminate(Reason, State) ->
    % Altri casi di terminazione, gestiti come di consueto.
    io:format("Terminazione del ws_handler per motivo sconosciuto: ~p. Stato corrente: ~p~n", [
        Reason, State
    ]),
    {stop, Reason, State}.
