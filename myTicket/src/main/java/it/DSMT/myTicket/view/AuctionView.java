package it.DSMT.myTicket.view;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.rqlite.NodeUnavailableException;

import it.DSMT.myTicket.controller.AuctionController;
import it.DSMT.myTicket.dto.TicketDTO;
import it.DSMT.myTicket.model.Auction;
import it.DSMT.myTicket.model.Ticket;

@Controller
public class AuctionView {

    @PostMapping("/auction")
    public ResponseEntity<String> createAuction(@RequestBody Auction auction){
        try{
            AuctionController.createAuction(auction.getTicketID());
        } catch (NodeUnavailableException e){
            System.out.println("[AUCTION VIEW] Impossible to create auction");
            return new ResponseEntity<>("ERROR" , HttpStatus.INTERNAL_SERVER_ERROR);
        }
        return new ResponseEntity<>("Auction created!", HttpStatus.OK);
    }

    @DeleteMapping("/auction/{id_auction}")
    public ResponseEntity<String> deleteAuction(@PathVariable("id_auction") int idAuction){
        try{
            AuctionController.deleteAuction(idAuction);
        } catch (NodeUnavailableException e){
            System.out.println("[AUCTION VIEW] Impossible to remove auction");
            return new ResponseEntity<>("INTERNAL_SERVER_ERROR" , HttpStatus.INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
            System.out.println("[AUCTION VIEW] Impossible to remove auction because auction doesn't exists");
            return new ResponseEntity<>("NOT FOUND" , HttpStatus.NOT_FOUND);
        }
        return new ResponseEntity<>("Auction removed!", HttpStatus.OK);
    }

    @GetMapping("/auction/{id_auction}")
    public ResponseEntity<Auction> getOneAuction(@PathVariable("id_auction") int idAuction){
        Auction response = new Auction();
        try{
            response = AuctionController.getAuction(idAuction, false);
        } catch (NodeUnavailableException e){
            System.out.println("[AUCTION VIEW] Impossible to get auction");
            return new ResponseEntity<>(null , HttpStatus.INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
            System.out.println("[AUCTION VIEW] Impossible to get auction because auction doesn't exists");
            return new ResponseEntity<>(null , HttpStatus.NOT_FOUND);
        }
        return ResponseEntity.ok(response);
    }

    @GetMapping("/auction/ticket/{id_auction}")
    public ResponseEntity<Auction> getOneAuctionFromTicket(@PathVariable("id_auction") int idTicket){
        Auction response = new Auction();
        try{
            response = AuctionController.getAuction(idTicket, true);
        } catch (NodeUnavailableException e){
            System.out.println("[AUCTION VIEW] Impossible to get auction");
            return new ResponseEntity<>(null , HttpStatus.INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
            System.out.println("[AUCTION VIEW] Impossible to get auction because auction doesn't exists");
            return new ResponseEntity<>(null , HttpStatus.NOT_FOUND);
        }
        return ResponseEntity.ok(response);
    }

}
