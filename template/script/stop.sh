#!/bin/bash

source init.sh

end() {
    erl -pa ${ROOT}/ebin ${ROOT}/deps/*/ebin \
        -name ${NODENAME}_stop@127.0.0.1 \
        -setcookie $COOKIE \
        -remsh ${NODENAME}@127.0.0.1 \
        -eval "rpc:call('${NODENAME}@127.0.0.1', ${APP_MOD}, stop, []), [rpc:cast(Node, erlang, halt, [0])||Node<-nodes()], erlang:halt(0)"
}

end
