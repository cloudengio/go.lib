#!/bin/bash

remote=$1
command=./print-linux-cpp-defs.sh
rsync -av $command $remote:/tmp && ssh $remote bash /tmp/$command > ./linux-defines.txt
GOOS=linux go generate .
