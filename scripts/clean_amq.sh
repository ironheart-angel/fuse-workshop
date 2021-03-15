#!/bin/bash

cd `dirname $0`
BASE=`pwd`
cd - >> /dev/null

source ${BASE}/../config.sh

oc delete -n $AMQPROJ activemqartemis/amq
oc delete -n $AMQPROJ subscription/amq-broker
oc delete -n $AMQPROJ svc/amq-broker-operator

if [ $(oc get clusterserviceversion -n $AMQPROJ -o name --no-headers 2>/dev/null | wc -l) -gt 0 ]; then
  oc delete -n $AMQPROJ $(oc get clusterserviceversion -n $AMQPROJ -o name --no-headers)
fi

if [ $(oc get operatorgroups -n $AMQPROJ -o name --no-headers 2>/dev/null | wc -l) -gt 0 ]; then
  oc delete -n $AMQPROJ $(oc get operatorgroups -n $AMQPROJ -o name --no-headers)
fi

exit 0
