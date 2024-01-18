package it.DSMT.myTicket.model;
import java.text.SimpleDateFormat;
import java.util.Date;

import it.DSMT.myTicket.controller.DbController;
import com.rqlite.NodeUnavailableException;
import com.rqlite.dto.QueryResults;
import com.rqlite.Rqlite;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonElement;


public class Ticket {
    private int ownerID;
    private String title;
    private Date date;
    private int hour;
    private String city;

    public Ticket(int ownerID, String title, Date date, int hour, String city) {
        this.ownerID = ownerID;
        this.title = title;
        this.date = date;
        this.hour = hour;
        this.city = city;
    }

    public static Ticket getTicketFromID(int ticketID) throws NodeUnavailableException{
        QueryResults res = DbController.getInstance().getConnection().Query("SELECT * FROM ticket where id = " + ticketID, Rqlite.ReadConsistencyLevel.STRONG);
        Gson gson = new Gson();
        String json = gson.toJson(res);
        System.out.println(json);
        JsonObject jsonObject = JsonParser.parseString(json).getAsJsonObject();
        System.out.println(jsonObject);
        
        if(!jsonObject.has("error")){
            System.out.println("ERROR");
            // [1,"concertone","0001-01-01T00:00:00Z",21,"Roma",0]
            int id = getAsJsonArray("results").get(0).getAsJsonArray("values").get(0).get(0);
            return new Ticket(
                getAsJsonArray("results").get(0).getAsJsonArray("values").get(0).get(0),
                getAsJsonArray("results").get(0).getAsJsonArray("values").get(0).get(1),
                getAsJsonArray("results").get(0).getAsJsonArray("values").get(0).get(2),
                getAsJsonArray("results").get(0).getAsJsonArray("values").get(0).get(3),
                getAsJsonArray("results").get(0).getAsJsonArray("values").get(0).get(4)
            );
        }
        //System.out.println("RES : " + res.results[0]);
        //return new Ticket()
    }

    public void addTicket() throws NodeUnavailableException{
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        String formattedDate = sdf.format(this.date);
        String query = "INSERT INTO ticket(owner_id, title, date, hour, city) values( " +this.ownerID + ",'" +this.title+ "', '" +formattedDate+ "'," + this.hour + ",'" +this.city+ "')";
        System.out.println(query);
        DbController.getInstance().getConnection().Execute("INSERT INTO ticket(owner_id, title, date, hour, city) values( \n"+
                this.ownerID + ",\n" +
                "'" +this.title+ "',\n" +
                "'" +formattedDate+ "',\n" +
                this.hour + ",\n" +
                "'" +this.city+ "'\n" +
                ")"
            );
    }

    public int getOwnerID(){
        return this.ownerID;
    }
    public String getTitle(){
        return this.title;
    }
    public Date getDate(){
        return this.date;
    }
    public int getHour(){
        return this.hour;
    }
    public String getCity(){
        return this.city;
    }

}
