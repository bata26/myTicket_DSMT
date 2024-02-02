package it.DSMT.myTicket.dto;

public class CloseAuctionDTO {
    private int auctionID;
    private int winnerID;
    private int lastBid;

    public int getAuctionID() {
        return auctionID;
    }

    public void setAuctionID(int auctionID) {
        this.auctionID = auctionID;
    }

    public int getWinnerID() {
        return winnerID;
    }

    public void setWinnerID(int winnerID) {
        this.winnerID = winnerID;
    }

    public int getLastBid() {
        return lastBid;
    }

    public void setLastBid(int lastBid) {
        this.lastBid = lastBid;
    }

}
