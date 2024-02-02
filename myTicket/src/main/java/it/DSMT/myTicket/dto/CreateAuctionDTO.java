package it.DSMT.myTicket.dto;

public class CreateAuctionDTO {
    private int ticketID;
    private int userID;

    public CreateAuctionDTO() {
    }

    public CreateAuctionDTO(int ticketID) {
        this.ticketID = ticketID;
    }

    public CreateAuctionDTO(int ticketID, int userID) {
        this.ticketID = ticketID;
        this.userID = userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public int getTicketID() {
        return ticketID;
    }

    public void setTicketID(int ticketID) {
        this.ticketID = ticketID;
    }

    public int getUserID() {
        return userID;
    }

}
