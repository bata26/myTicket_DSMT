cd /root/rqlite-v8.19.0-linux-amd64
./rqlited -node-id 2 -http-addr 10.2.1.117:4001 -raft-addr 10.2.1.117:4002 -join 10.2.1.116:4002 data/