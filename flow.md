# FLOW FOR CRITIC EVENTS

### Auction created
1. User create an auction via http request to SW.
2. SW add the auction on MongoDB
    2.1. If the insert is ok
        2.1.1. SW sends a message to both the masters node
        2.1.2. Masters Node create a worker node for the specific auction
        2.1.3. Worker Nodes create the entry on mnesiaDB
        2.1.4. Worker Nodes open connection for websocket
        2.1.5. Master returns to SW the specific url for websocket
        2.1.6. SW returns '200-OK' to client

### Join Auction
1. User click join auction
2. SW returns the websocket url

### Auction management
- For each bid:
    - the worker node needs to update the mnesiaDB
    - the worker node needs to update each client