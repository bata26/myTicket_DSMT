package it.DSMT.myTicket.dto;

public class CreatedAuctionDTO {
    private int auctionID;

    public CreatedAuctionDTO() {
    }   

    public CreatedAuctionDTO(int auctionID) {
        this.auctionID = auctionID;
    }

    public int getAuctionID() {
        return auctionID;
    }

    public void setAuctionID(int auctionID) {
        this.auctionID = auctionID;
    }
}
