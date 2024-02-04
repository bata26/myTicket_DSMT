package it.DSMT.myTicket.view;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import com.rqlite.NodeUnavailableException;

import it.DSMT.myTicket.controller.AuctionController;
import it.DSMT.myTicket.dto.CloseAuctionDTO;
import it.DSMT.myTicket.dto.CreateAuctionDTO;
import it.DSMT.myTicket.dto.CreatedAuctionDTO;
import it.DSMT.myTicket.model.Auction;

@Controller
public class AuctionView {  

    @PostMapping("/auction")
    public ResponseEntity<CreatedAuctionDTO> createAuction(@RequestBody CreateAuctionDTO auction){
        CreatedAuctionDTO response = new CreatedAuctionDTO();
        try{
            System.out.println("TicketID: " + auction.getTicketID());
            response.setAuctionID(AuctionController.createAuction(auction.getTicketID(), auction.getUserID()));
        } catch (NodeUnavailableException e){
            System.out.println("[AUCTION VIEW] Impossible to create auction");
            return new ResponseEntity(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
        return ResponseEntity.ok(response);
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

    @GetMapping("/auction/ticket/{id_ticket}")
    public ResponseEntity<Auction> getOneAuctionFromTicket(@PathVariable("id_ticket") int idTicket){
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


    @PostMapping("/close/auction")
    public ResponseEntity<String> closeAuction(@RequestBody CloseAuctionDTO auction){
        try{
            AuctionController.closeAuction(auction.getAuctionID(),auction.getWinnerID(),auction.getLastBid());
        } catch (NodeUnavailableException e){
            System.out.println("[AUCTION VIEW] Impossible to close auction");
            return new ResponseEntity<>("INTERNAL_SERVER_ERROR" , HttpStatus.INTERNAL_SERVER_ERROR);
        } catch (Exception e){
        System.out.println("[AUCTION VIEW] Impossible to close auction");
            return new ResponseEntity<>("NOT_FOUNT" , HttpStatus.NOT_FOUND);

        }
        return new ResponseEntity<>("Auction closed!", HttpStatus.OK);
    }

    @GetMapping("/auction/history/{auction_id}")
    public ResponseEntity<String> getAuctionHistory(@PathVariable("auction_id") int auctionID){
        String result = "";
        try{
            result = AuctionController.getAuctionHistory(auctionID);
        } catch (Exception e){
        System.out.println("[AUCTION VIEW] Impossible to get auction history");
            return new ResponseEntity<>("NOT_FOUNT" , HttpStatus.NOT_FOUND);

        }
        System.out.println("RESULT " + result);
        return new ResponseEntity<>(result, HttpStatus.OK);
    }
}
