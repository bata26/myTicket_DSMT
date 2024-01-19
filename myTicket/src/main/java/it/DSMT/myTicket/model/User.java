package it.DSMT.myTicket.model;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
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

    public int login() throws  NodeUnavailableException{
        QueryResults res = DbController.getInstance().getConnection().Query("SELECT * FROM user where username = '" + this.username + "' and password = '" + this.password + "'" , Rqlite.ReadConsistencyLevel.STRONG);
        System.out.println("RES : " + res.results[0]);

        if (res != null && res.results != null && res.results.length > 0) {
            QueryResults.Result result = res.results[0];
            if (result.error == null || result.error.isEmpty()) {
                if (result.values != null && result.values.length > 0 && result.values[0].length > 0) {
                    return User.getUserIDFromQueryResult(res);
                }
            }
        }

        return -1;
    }
    
    private static int getUserIDFromQueryResult(QueryResults res){
        Gson gson = new Gson();
        String json = gson.toJson(res);
        JsonObject jsonObject = gson.fromJson(json, JsonObject.class);
        int id = jsonObject.getAsJsonArray("results")
            .get(0).getAsJsonObject()
            .getAsJsonArray("values").get(0).getAsJsonArray().get(0).getAsInt();
        return id;
    }
}
