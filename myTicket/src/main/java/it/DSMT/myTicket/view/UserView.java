package it.DSMT.myTicket.view;
import com.rqlite.NodeUnavailableException;
import it.DSMT.myTicket.model.User;
import org.springframework.stereotype.Controller;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import it.DSMT.myTicket.controller.UserController;
import it.DSMT.myTicket.dto.LoginDTO;

import org.springframework.http.HttpStatus;

@Controller
public class UserView {

    @PostMapping("/register")
    @ResponseBody
    public ResponseEntity<String> register(@RequestBody User user){
        try{
            UserController.registerUser(user.getUsername(), user.getPassword());
        } catch (NodeUnavailableException e){
            System.out.println("[USER CONTROLLER] Impossible to register user");
            return new ResponseEntity<>("ERROR" , HttpStatus.INTERNAL_SERVER_ERROR);
        }
        return new ResponseEntity<>("Registered USer", HttpStatus.OK);
    }

    @PostMapping("/login")
    @ResponseBody
    public ResponseEntity<LoginDTO> login(@RequestBody User user){
        LoginDTO login = new LoginDTO();
        try{
            int userID;
            userID = UserController.loginUser(user.getUsername(), user.getPassword());
            login.setUserID(userID);
            if (userID != -1){
                return ResponseEntity.ok(login);
            }else{
                return new ResponseEntity(null , HttpStatus.UNAUTHORIZED);
            }
        } catch (NodeUnavailableException e){
            System.out.println("[USER CONTROLLER] Impossible to login");
            return new ResponseEntity(null , HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

}