#!/bin/bash
cd $(dirname ${BASH_SOURCE})
cd ..

ROOT_PATH=`pwd`
NODE_NAME=`basename $ROOT_PATH`
cd $(dirname ${BASH_SOURCE})

COOKIE=cookie

erl -pa ${ROOT_PATH}/ebin ${ROOT_PATH}/deps/*/ebin \
    -noinput \
    -name ${NODE_NAME}_load_beam@127.0.0.1 \
    -setcookie $COOKIE \
    -root_path ${ROOT_PATH}/ \
    -remsh ${NODE_NAME}@127.0.0.1 \
    -eval "rpc:call('${NODE_NAME}@127.0.0.1', user_default, uu, []), rpc:call('${NODE_NAME}_load_beam@127.0.0.1', erlang, halt, [])"
