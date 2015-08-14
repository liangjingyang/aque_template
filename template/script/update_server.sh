#!/bin/bash

cd $(dirname ${BASH_SOURCE})
cd ..

IP=$1
REMOTE_PATH=$2

if [ -z $IP ]; then
    echo "no ip"
    exit
fi

if [ -z $REMOTE_PATH ]; then
    echo "no remote_path"
    exit
fi

PORT=$3
if [ -z $PORT ]; then
    PORT=22
fi

tar czf server.tar.gz config deps ebin script
ssh -p $PORT $IP "mkdir -p ${REMOTE_PATH}" 
scp -P $PORT server.tar.gz $IP:${REMOTE_PATH}/
ssh -p $PORT $IP "cd ${REMOTE_PATH}/; cp config/c_common.config .; cp ebin/server.app .; rm -rf config deps ebin script; tar xzf server.tar.gz; mv c_common.config config/; mv server.app ebin/; mv server.tar.gz server`date +%Y%m%d%H%M%S`.tar.gz; bash script/stop.sh; sleep 3; bash script/start.sh" 
