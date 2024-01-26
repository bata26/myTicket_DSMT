### labels to save:
- event_name
- primary_act_name
- secondary_act_name
- minor_cat_name
- event_disp_name
- event_date_time
- venue_city
- venue_state

### to add:
- total_of_tickets
- price

### to modify:
- date of events

# Doc
Useful links:
- https://www.oxagile.com/article/load-balancing-of-websocket-connections/#:~:text=The%20problem%20of%20load%20balancing,problem%20is%20crucial%20for%20performance.

- https://stackoverflow.com/questions/66059636/chat-room-in-erlang-with-cowboy-and-websocket

# DB
4 Tables (Sqlite3):
- User {
    id
    username
    password
}
- Auction {
    id
    ticket_id : FK Ticket.id
    final_bid
    winner_id : FK User.id
}
- Ticket {
    id
    owner_id : FK User.id
    title
    date
    hour
    city
}
- Bid {
    id
    auction_id : FK Auction.id
    user_id : FK User.id
    ts
    amount
}


# OPERAZIONI
1. login
2. logout
3. registrazione
4. aggiunta di un biglietto
5. eliminazione di un biglietto
6. ricerca di un biglietto
7. creazione di un'asta
8. join di un'asta
9. vincita di un'asta
10. puntata per un'asta
11. chiusura di un'asta

### 1-Login
La registrazione avviene tramite mail e password. La password viene inviata in chiaro (si spera sotto TLS).

Request: /login (POST)
body: 
{
    "mail": ,
    "password": 
}

Il server restituisce un JWT oppure l'objectId che viene utilizzato per le richieste future.

### 2-Logout
L'utente esce dall'applicazione, viene cancellato dal local-storage il suo token/ID.

Request: /logout (GET)

### 3-Registrazione
L'utente si registra tramite un form inserendo i campi:

- Nome
- Cognome
- Data di nascita
- mail
- password

Request: /register (POST)
body:
{
    "name",
    "surname",
    "date",
    "mail",
    "password"
}

Dopodichè il client viene redirectato alla home.

### 4-Aggiunta di un biglietto
L'utente tramite un form può inserire un nuovo biglietto, le informazioni necessarie saranno:

- artista
- data
- luogo
- città
- stato
- costo di partenza
- numero di biglietti

Request: /ticket (POST)

body
{
    artist
    date
    place
    city
    state
    startingPrice
    numbers
}

### 5-Eliminazion ticket
Un utente che possiede un biglietto può decidere di eliminarlo uno o più

Request: /ticket/<ticketID> (DELETE)

### 6-Ricerca biglietto
Un utente può cercare un biglietto, questo avviene sul campo titolo, se non viene specificato durante la creazione, il titolo è l'insieme di artista, luogo, città e data.

Request: /ticket?title= (GET)

### 7-Creazione Asta
Il proprietario di un biglietto può creare un'asta per uno dei suoi biglietti. Può settare una durata e aspettare che qualcuno offra. 


# Doc for presentation

# myTicket
myTicket is a platform where users can buy and sell ticket for events. Each user can sell his own ticket creating an auction. Every user can partecipate to an auction and the winner will get the ticket.

### Functional requirements:
- A user can register to the platform.
- A registered user can join multiple auction.
- A registered user can create or delete an auction wrt his own tickets.
- A registered user cannot create a bid on his auction.
- A registered user can create a bid for an auction.
- A registered user can add a ticket to his own list of tickets.
- Every auction has a setted duration time.
- Every auction is accessible to all registered user.
- Every auction has a winner.
- A registered user can see every auction.
- A registered user needs to registrate to partecipate to an auction.
- During an auction, every user registered to it, can see the remaining time.
- During an auction, every user registered to it, can see the older bids.
- A user can login with username and password.

### Non functional requirements:
- Communication between client and server use HTTP protocol. (HTTPS preferred)
- When a user join an auction, communication between client ad server use WebSocket. (WSS preferred)
- System need to be available even if one node fails.
- System need to be consistent even if one node fails.
- There will be a load balancer to manage the request load.
- Each node is going to have the same data.

### Erlang Usage
About Erlang, each node will have a erlang process, called master node. The master node will create a new process, called worker node for each auction. This is going to happen on all physical node. In this way each worker node can communicate with his respective worker node to exchange info about last bids and auction evolution. Only masters node will communicate with Java Spring Web Server.


docker container:
docker run  -p 4001:4001 -p 4002:4002 -v rqlite-dir:/rqlite/file rqlite/rqlite -node-id 1

mvn install:install-file -Dfile=/usr/local/Cellar/erlang/26.0.2/lib/erlang/lib/jinterface-1.14/priv/OtpErlang.jar -DgroupId=com.ericsson -DartifactId=erlang-jinterface -Dversion=1.14 -Dpackaging=jar -DgeneratePom=true

# MNESIA DATABASE:
- auction:
    auctionID
    owner_id
- bid
    auctionID
    userID
    username
    amount
