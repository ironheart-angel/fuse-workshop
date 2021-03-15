#!/bin/bash

cd `dirname $0`
BASE=`pwd`
cd - >> /dev/null

source ${BASE}/../config.sh

oc delete all -n $GAUPROJ -l app=redis
oc delete all -n $GAUPROJ -l app=get-a-username
oc delete -n $GAUPROJ secret/redis
oc delete -n $GAUPROJ pvc/redis

exit 0
