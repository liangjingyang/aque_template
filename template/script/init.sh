#!/bin/bash

ulimit -SHn 1024000

APP_NAME=aque
APP_MOD=${APP_NAME}_app

COOKIE=${APP_NAME}_cookie

POLL=true
SMP=enable
ERL_MAX_PROCESSES=10240000
ERL_MAX_ETS_TABLES=102400
ERL_MAX_PORTS=1024000

export ERL_MAX_ETS_TABLES
export ERL_MAX_PORTS
