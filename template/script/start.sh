#!/bin/bash

SCRIPT_PATH=`cd $(dirname ${BASH_SOURCE}); pwd`

ROOT_PATH=`cd ${SCRIPT_PATH}/..; pwd` 
NODE_NAME=`basename $ROOT_PATH`
cd ${SCRIPT_PATH}
source ${SCRIPT_PATH}/init.sh


erl +P $ERL_MAX_PROCESSES \
    +K $POLL \
    -smp $SMP \
    -detached \
    -pa ${ROOT_PATH}/ebin ${ROOT_PATH}/deps/*/ebin \
    -name ${NODE_NAME}@127.0.0.1 \
    -setcookie $COOKIE \
    -config ${ROOT_PATH}/config/${APP_NAME}.config \
    -root_path ${ROOT_PATH}/ \
    -s $APP_MOD
    #-mnesia dump_log_write_threshold 100000 \
    #-mnesia no_table_loaders 100 \
    #-mnesia dir \"$ROOT_PATH/croods_data\" \
