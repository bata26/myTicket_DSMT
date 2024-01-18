package it.DSMT.myTicket;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import it.DSMT.myTicket.controller.DbController;
//import it.DSMT.myTicket.controller.UserController;

@SpringBootApplication
public class MyTicketApplication {

	public static void main(String[] args) {
		DbController.getInstance();
		SpringApplication.run(MyTicketApplication.class, args);
	}

}
