#!/bin/bash

cd `dirname $0`
BASE=`pwd`
cd - >> /dev/null

source ${BASE}/../config.sh

oc delete all -n $RESTPROJ -l app=rest-cxfrs-service
