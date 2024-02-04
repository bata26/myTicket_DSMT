package it.DSMT.myTicket.model;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.InputStream;


public class MasterNode {
    private final static String URL = "http://10.2.1.116:8082/auction";
    private final static String AUCTION_HISTORY_URL = "http://10.2.1.116:8082/auction/history";
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

    public static String getAuctionHistory(int auctionID) throws RuntimeException {
        try {
            // URL del server Erlang
            URL url = new URL(AUCTION_HISTORY_URL);  // Sostituisci con il tuo endpoint Erlang

            // Apri una connessione HTTP
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();

            // Imposta il metodo di richiesta e l'impostazione per una richiesta di output
            connection.setRequestMethod("GET");
            connection.setDoOutput(true);

            // Crea il corpo della richiesta
            String requestBody = String.format("{\"auctionID\": %d}", auctionID);
            System.out.println("REQ BODY : " + requestBody);
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
            
            StringBuilder response = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()))) {
                String line;

                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
            } finally {
                // Chiudere la connessione
                connection.disconnect();
             }
            // Stampare o elaborare il corpo della risposta qui
            System.out.println("Response Body: " + response.toString());
            return response.toString();
            // Puoi leggere la risposta dal server utilizzando connection.getInputStream() se necessario

        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }
}

