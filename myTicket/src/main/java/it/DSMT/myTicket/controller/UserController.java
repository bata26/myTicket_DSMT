package it.DSMT.myTicket.controller;
import com.rqlite.NodeUnavailableException;
import it.DSMT.myTicket.model.User;
import org.w3c.dom.Node;

public class UserController {

    public static void registerUser(String username, String password) throws NodeUnavailableException{
        User user = new User(username, password);
        try{
            user.register();
        } catch (NodeUnavailableException e){
            throw e;
        }
    }

    public static int loginUser(String username, String password) throws NodeUnavailableException{
        User user = new User(username, password);
        int userID = -1;
        try{
            userID = user.login();
        } catch (NodeUnavailableException e){
            throw e;
        }
        return userID;
    }

}