#!/bin/bash

# Provisions the terminal template from the workshop-spawner:
# https://github.com/openshift-homeroom/workshop-spawner


cd `dirname $0`
BASE=`pwd`
cd - >> /dev/null

source ${BASE}/../config.sh

oc project $TERMPROJ || oc new-project $TERMPROJ

set -e

oc delete all -n $TERMPROJ --all

oc process \
  -f https://raw.githubusercontent.com/openshift-homeroom/workshop-spawner/develop/templates/terminal-server-production.json \
  --param SPAWNER_NAMESPACE=$TERMPROJ \
  --param CLUSTER_SUBDOMAIN=$(oc get route -n openshift-console console -o jsonpath='{.spec.host}' | sed -e 's/^[^.]*\.//') \
| \
oc apply -n $TERMPROJ -f -
