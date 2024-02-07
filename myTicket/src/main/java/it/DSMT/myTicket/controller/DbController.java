package it.DSMT.myTicket.controller;
import com.rqlite.NodeUnavailableException;
import com.rqlite.Rqlite;
import com.rqlite.dto.QueryResults;
import com.rqlite.dto.ExecuteResults;
import com.rqlite.RqliteFactory;
import com.rqlite.impl.ExecuteRequest;
import com.rqlite.Rqlite.*;

public  class DbController {
    // Declare variables.
    private ExecuteResults results = null;
    private QueryResults rows = null;
    private Rqlite connection = null;

    private static DbController instance = null;

    // Metodo pubblico per ottenere l'istanza del singleton
    public static  DbController getInstance(){
        if (instance == null) {
            try{
                instance = new DbController();
            } catch (NodeUnavailableException e){
                System.out.println("[DB] Node unavailable");
            }
        }
        return instance;
    }

    public Rqlite getConnection(){
        return DbController.getInstance().connection;
    }

    public DbController () throws NodeUnavailableException {
        // Get a connection to a rqlite node.
        this.connection = RqliteFactory.connect("http", "10.2.1.117", 4001);

        // Create a table.
        System.out.println("[DB] CREATE USER TABLE");
        results = connection.Execute("CREATE TABLE IF NOT EXISTS  user (id integer not null primary key autoincrement, username text, password text)");
        System.out.println(results.toString());

        System.out.println("[DB] CREATE TICKET TABLE");
        results = connection.Execute("CREATE TABLE IF NOT EXISTS ticket (\n" +
                "id integer not null primary key autoincrement,\n" +
                "title text,\n" +
                "date DATE,\n" +
                "hour integer,\n" +
                "city text,\n" +
                "owner_id integer,\n" +
                "artist text,\n" +
                "foreign key (owner_id) references user(id)\n" +
                ");");
        System.out.println(results.toString());

        System.out.println("[DB] CREATE AUCTION TABLE");
        results = connection.Execute("CREATE TABLE IF NOT EXISTS auction (\n" +
                "id INTEGER PRIMARY KEY autoincrement,\n" +
                "final_bid FLOAT,\n" +
                "ticket_id INTEGER,\n" +
                "winner_id INTEGER,\n" +
                "FOREIGN KEY (ticket_id) REFERENCES ticket(id)\n" +
                "FOREIGN KEY (winner_id) REFERENCES user(id)\n" +
                ");");
        System.out.println(results.toString());

        System.out.println("[DB] CREATE BID TABLE");
        results = connection.Execute("CREATE TABLE IF NOT EXISTS bid (\n" +
                "id INTEGER PRIMARY KEY autoincrement,\n" +
                "auction_id INTEGER,\n" +
                "user_id INTEGER,\n" +
                "ts DATE,\n" +
                "amount FLOAT\n"+
                "FOREIGN KEY (auction_id) REFERENCES auction(id)\n" +
                "FOREIGN KEY (user_id) REFERENCES user(id)\n" +
                ");");
        System.out.println(results.toString());
    }

}
