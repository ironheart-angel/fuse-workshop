#!/bin/bash

# Based on instructions from:
# https://access.redhat.com/documentation/en-us/red_hat_amq/7.7/html/deploying_amq_broker_on_openshift/deploying-broker-on-ocp-using-operator_broker-ocp#proc_br-deploying-operator_broker-ocp


cd `dirname $0`
BASE=`pwd`
cd - >> /dev/null

source ${BASE}/../config.sh

oc project $AMQPROJ || oc new-project $AMQPROJ

set -e

cat <<EOF | oc create -n $AMQPROJ -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  generateName: enterprise-services-
spec:
  targetNamespaces:
  - $AMQPROJ
EOF

cat <<EOF | oc apply -n $AMQPROJ -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: amq-broker
spec:
  channel: current
  installPlanApproval: Automatic
  name: amq-broker
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: amq-broker-operator.v0.15.0
EOF

echo -n "Waiting for ClusterServiceVersion to be created..."
while [ $(oc get clusterserviceversion -n $AMQPROJ --no-headers 2>/dev/null | grep amq-broker | wc -l) -lt 1 ]; do
  echo -n "."
  sleep 1
done
echo "done"

echo -n "Waiting for artemis API to show up..."
while [ $(oc api-resources | grep activemqartemises | wc -l) -lt 1 ]; do
  echo -n "."
  sleep 1
done
echo "done"

cat <<EOF | oc create -n $AMQPROJ -f -
apiVersion: broker.amq.io/v2alpha2
kind: ActiveMQArtemis
metadata:
  name: amq
spec:
  acceptors:
  - name: my-acceptor
    port: 5672
    protocols: amqp
    expose: true
    connectionsAllowed: 20
  adminPassword: ${AMQADMINPASSWORD}
  adminUser: ${AMQADMINUSER}
  console:
    expose: true
  deploymentPlan:
    image: 'registry.redhat.io/amq7/amq-broker:7.7'
    journalType: nio
    messageMigration: false
    requireLogin: false
    size: 1
  upgrades:
    enabled: false
    minor: false
EOF

echo -n "Waiting for acceptor route to appear..."
while [ $(oc get -n $AMQPROJ route/amq-my-acceptor-0-svc-rte --no-headers 2>/dev/null | wc -l) -lt 1 ]; do
  echo -n "."
  sleep 1
done
echo "done"

oc delete -n $AMQPROJ route/amq-my-acceptor-0-svc-rte
