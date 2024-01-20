package it.DSMT.myTicket.dto;

import java.time.LocalDate;

public class ActiveAuctionDTO {
    private int auctionID;
    private int ticketID;
    private int ownerID;
    private String title;
    private LocalDate date;
    private int hour;
    private String city;
    private String artist;
    private float finalBid;
    private int winnerID;

    public int getAuctionID() {
        return auctionID;
    }

    public int getTicketID() {
        return ticketID;
    }

    public int getOwnerID() {
        return ownerID;
    }

    public String getTitle() {
        return title;
    }

    public LocalDate getDate() {
        return date;
    }

    public int getHour() {
        return hour;
    }

    public String getCity() {
        return city;
    }

    public String getArtist() {
        return artist;
    }

    public float getFinalBid() {
        return finalBid;
    }

    public int getWinnerID() {
        return winnerID;
    }

    public ActiveAuctionDTO(int auctionID, int ticketID, int ownerID, String title, LocalDate date, int hour, String city, String artist, float finalBid, int winnerID){
        this.auctionID = auctionID;
        this.ticketID = ticketID;
        this.ownerID = ownerID;
        this.title = title;
        this.date = date;
        this.hour = hour;
        this.city = city;
        this.artist = artist;
        this.finalBid = finalBid;
        this.winnerID = winnerID;
    }
}
