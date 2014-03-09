#! /bin/bash

set -e

for index in `seq 5`;
do
  echo "Testing [riak${index}]...`curl -s http://$(sudo docker inspect -format '{{ .NetworkSettings.IPAddress }}' riak${index}):8098/ping`"
done
