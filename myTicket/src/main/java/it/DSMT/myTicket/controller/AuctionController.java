package it.DSMT.myTicket.controller;

import java.util.List;
import java.util.prefs.NodeChangeEvent;
import it.DSMT.myTicket.model.MasterNode;
import com.rqlite.NodeUnavailableException;
import it.DSMT.myTicket.dto.ActiveAuctionDTO;
import it.DSMT.myTicket.model.Auction;

public class AuctionController {

    public static int createAuction(int ticketID, int userID) throws NodeUnavailableException {
        Auction auction = new Auction(ticketID);
        int auctionID = -1;
        try {
            auctionID = auction.addAuction();
            MasterNode.sendAuction(auctionID, userID);
        } catch (NodeUnavailableException e) {
            throw e;
        } catch (RuntimeException e) {
            throw e;
        }
        return auctionID;
    }

    public static void deleteAuction(int auctionID) throws NodeUnavailableException, Exception {
        try {
            Auction auction = Auction.getOne(auctionID);
            auction.removeAuction();
        } catch (NodeUnavailableException e) {
            throw e;
        } catch (Exception e) {
            throw e;
        }
    }

    public static Auction getAuction(int id, boolean ticket) throws NodeUnavailableException, Exception {
        try {
            if (ticket == true) {
                System.out.println("TICKET");
                return Auction.getOneFromTicketID(id);
            } else {
                return Auction.getOne(id);
            }
        } catch (NodeUnavailableException e) {
            throw e;
        }
    }

    public static void closeAuction(int auctionID, int winnerID, int lastBid) throws NodeUnavailableException, Exception {
        try {
            Auction auction = Auction.getOne(auctionID);
            auction.closeAuction(winnerID, lastBid);
        } catch (NodeUnavailableException e) {
            throw e;
        } catch (Exception e) {
            throw e;
        }
    }

    public static String getAuctionHistory(int auctionID) throws RuntimeException{
        try{
            String res = MasterNode.getAuctionHistory(auctionID);
            String charsToRemove = "{";
            for (char c : charsToRemove.toCharArray()) {
                res = res.replace(String.valueOf(c), "");
            }
            charsToRemove = "}";
            for (char c : charsToRemove.toCharArray()) {
                res = res.replace(String.valueOf(c), "");
            }
            System.out.println("Response Body: " + res);
            return res;
        }catch(RuntimeException e){
            throw e;
        }
    }

}
