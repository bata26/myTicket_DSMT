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

    public static boolean loginUser(String username, String password) throws NodeUnavailableException{
        User user = new User(username, password);
        boolean loginResult = false;
        try{
            loginResult =  user.login();
        } catch (NodeUnavailableException e){
            throw e;
        }
        return loginResult;
    }

}