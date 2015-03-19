#!/bin/bash

source init.sh

begin() {
    erl -pa ${ROOT}/ebin ${ROOT}/deps/*/ebin \
        -name ${NODENAME}@127.0.0.1 \
        -mnesia dump_log_write_threshold 100000 \
        -mnesia no_table_loaders 100 \
        -mnesia dir \"${ROOT}/ever_database\" \
        -config ${ROOT}/config/${APPNAME}.config \
        -s ${APP_MOD}
        #-detached \
}

begin
