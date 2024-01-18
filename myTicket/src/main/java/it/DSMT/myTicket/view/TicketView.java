package it.DSMT.myTicket.view;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.stereotype.Controller;

import com.rqlite.NodeUnavailableException;

import it.DSMT.myTicket.controller.TicketController;
import it.DSMT.myTicket.model.Ticket;

@Controller
public class TicketView {
    @PostMapping("/ticket")
    @ResponseBody
    public ResponseEntity<String> register(@RequestBody Ticket ticket){
        try{
            TicketController.insertTicket(ticket.getOwnerID(), ticket.getTitle() ,ticket.getDate() ,ticket.getHour() ,ticket.getCity());
        } catch (NodeUnavailableException e){
            System.out.println("[TICKET VIEW] Impossible to add ticket");
            return new ResponseEntity<>("ERROR" , HttpStatus.INTERNAL_SERVER_ERROR);
        }
        return new ResponseEntity<>("Ticket added!", HttpStatus.OK);
    }

    @DeleteMapping("/ticket/{id_ticket}")
    public ResponseEntity<String> delete(@PathVariable("id_ticket") int idTicket){
        try{
            TicketController.deleteTicket(idTicket);
        } catch (NodeUnavailableException e){
            System.out.println("[TICKET VIEW] Impossible to add ticket");
            return new ResponseEntity<>("ERROR" , HttpStatus.INTERNAL_SERVER_ERROR);
        }
        return new ResponseEntity<>("Ticket added!", HttpStatus.OK);
    }
}
