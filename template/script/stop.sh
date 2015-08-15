#!/bin/bash

SCRIPT_PATH=`cd $(dirname ${BASH_SOURCE}); pwd`

ROOT_PATH=`cd ${SCRIPT_PATH}/..; pwd` 
NODE_NAME=`basename $ROOT_PATH`
cd ${SCRIPT_PATH}
source ${SCRIPT_PATH}/init.sh

erl -pa ${ROOT_PATH}/ebin ${ROOT_PATH}/deps/*/ebin \
    -name ${NODE_NAME}_stop@127.0.0.1 \
    -setcookie $COOKIE \
    -noinput \
    -root_path ${ROOT_PATH}/ \
    -remsh ${NODE_NAME}@127.0.0.1 \
    -eval "rpc:call('${NODE_NAME}@127.0.0.1', ${APP_MOD}, stop, []), [rpc:cast(Node, erlang, halt, [0])||Node<-nodes()], erlang:halt(0)"
