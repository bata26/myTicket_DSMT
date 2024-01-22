package it.DSMT.myTicket;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import it.DSMT.myTicket.controller.DbController;
import com.ericsson.otp.erlang.*;
//import it.DSMT.myTicket.controller.UserController;

@SpringBootApplication
public class MyTicketApplication {

	public static void main(String[] args) {

		System.setProperty("OtpConnection.trace", "5");
		try {
			// Configura il nodo Java
			OtpNode self = new OtpNode("java_node", "master");
			if (self.ping("master@127.0.0.1", 2000)) {
				System.out.println("Master Node Correctly pinged");
			} else {
				return;
			}
			OtpMbox mbox = self.createMbox();
			OtpErlangPid mboxPid = mbox.self();
			mbox.registerName("master_node");
			OtpErlangObject[] msgArray = new OtpErlangObject[] {
					mboxPid,
					new OtpErlangAtom("java_node")
					//new OtpErlangString("Hello from Java!")
			};
			OtpErlangTuple tuple = new OtpErlangTuple(msgArray);
			System.out.println("TUPLE : " + tuple);
			mbox.send( "master_node","master@127.0.0.1", tuple);
		} catch (Exception e) {
			e.printStackTrace();
		}
		DbController.getInstance();
		SpringApplication.run(MyTicketApplication.class, args);
	}

}
