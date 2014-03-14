#! /bin/bash

set -e

if [ -z "$1" ]
  then
    seqnum=5
else
  seqnum=$1
fi

for index in `seq ${seqnum}`;
do
  echo "Testing [riak${index}]...`curl -s http://$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' riak${index}):8098/ping`"
done
