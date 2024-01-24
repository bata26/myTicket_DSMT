cd myTicketERL/worker_node/
./rebar3 compile
./rebar3 shell  --name worker@127.0.0.1 --setcookie master