package it.DSMT.myTicket.controller;
import java.util.List;

import com.rqlite.NodeUnavailableException;
import it.DSMT.myTicket.model.Auction;
public class AuctionController {

    public static void createAuction(int ticketID) throws NodeUnavailableException{
        Auction auction = new Auction( ticketID);
        try{
            auction.addAuction();
        } catch (NodeUnavailableException e){
            throw e;
        }
    }

    public static void deleteAuction(int auctionID) throws NodeUnavailableException, Exception{
        try{
            Auction auction = Auction.getOne(auctionID);
            auction.removeAuction();
        } catch (NodeUnavailableException e){
            throw e;
        } catch (Exception e){
            throw e;
        }
    }

    public static Auction getAuction(int id, boolean ticket) throws NodeUnavailableException, Exception{
        try{
            if (ticket == true) {
                System.out.println("TICKET");
                return Auction.getOneFromTicketID(id);
            }else{
                return Auction.getOne(id);
            }
        } catch (NodeUnavailableException e){
            throw e;
        }
    }

}
