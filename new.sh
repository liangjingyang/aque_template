#!/bin/bash


show_help() {
    echo "./new_app.sh app_name"
    exit 1
}

if [ "$1" != '' ]; then
    APP_NAME=$1
else
    show_help
fi

if [ -d ${APP_NAME} ]; then
    echo "Error: Dir ${APP_NAME} already exsits!"
    exit 1
fi


cp -ar template ${APP_NAME}

# script init.sh
sed -i "s/APP_NAME=.*/APP_NAME=${APP_NAME}/g" ${APP_NAME}/script/init.sh

# aque.app.src
sed -i "s/aque/${APP_NAME}/g" ${APP_NAME}/src/aque.app.src
mv ${APP_NAME}/src/aque.app.src ${APP_NAME}/src/${APP_NAME}.app.src

# app.hrl
sed -i "s/aque/${APP_NAME}/g" ${APP_NAME}/include/app.hrl

# rename and replace -module(xxx).
# aque_app.erl
sed -i "s/aque/${APP_NAME}/g" ${APP_NAME}/src/aque_app.erl
mv ${APP_NAME}/src/aque_app.erl ${APP_NAME}/src/${APP_NAME}_app.erl

# aque_sup.erl
sed -i "s/aque/${APP_NAME}/g" ${APP_NAME}/src/aque_sup.erl
mv ${APP_NAME}/src/aque_sup.erl ${APP_NAME}/src/${APP_NAME}_sup.erl

# aque_server.erl
sed -i "s/aque/${APP_NAME}/g" ${APP_NAME}/src/aque_server.erl
mv ${APP_NAME}/src/aque_server.erl ${APP_NAME}/src/${APP_NAME}_server.erl

# config/aque.config
sed -i "s/aque/${APP_NAME}/g" ${APP_NAME}/config/aque.config
mv ${APP_NAME}/config/aque.config ${APP_NAME}/config/${APP_NAME}.config

mkdir ${APP_NAME}/log

echo DONE!
