#!/bin/bash

show_help() {
	echo "./update_beam.sh ip remote_path beam_file [port]"
	exit
}

IP=$1
REMOTE_PATH=$2
BEAMFILE=$3
PORT=$4

if [ -z $IP ]; then
    show_help
fi

if [ -z $REMOTE_PATH ]; then
    show_help
fi

if [ -z $BEAMFILE ]; then
    show_help
fi

if [ -z $PORT ]; then
    PORT=22
fi

cd $(dirname ${BASH_SOURCE})
cd ..

ROOT_PATH=`pwd`

scp -P $PORT ${ROOT_PATH}/ebin/$BEAMFILE.beam $IP:${REMOTE_PATH}/ebin/
ssh -p $PORT $IP "cd ${REMOTE_PATH}/script; bash load_beam.sh"

