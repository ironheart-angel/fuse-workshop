#!/bin/bash

# Based on instructions from:
# https://access.redhat.com/documentation/en-us/red_hat_amq/7.7/html/deploying_amq_broker_on_openshift/deploying-broker-on-ocp-using-operator_broker-ocp#proc_br-deploying-operator_broker-ocp


cd `dirname $0`
BASE=`pwd`
cd - >> /dev/null

source ${BASE}/../config.sh

u=1 \
&& \
while [ $u -le $USERCOUNT ]; do
  echo "Creating project for user${u}..."
  myproj="labs-${u}"
  oc new-project $myproj
  oc policy add-role-to-user -n $myproj admin user${u}
  u=$(( $u + 1))
done

echo "Assigning permissions for ${AMQPROJ}..."
u=1 \
&& \
while [ $u -le $USERCOUNT ]; do
  oc policy add-role-to-user -n $AMQPROJ view user${u}
  u=$(( $u + 1))
done
