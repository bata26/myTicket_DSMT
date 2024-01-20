package it.DSMT.myTicket.dto;

import java.util.List;
import it.DSMT.myTicket.dto.ActiveAuctionDTO;

public class ActiveAuctionListDTO {
    private List<ActiveAuctionDTO> auctions;

    public void setAuctions(List<ActiveAuctionDTO> auctions) {
        this.auctions = auctions;
    }

    public List<ActiveAuctionDTO> getAuctions() {
        return this.auctions;
    }
}
