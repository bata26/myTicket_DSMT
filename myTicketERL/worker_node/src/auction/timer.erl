-module(ws_handler).
-export([init/2, websocket_handle/2, websocket_info/2, terminate/2, start_auction/1, end_auction/1]).

% Aggiunta di uno stato per mantenere lo stato dell'asta
-record(auction_state, {
    auction_id,
    timer_ref
}).

% Altre funzioni esistenti...

% Cowboy chiamerà init/2 ogni volta che riceve una richiesta,
% per stabilire una connessione websocket.
init(Req, _State) ->
    % Cambiare a cowboy_websocket module
    {cowboy_websocket, Req, none}.

% Cowboy chiamerà websocket_handle/2 ogni volta che arriva un frame di testo, binario, ping o pong dal client.
websocket_handle({text, Message}, State) ->
    try
        {DecodedMessage} = jiffy:decode(Message),
        handle_websocket_frame(DecodedMessage, State)
    catch
        error:Reason ->
            io:format("[ws_handler] websocket_handle => error: ~p~n", [Reason]),
            {ok, State}
    end.

% Funzione per gestire il frame websocket dopo la decodifica JSON
handle_websocket_frame(Map, State) ->
    io:format("[ws_handler] handle_websocket_frame => Map is ~p~n", [Map]),
    Opcode = proplists:get_value(<<"opcode">>, Map),
    case Opcode of
        <<"JOIN">> ->
            handle_join(Map, State);
        <<"START_AUCTION">> ->
            handle_start_auction(Map, State);
        <<"BID">> ->
            handle_bid(Map, State);
        _ ->
            io:format("[ws_handler] handle_websocket_frame => Unknown opcode~n"),
            {ok, State}
    end.

% Nuova funzione per gestire la richiesta di avvio dell'asta
handle_start_auction(Map, State) ->
    io:format("[ws_handler] handle_start_auction => Starting auction~n"),
    AuctionID = proplists:get_value(<<"auctionID">>, Map),
    TimeoutSeconds = proplists:get_value(<<"timeout">>, Map, 60), % Default a 60 secondi
    % Avvia l'asta e ottieni il nuovo stato
    NewState = start_auction(State, AuctionID, TimeoutSeconds),
    {ok, NewState}.

% Funzione per avviare l'asta e impostare un timer
start_auction(State, AuctionID, TimeoutSeconds) ->
    io:format("[ws_handler] start_auction => Starting auction ~p with timeout ~p seconds~n", [AuctionID, TimeoutSeconds]),
    % Cancella il timer precedente se presente
    State#auction_state.timer_ref =:= none orelse erlang:cancel_timer(State#auction_state.timer_ref),
    % Avvia un nuovo timer per la durata dell'asta
    TimerRef = erlang:start_timer(TimeoutSeconds * 1000, self(), {auction_timeout, AuctionID}),
    % Restituisci il nuovo stato con il riferimento al timer
    State#auction_state{auction_id = AuctionID, timer_ref = TimerRef}.

% Nuova funzione per gestire l'evento di timeout dell'asta
handle_auction_timeout(AuctionID, State) ->
    io:format("[ws_handler] handle_auction_timeout => Auction ~p timed out~n", [AuctionID]),
    % Logica per concludere l'asta, ad esempio, inviare messaggi
    % ai partecipanti sull'esito dell'asta.
    end_auction(State),
    {ok, State}.

% Nuova funzione per gestire la fine dell'asta
end_auction(State) ->
    % Logica per concludere l'asta, ad esempio, inviare messaggi
    % ai partecipanti sull'esito dell'asta.
    io:format("[ws_handler] end_auction => Auction ~p ended~n", [State#auction_state.auction_id]),
    % Cancella il timer alla fine dell'asta
    State#auction_state.timer_ref =:= none orelse erlang:cancel_timer(State#auction_state.timer_ref),
    {ok, State}.

% Cowboy chiamerà websocket_info/2 ogni volta che arriva un messaggio Erlang
% (=> da un altro processo Erlang).
websocket_info({auction_timeout, AuctionID}, State) ->
    % Gestisci l'evento di timeout dell'asta
    handle_auction_timeout(AuctionID, State);
websocket_info({res, Bids}, State) ->
    io:format("[ws_handler] websocket_info({result, Bids}, State) => Sending message: ~p~n", [Bids]),
    {[{binary, Bids}], State};
websocket_info({result, Msg}, State) ->
    io:format("[ws_handler] websocket_info({send_message, Msg}, State) => Send message ~p~n", [Msg]),
    {[{text, Msg}], State};
websocket_info(Info, State) ->
    io:format("ws_handler:websocket_info(Info, State) => Received info ~p~n", [Info]),
    {ok, State}.

% Altre funzioni esistenti...

