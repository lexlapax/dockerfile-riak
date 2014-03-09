#!/bin/bash

sed -i.bak 's/127.0.0.1/0.0.0.0/' /etc/riak/app.config

# switch to leveldb as the riak backend
sed -i -e s/riak_kv_bitcask_backend/riak_kv_eleveldb_backend/g /etc/riak/app.config
# enable search. the sed command below only replaces the first line it matches
sed -i -e 0,/"enabled, false"/{s/"enabled, false"/"enabled, true"/} /etc/riak/app.config

# enable admin panel. replaces the second line it matches
sed -i -e 1,/"enabled, false"/{s/"enabled, false"/"enabled, true"/} /etc/riak/app.config
# enable ssl for admin panel
sed -i.bak 's/%{https, .\+,/{https, [{ "0.0.0.0", 8069 } ]},/' /etc/riak/app.config
sed -i.bak 's/%{ssl,.\+/{ssl, [/' /etc/riak/app.config
sed -i.bak 's/%\(.\+{certfile, .\+\)/\1/' /etc/riak/app.config
sed -i.bak '/%.\+{keyfile, .*/ {N; s/%\(.\+keyfile, .\+pem"\}\)\n\(.\+\)%\(.\+\)\]\},/\1\n\2\3]},/g}' /etc/riak/app.config


#change the admin user
sed -i.bak 's/"user", "pass"/"admin", "adminpass"/' /etc/riak/app.config

echo "sed -i.bak \"s/-name riak@.\+/-name riak@\$(ip addr show eth0 scope global primary|grep inet|awk '{print \$2}'|awk -F'/' '{print \$1}')/\" /etc/riak/vm.args" > /etc/default/riak
echo "ulimit -n 4096" >> /etc/default/riak
