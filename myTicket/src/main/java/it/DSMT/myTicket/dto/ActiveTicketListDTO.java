package it.DSMT.myTicket.dto;

import java.util.List;

public class ActiveTicketListDTO {
    private List<ActiveTicketDTO> tickets;

    public void setTickets(List<ActiveTicketDTO> tickets) {
        this.tickets = tickets;
    }

    public List<ActiveTicketDTO> getTickets() {
        return this.tickets;
    }
}
