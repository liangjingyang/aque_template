#!/bin/bash

SCRIPT_PATH=`cd $(dirname ${BASH_SOURCE}); pwd`

ROOT_PATH=`cd ${SCRIPT_PATH}/..; pwd` 
NODE_NAME=`basename $ROOT_PATH`
cd ${SCRIPT_PATH}
source ${SCRIPT_PATH}/init.sh

NUM=1
if [ "$1" != '' ]; then
    NUM=$1
fi

erl -pa ${ROOT_PATH}/ebin ${ROOT_PATH}/deps/*/ebin \
    -name ${NODE_NAME}_debug_$NUM@127.0.0.1 \
    -setcookie $COOKIE \
    -root_path ${ROOT_PATH}/ \
    -remsh ${NODE_NAME}@127.0.0.1
