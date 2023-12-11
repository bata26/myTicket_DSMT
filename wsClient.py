import websocket
import time

def on_message(ws, message):
    print(f"Ricevuto messaggio: {message}")

def on_error(ws, error):
    print(f"Errore: {error}")

def on_close(ws):
    print("Connessione chiusa")

def on_open(ws):
    print("Connessione aperta")
    # Esempio di invio di un messaggio al server una volta aperta la connessione
    ws.send("Ciao, server!")

if __name__ == "__main__":
    # Indirizzo del server WebSocket
    websocket_url = "ws://localhost:8080/websocket"

    # Inizializzazione e connessione al server WebSocket
    websocket.enableTrace(True)
    ws = websocket.WebSocketApp(websocket_url,
                                on_message=on_message,
                                on_error=on_error,
                                on_close=on_close)
    ws.on_open = on_open
    ws.run_forever()
