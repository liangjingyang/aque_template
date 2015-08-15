#!/bin/bash

SCRIPT_PATH=`cd $(dirname ${BASH_SOURCE}); pwd`

ROOT_PATH=`cd ${SCRIPT_PATH}/..; pwd` 
cd ${ROOT_PATH}

PID_FILE=${ROOT_PATH}/server.pid

if [ -f ${PID_FILE} ]; then
    kill -15 `cat ${PID_FILE}`
else
    echo "no file server.pid"
fi
