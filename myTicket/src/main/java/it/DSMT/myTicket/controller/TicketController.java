package it.DSMT.myTicket.controller;
import java.time.LocalDate;
import com.rqlite.NodeUnavailableException;

import it.DSMT.myTicket.dto.ActiveAuctionDTO;
import it.DSMT.myTicket.dto.ActiveTicketDTO;
import it.DSMT.myTicket.model.Auction;
import it.DSMT.myTicket.model.Ticket;
import java.util.List;

public class TicketController {

    public static void insertTicket(int ownerID, String title, LocalDate date, int hour, String city, String artist) throws NodeUnavailableException{
        Ticket ticket = new Ticket( ownerID, title, date, hour, city, artist);
        try{
            ticket.addTicket();
        } catch (NodeUnavailableException e){
            throw e;
        }
    }

    public static void deleteTicket(int ticketID) throws NodeUnavailableException, Exception{
        try{
            Ticket ticket = Ticket.getTicketFromID(ticketID);
            ticket.removeTicket();
        } catch (NodeUnavailableException e){
            throw e;
        } catch (Exception e){
            throw e;
        }
    }

    public static List<Ticket> searchTicket(String title) throws NodeUnavailableException{
        try{
            return Ticket.getMany(title);
        } catch (NodeUnavailableException e){
            throw e;
        }
    }

    public static List<ActiveTicketDTO> getActiveTickets() throws NodeUnavailableException, Exception{
        try{
            return Ticket.getActiveTickets();
        }catch (NodeUnavailableException e){
            throw e;
        }catch (Exception e){
            throw e;
        }
    }

    public static List<ActiveTicketDTO> getClosedTickets() throws NodeUnavailableException{
        try{
            return Ticket.getClosedTickets();
        }catch (NodeUnavailableException e){
            throw e;
        }
    }

    public static Ticket getOneTicket(int ticketID) throws NodeUnavailableException, Exception {
        try{
            Ticket ticket = Ticket.getTicketFromID(ticketID);
            return ticket;
        } catch (NodeUnavailableException e){
            throw e;
        } catch (Exception e){
            throw e;
        }
    }

    public static List<Ticket> getOwnedTicket(int ownerID) throws NodeUnavailableException, Exception {
        try{
            return Ticket.getTicketFromOwner(ownerID);
        } catch (NodeUnavailableException e){
            throw e;
        }catch (Exception e){
            throw e;
        }
    } 

    public static List<Ticket> getWinnedTicket(int userID) throws NodeUnavailableException, Exception {
        try{
            return Ticket.getWinnedTicket(userID);
        } catch (NodeUnavailableException e){
            throw e;
        } catch (Exception e){
            throw e;
        }
    } 
}
