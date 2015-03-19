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

# script init.sh
sed -i "s/APPNAME=.*/APPNAME=${APPNAME}/g" init.sh

# aque.app.src
sed -i "s/aque/${APPNAME}/g" ../src/aque.app.src
mv ../src/aque.app.src ../src/${APPNAME}.app.src

# rename and replace -module(xxx).
# aque_app.erl
sed -i "s/aque/${APPNAME}/g" ../src/aque_app.erl
mv ../src/aque_app.erl ../src/${APPNAME}_app.erl

# aque_sup.erl
sed -i "s/aque/${APPNAME}/g" ../src/aque_sup.erl
mv ../src/aque_sup.erl ../src/${APPNAME}_sup.erl

# aque_server.erl
sed -i "s/aque/${APPNAME}/g" ../src/aque_server.erl
mv ../src/aque_server.erl ../src/${APPNAME}_server.erl

rm -rf ../.git
mkdir ../log ../include ../config

echo DONE!
