#!/bin/bash

cd $(dirname $0)
BASE=$(pwd)
cd - >> /dev/null

source ${BASE}/../config.sh

function ensure_set {
	local varName="$1"
	if [ -z "${!varName}" ]; then
		echo "$varName is not set"
		exit 1
	fi
}

ensure_set GAUPROJ
ensure_set USERCOUNT
ensure_set GAUACCESSTOKEN
ensure_set GAUADMINPASSWORD
ensure_set WORKSHOPPROJ
ensure_set TERMPROJ
ensure_set AMQPROJ

WORKSHOPPERROUTE="$(oc get -n $WORKSHOPPROJ route/workshopper -o jsonpath='{.spec.host}')"
ensure_set WORKSHOPPERROUTE

TERMROUTE="$(oc get route terminal-server-spawner -n $TERMPROJ -o jsonpath='{.spec.host}')"
ensure_set TERMROUTE

AMQROUTE="$(oc get route amq-wconsj-0-svc-rte -n $AMQPROJ -o jsonpath='{.spec.host}')"
ensure_set AMQROUTE

oc project $GAUPROJ || oc new-project $GAUPROJ

set -e

oc new-app \
  -n $GAUPROJ \
  --name=redis \
  --template=redis-persistent \
  -p MEMORY_LIMIT=1Gi \
  -p DATABASE_SERVICE_NAME=redis \
  -p REDIS_PASSWORD=redis \
  -p VOLUME_CAPACITY=1Gi \
  -p REDIS_VERSION=5

oc new-app \
  quay.io/openshiftlabs/username-distribution \
  -n $GAUPROJ \
  --name=get-a-username \
  -e LAB_REDIS_HOST=redis \
  -e LAB_REDIS_PASS=redis \
  -e LAB_TITLE="Fuse Workshop" \
  -e LAB_DURATION_HOURS=8h \
  -e LAB_USER_COUNT=$USERCOUNT \
  -e LAB_USER_ACCESS_TOKEN="$GAUACCESSTOKEN" \
  -e LAB_USER_PASS=openshift \
  -e LAB_USER_PREFIX=user \
  -e LAB_USER_PAD_ZERO=false \
  -e LAB_ADMIN_PASS="$GAUADMINPASSWORD" \
  -e LAB_MODULE_URLS="http://${WORKSHOPPERROUTE};PAM Workshop Labs" \
  -e LAB_EXTRA_URLS="http://$(oc get -n openshift-console route/console -o jsonpath='{.spec.host}');OpenShift Console,http://${TERMROUTE};Terminal Server,http://${AMQROUTE};AMQ Administration Interface"

oc expose -n $GAUPROJ svc/get-a-username
oc patch route/get-a-username -n $GAUPROJ -p '{"spec":{"tls":{"termination":"edge","insecureEdgeTerminationPolicy":"Allow"}}}'

echo "Username app is now available at http://$(oc get -n $GAUPROJ route/get-a-username -o jsonpath='{.spec.host}')"