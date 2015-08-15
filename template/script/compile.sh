#!/bin/bash

SCRIPT_PATH=`cd $(dirname ${BASH_SOURCE}); pwd`

ROOT_PATH=`cd ${SCRIPT_PATH}/..; pwd` 
NODE_NAME=`basename $ROOT_PATH`
COOKIE=cookie

./rebar compile

erl -pa ${ROOT_PATH}/ebin ${ROOT_PATH}/deps/*/ebin \
    -noinput \
    -name ${NODE_NAME}_compile_config@127.0.0.1 \
    -setcookie $COOKIE \
    -root_path ${ROOT_PATH}/ \
    -remsh ${NODE_NAME}@127.0.0.1 \
    -eval "rpc:call('${NODE_NAME}@127.0.0.1', config_dyn, gen_all_beam, []), rpc:call('${NODE_NAME}_compile_config@127.0.0.1', erlang, halt, [])"
