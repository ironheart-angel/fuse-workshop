#!/bin/bash

cd `dirname $0`
BASE=`pwd`
cd - >> /dev/null

source ${BASE}/../config.sh

oc delete -n $WORKSHOPPROJ all -l app=workshopper
oc delete -n $WORKSHOPPROJ istag/workshopper:latest
oc delete -n $WORKSHOPPROJ istag/workshopper-uid:1.0
oc delete -n $WORKSHOPPROJ is/workshopper
oc delete -n $WORKSHOPPROJ is/workshopper-uid
oc delete -n $WORKSHOPPROJ bc/workshopper

if [ $(oc get -n $WORKSHOPPROJ cm | grep workshopper | wc -l) -gt 0 ]; then
  for c in $(oc get -n $WORKSHOPPROJ cm -o name --no-headers | grep workshopper); do
    oc delete -n $WORKSHOPPROJ $c
  done
fi

exit 0
