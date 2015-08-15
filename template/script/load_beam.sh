#!/bin/bash

SCRIPT_PATH=`cd $(dirname ${BASH_SOURCE}); pwd`

ROOT_PATH=`cd ${SCRIPT_PATH}/..; pwd` 
NODE_NAME=`basename $ROOT_PATH`
cd ${SCRIPT_PATH}
source ${SCRIPT_PATH}/init.sh

erl -pa ${ROOT_PATH}/ebin ${ROOT_PATH}/deps/*/ebin \
    -noinput \
    -name ${NODE_NAME}_load_beam@127.0.0.1 \
    -setcookie $COOKIE \
    -root_path ${ROOT_PATH}/ \
    -remsh ${NODE_NAME}@127.0.0.1 \
    -eval "rpc:call('${NODE_NAME}@127.0.0.1', user_default, ul, []), rpc:call('${NODE_NAME}_load_beam@127.0.0.1', erlang, halt, [])"
