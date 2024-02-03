package it.DSMT.myTicket.model;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class MasterNode {
    private final static String URL = "http://10.2.1.116:8082/auction";
    public static void sendAuction(int auctionID, int userID) throws RuntimeException {
        try {
            // URL del server Erlang
            URL url = new URL(URL);  // Sostituisci con il tuo endpoint Erlang

            // Apri una connessione HTTP
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();

            // Imposta il metodo di richiesta e l'impostazione per una richiesta di output
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);

            // Crea il corpo della richiesta
            String requestBody = String.format("{\"auctionID\": %d, \"userID\": %d}", auctionID, userID);

            // Scrivi il corpo della richiesta sulla connessione
            try (OutputStream os = connection.getOutputStream()) {
                byte[] input = requestBody.getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            // Leggi la risposta dal server Erlang
            int responseCode = connection.getResponseCode();
            System.out.println("HTTP Response Code: " + responseCode);

            if (responseCode != 200) {
                throw new RuntimeException("HTTP Response Code: " + responseCode);
            }

            // Puoi leggere la risposta dal server utilizzando connection.getInputStream() se necessario

            // Chiudi la connessione
            connection.disconnect();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

