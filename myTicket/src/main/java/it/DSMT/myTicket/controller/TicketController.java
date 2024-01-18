package it.DSMT.myTicket.controller;

import java.util.Date;

import com.rqlite.NodeUnavailableException;

import it.DSMT.myTicket.model.Ticket;

public class TicketController {

    public static void insertTicket(int ownerID, String title, Date date, int hour, String city) throws NodeUnavailableException{
        Ticket ticket = new Ticket( ownerID, title, date, hour, city);
        try{
            ticket.addTicket();
        } catch (NodeUnavailableException e){
            throw e;
        }
    }

    public static void deleteTicket(int ticketID) throws NodeUnavailableException{
        try{
            Ticket.getTicketFromID(ticketID);
        } catch (NodeUnavailableException e){
            throw e;
        }
    }

}
