#!/bin/bash

cd $(dirname $0)

version="latest"
if [ -n "$1" ]; then
	version=$1
fi

docker build --tag idstudios/dcos-galera:$version .
