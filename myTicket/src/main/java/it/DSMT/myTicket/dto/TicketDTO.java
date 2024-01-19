package it.DSMT.myTicket.dto;
import java.util.List;
import it.DSMT.myTicket.model.Ticket;

public class TicketDTO {
    private List<Ticket> tickets;

    public List<Ticket> getTickets() {
        return this.tickets;
    }

    public void setTickets(List<Ticket> tickets) {
        this.tickets = tickets;
    }
}