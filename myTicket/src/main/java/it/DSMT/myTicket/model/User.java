package it.DSMT.myTicket.model;
import com.rqlite.NodeUnavailableException;
import it.DSMT.myTicket.controller.DbController;
import com.rqlite.Rqlite;
import com.rqlite.dto.QueryResults;

public class User {
    private String username;
    private String password;
    private int uuid;

    public User(String username, String password){
        this.username = username;
        this.password = password;
    }

    public String getUsername(){
        return this.username;
    }

    public String getPassword(){
        return this.password;
    }

    public void register() throws  NodeUnavailableException{
        DbController.getInstance().getConnection().Execute("INSERT INTO user(username, password) values( '" + this.username + "' , '" + this.password + "')");
    }

    public boolean login() throws  NodeUnavailableException{
        QueryResults res = DbController.getInstance().getConnection().Query("SELECT * FROM user where username = '" + this.username + "' and password = '" + this.password + "'" , Rqlite.ReadConsistencyLevel.STRONG);
        System.out.println("RES : " + res.results[0]);

        if (res != null && res.results != null && res.results.length > 0) {
            QueryResults.Result result = res.results[0];
            if (result.error == null || result.error.isEmpty()) {
                if (result.values != null && result.values.length > 0 && result.values[0].length > 0) {
                    return true;
                } else {
                }
            }
        }

        return false;
    }
}
