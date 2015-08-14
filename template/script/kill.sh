#!/bin/bash

cd $(dirname ${BASH_SOURCE})
cd ..

ROOT_PATH=`pwd`

PID_FILE=${ROOT_PATH}/server.pid

if [ -f ${PID_FILE} ]; then
    kill -15 `cat ${PID_FILE}`
else
    echo "no file server.pid"
fi
