#! /bin/bash

set -e

if sudo docker ps | grep "lapax/riak" >/dev/null; then
  echo ""
  echo "It looks like you already have some containers running."
  echo "Please take them down before attempting to bring up another"
  echo "cluster with the following command:"
  echo ""
  echo "  make stop-cluster"
  echo ""

  exit 1
fi

if [ -z "$1" ]
  then
    seqnum=5
else
  seqnum=$1
fi
if [ -z "$2" ]
  then
    datadir=`pwd`/data
else
    datadir=$2
fi

echo "starting a cluster with ${seqnum} nodes using ${datadir} for data"

mkdir -p ${datadir}

for index in `seq ${seqnum}`;
do
  sudo mkdir -p ${datadir}/riak${index}/{ring,testdir}
  sudo chmod 777 ${datadir}/riak${index}
  sudo chmod 777 ${datadir}/riak${index}/*
  if [ -z "$DOMAIN" ]; then
    HOSTNAME=riak${index} 
  else
    HOSTNAME=riak${index}.${DOMAIN}
  fi
  CONTAINER_ID=$(sudo docker run -d -t -i \
    -h "${HOSTNAME}" \
    -v ${datadir}/riak${index}:/var/lib/riak \
    --name "riak${index}" \
    "lapax/riak")

  sleep 1

  #sudo ./bin/pipework br1 ${CONTAINER_ID} "33.33.33.${index}0/24@33.33.33.1"
  hostip=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' riak${index})
  echo "Started [${HOSTNAME}] with assigned IP ${hostip}]"

  if [ "$index" -eq "1" ] ; then
    firsthostip=${hostip}
    FIRSTHOST=${HOSTNAME}
  #  sudo ifconfig br1 33.33.33.254
  #
  #  sleep 1
  fi

  until curl -s "http://${hostip}:8098/ping" | grep "OK" >/dev/null;
  do
    sleep 1
  done

  if [ "$index" -gt "1" ] ; then
    echo "Requesting that [riak${index}] join the cluster.."

    sshpass -p "basho" \
      ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" root@${hostip} \
        riak-admin cluster join riak@${FIRSTHOST}
  fi
done

sleep 1

sshpass -p "basho" \
  ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" root@${firsthostip} \
    riak-admin cluster plan

read -p "Commit these cluster changes? (y/n): " RESP
if [[ $RESP =~ ^[Yy]$ ]] ; then
  sshpass -p "basho" \
    ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" root@${firsthostip} \
      riak-admin cluster commit
else
  sshpass -p "basho" \
    ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" root@{firsthostip} \
      riak-admin cluster clear
fi
