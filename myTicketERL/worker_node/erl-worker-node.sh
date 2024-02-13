#cd myTicketERL/worker_node/
#./rebar3 compile
./rebar3 shell --name worker@10.2.1.117 --setcookie master
