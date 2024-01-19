package it.DSMT.myTicket.model;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.rqlite.NodeUnavailableException;
import com.rqlite.Rqlite;
import com.rqlite.dto.QueryResults;

import it.DSMT.myTicket.controller.DbController;

public class Auction {
    private int id;
    private int ticket_id;
    private float final_bid;
    private int winner_id;

    public Auction(){}

    public Auction(int ticket_id) {
        this.ticket_id = ticket_id;
        this.final_bid = 0;
        this.winner_id = -1;
    }

    public Auction(int id,int ticket_id,float final_bid,int winner_id) {
        this.id = id;
        this.ticket_id = ticket_id;
        this.final_bid = final_bid;
        this.winner_id = winner_id;
    }

    public void addAuction() throws NodeUnavailableException {
        String query = "INSERT INTO auction(ticket_id, final_bid, winner_id) values( " + this.ticket_id + ","
                + this.final_bid + "," + this.winner_id + ")";
        DbController.getInstance().getConnection().Execute(query);
    }

    public void removeAuction() throws NodeUnavailableException {
        String query = "DELETE FROM auction WHERE id = " + this.id;
        DbController.getInstance().getConnection().Execute(query);
    }

    public static Auction getOne(int auctionID) throws NodeUnavailableException, Exception {
        QueryResults res = DbController.getInstance().getConnection()
                .Query("SELECT * FROM auction where id = " + auctionID, Rqlite.ReadConsistencyLevel.STRONG);
        Gson gson = new Gson();
        String json = gson.toJson(res);
        JsonObject jsonObject = gson.fromJson(json, JsonObject.class);

        if (!jsonObject.has("error")) {
            JsonArray values = jsonObject.getAsJsonArray("results")
                    .get(0).getAsJsonObject()
                    .getAsJsonArray("values");
            JsonElement element = values.getAsJsonArray().get(0);
            return Auction.parseQueryResult(element);
        }
        return null;
    }

    public static Auction getOneFromTicketID(int ticketID) throws NodeUnavailableException, Exception {
        QueryResults res = DbController.getInstance().getConnection().Query("SELECT * FROM auction where ticket_id = " + ticketID, Rqlite.ReadConsistencyLevel.STRONG);
        Gson gson = new Gson();
        String json = gson.toJson(res);
        JsonObject jsonObject = gson.fromJson(json, JsonObject.class);

        if (!jsonObject.has("error")) {
            JsonArray values = jsonObject.getAsJsonArray("results")
                    .get(0).getAsJsonObject()
                    .getAsJsonArray("values");
            JsonElement element = values.getAsJsonArray().get(0);
            return Auction.parseQueryResult(element);
        }
        return null;
    }

    private static Auction parseQueryResult(JsonElement element) {
        System.out.println("elem : "  + element);
        int id = element.getAsJsonArray().get(0).getAsInt();
        int final_bid = element.getAsJsonArray().get(1).getAsInt();
        int ticket_id = element.getAsJsonArray().get(2).getAsInt();
        int winner_id = element.getAsJsonArray().get(3).getAsInt();
        return new Auction(id, ticket_id,final_bid, winner_id);
    }

    public int getID(){
        return this.id;
    }

    public int getTicketID(){
        return this.ticket_id;
    }

    public int getWinnerID(){
        return this.winner_id;
    }

    public float getFinalBid(){
        return this.final_bid;
    }
}
