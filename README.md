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

## Presentazione
L'applicazione myTicket è una piattaforma di compravendita di biglietti per concerti musicali. Essa permette agli utenti di acquistare biglietti per i concerti presenti nella piattaforma. Inoltre nella sezione Bid è possibile avere delle mini-aste per comprare biglietti all'ultimo minuto.

## Actors
Ci sono 3 tipi diversi di attori:
- Admin
- Manager
- Utenti

### Admin
L'amministratore ha il completo controllo sulla piattaforma, può creare eventi, eliminarli e modificarli. 

### Manager
Il manager può eseguire le seguenti operazioni:
- login/logout
- registrarsi alla piattaforma
- aggiungere un evento
- eliminare uno dei suoi eventi
- modificare i suoi eventi
- creare un'asta per uno dei suoi eventi
- chiudere un'asta per uno dei suoi eventi

### User
Lo user può eseguire le seguenti operazioni:
- login/logout
- registrarsi alla piattaforma
- acquistare un biglietto
- navigare tra i concerti
- cercare un evento in particolare
- creare un'asta per uno dei biglietti che possiede
- chiudere un'asta per uno dei biglietti che possiede

### Development
- **SW**: Server Web (Java Glassfish o Spring)
- **EMN**: Erlang Master Node
- **EWN**: Erlang Worker Node
- **MNDB**: MnesiaDB
- **MODB**: MongoDB
- **RDDB**: RedisDB

### Idee
Gestione di login, registrazione e logout con un semplice server web in java.

### Aste
- Creazione asta:
1. Utente invia richiesta SW, il server web lo autentifica e gli risponde con il codice univoco dell'asta.
2. L'asta viene registrata dal master node, inserisce una nuova entry nel db e genera un worker node su entrambe le macchine. gestendo anche la consistenza nel db.

- Iscrizione asta:
1. Utente invia iscrizione asta al SW, il SW lo autentifica e lo registra all'asta corrente inviando una richiesta al master node restituisce un token di autenticazione.
2. con questo token il client invia richieste tramite websocket a erlang.






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
