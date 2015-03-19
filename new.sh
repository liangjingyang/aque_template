#!/bin/bash


show_help() {
    echo "./new_app.sh app_name"
    exit 1
}

if [ "$1" != '' ]; then
    APPNAME=$1
else
    show_help
fi


cp -ar template ${APPNAME}

# script init.sh
sed -i "s/APPNAME=.*/APPNAME=${APPNAME}/g" ${APPNAME}/script/init.sh

# aque.app.src
sed -i "s/aque/${APPNAME}/g" ${APPNAME}/src/aque.app.src
mv ${APPNAME}/src/aque.app.src ${APPNAME}/src/${APPNAME}.app.src

# rename and replace -module(xxx).
# aque_app.erl
sed -i "s/aque/${APPNAME}/g" ${APPNAME}/src/aque_app.erl
mv ${APPNAME}/src/aque_app.erl ${APPNAME}/src/${APPNAME}_app.erl

# aque_sup.erl
sed -i "s/aque/${APPNAME}/g" ${APPNAME}/src/aque_sup.erl
mv ${APPNAME}/src/aque_sup.erl ${APPNAME}/src/${APPNAME}_sup.erl

# aque_server.erl
sed -i "s/aque/${APPNAME}/g" ${APPNAME}/src/aque_server.erl
mv ${APPNAME}/src/aque_server.erl ${APPNAME}/src/${APPNAME}_server.erl

mkdir ${APPNAME}/log ${APPNAME}/include ${APPNAME}/config

echo DONE!
