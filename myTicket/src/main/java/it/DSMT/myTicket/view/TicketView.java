package it.DSMT.myTicket.view;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.stereotype.Controller;

import com.rqlite.NodeUnavailableException;

import it.DSMT.myTicket.controller.TicketController;
import it.DSMT.myTicket.model.Ticket;
import it.DSMT.myTicket.dto.TicketDTO;

@Controller
public class TicketView {
    @PostMapping("/ticket")
    @ResponseBody
    public ResponseEntity<String> register(@RequestBody Ticket ticket){
        try{
            TicketController.insertTicket(ticket.getOwnerID(), ticket.getTitle() ,ticket.getDate() ,ticket.getHour() ,ticket.getCity(), ticket.getArtist());
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
            System.out.println("[TICKET VIEW] Impossible to remove ticket");
            return new ResponseEntity<>("INTERNAL_SERVER_ERROR" , HttpStatus.INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
            System.out.println("[TICKET VIEW] Impossible to remove ticket because ticket doesn't exists");
            return new ResponseEntity<>("NOT FOUND" , HttpStatus.NOT_FOUND);
        }
        return new ResponseEntity<>("Ticket removed!", HttpStatus.OK);
    }

    @GetMapping("/ticket")
    public ResponseEntity<TicketDTO> searchTicket(@RequestParam String title){
        TicketDTO response = new TicketDTO();
        try{
            response.setTickets(TicketController.searchTicket(title));
        } catch (NodeUnavailableException e){
            System.out.println("[TICKET VIEW] Impossible to remove ticket");
            return new ResponseEntity(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
        return ResponseEntity.ok(response);
    }

    @GetMapping("/tickets")
    public ResponseEntity<TicketDTO> getAllTicket(){
        TicketDTO response = new TicketDTO();
        try{
            response.setTickets(TicketController.searchTicket(""));
        } catch (NodeUnavailableException e){
            System.out.println("[TICKET VIEW] Impossible to remove ticket");
            return new ResponseEntity(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
        return ResponseEntity.ok(response);
    }
}
