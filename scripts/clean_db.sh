#!/bin/bash

cd `dirname $0`
BASE=`pwd`
cd - >> /dev/null

source ${BASE}/../config.sh

oc delete -n $DBPROJ all -l app=postgresql
oc delete -n $DBPROJ pvc/postgresql
oc delete -n $DBPROJ secret/postgresql

exit 0
