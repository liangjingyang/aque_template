#!/bin/bash

source init.sh

debug() {
    erl -pa ${ROOT}/ebin ${ROOT}/deps/*/ebin \
        -setcookie ${COOKIE} \
        -name ${NODENAME}_debug_${1}@127.0.0.1 \
        -remsh ${NODENAME}@127.0.0.1
}

source init.sh

NUM=1
if [ "$1" != '' ]; then
    NUM=$1
fi


debug ${NUM}

