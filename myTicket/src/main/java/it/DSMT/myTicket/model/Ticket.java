package it.DSMT.myTicket.model;
import java.time.LocalDate;

import java.util.ArrayList;
import java.util.List;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;


import it.DSMT.myTicket.controller.DbController;
import com.rqlite.NodeUnavailableException;
import com.rqlite.dto.QueryResults;
import com.rqlite.Rqlite;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import java.time.format.DateTimeFormatter;


public class Ticket {
    private int id;
    private int ownerID;
    private String title;
    private LocalDate date;
    private int hour;
    private String city;
    private String artist;

    public Ticket(){

    }

    public Ticket(int ownerID, String title, LocalDate date, int hour, String city, String artist) {
        this.ownerID = ownerID;
        this.title = title;
        this.date = date;
        this.hour = hour;
        this.city = city;
        this.artist = artist;
    }

    public Ticket(int ownerID, String title, LocalDate date, int hour, String city, int id, String artist) {
        this.ownerID = ownerID;
        this.title = title;
        this.date = date;
        this.hour = hour;
        this.city = city;
        this.id = id;
        this.artist = artist;
    }

    public static Ticket getTicketFromID(int ticketID) throws NodeUnavailableException, Exception{
        QueryResults res = DbController.getInstance().getConnection().Query("SELECT * FROM ticket where id = " + ticketID, Rqlite.ReadConsistencyLevel.STRONG);
        Gson gson = new Gson();
        String json = gson.toJson(res);
        JsonObject jsonObject = gson.fromJson(json, JsonObject.class);
        
        if(!jsonObject.has("error")){
            JsonArray values = jsonObject.getAsJsonArray("results")
                    .get(0).getAsJsonObject()
                    .getAsJsonArray("values");
            JsonElement element = values.getAsJsonArray().get(0);
            return Ticket.parseQueryResult(element);
        }
        return null;
    }

    public void removeTicket() throws NodeUnavailableException {
        String query = "DELETE FROM ticket WHERE id = " + this.id;
        System.out.println(query);
        DbController.getInstance().getConnection().Execute(query);
    }

    public void addTicket() throws NodeUnavailableException{
        String query = "INSERT INTO ticket(owner_id, title, date, hour, city, artist) values( " +this.ownerID + ",'" +this.title+ "', '" +this.date+ "'," + this.hour + ",'" +this.city+ "')";
        System.out.println(query);
        DbController.getInstance().getConnection().Execute("INSERT INTO ticket(owner_id, title, date, hour, city, artist) values( \n"+
                this.ownerID + ",\n" +
                "'" +this.title+ "',\n" +
                "'" +this.date+ "',\n" +
                this.hour + ",\n" +
                "'" +this.city+ "',\n" +
                "'" +this.artist+ "'\n" +
                ")"
            );
    }

    public static List<Ticket> getMany(String title)  throws NodeUnavailableException {
        String query = "SELECT * FROM ticket ";
        if (title != "") {
            query = query + "WHERE title LIKE '%" + title+"%'";
        }
        QueryResults res = DbController.getInstance().getConnection().Query(query,  Rqlite.ReadConsistencyLevel.STRONG);
        System.out.println("RES: " + res.results[0]);

        Gson gson = new Gson();
        String json = gson.toJson(res);
        JsonObject jsonObject = gson.fromJson(json, JsonObject.class);
        JsonArray values = jsonObject.getAsJsonArray("results")
                .get(0).getAsJsonObject()
                .getAsJsonArray("values");
        List<Ticket> tickets = new ArrayList<>();

        // Itera sugli elementi del JsonArray
        for (JsonElement row : values) {
            tickets.add(Ticket.parseQueryResult(row));
        }

        return tickets;

    }

    private static Ticket parseQueryResult(JsonElement element){
        int id = element.getAsJsonArray().get(0).getAsInt();
        String ticketTitle = element.getAsJsonArray().get(1).getAsString();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        String dateString = element.getAsJsonArray().get(2).getAsString().substring(0,10);
        // Parsa la stringa nella data usando il formatter
        LocalDate date = LocalDate.parse(dateString, formatter);
        int hour = element.getAsJsonArray().get(3).getAsInt();
        String city = element.getAsJsonArray().get(4).getAsString();
        int ownerID = element.getAsJsonArray().get(5).getAsInt();
        String artist = element.getAsJsonArray().get(6).getAsString();
        return new Ticket(ownerID, ticketTitle, date, hour, city, id, artist);
    }
    public int getOwnerID(){
        return this.ownerID;
    }
    public String getTitle(){
        return this.title;
    }
    public String getArtist(){
        return this.artist;
    }
    public LocalDate getDate(){
        return this.date;
    }
    public int getHour(){
        return this.hour;
    }
    public String getCity(){
        return this.city;
    }

}
