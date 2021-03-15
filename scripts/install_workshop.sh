#!/bin/bash

# We have to customize the image because the original image
# (quay.io/openshiftlabs/workshopper:1.0) has problems with S2I on OpenShift
# (uid problems).

cd `dirname $0`
BASE=`pwd`
cd - >> /dev/null

source ${BASE}/../config.sh

function ensure_set {
	local varName="$1"
	if [ -z "${!varName}" ]; then
		echo "$varName is not set"
		exit 1
	fi
}

ensure_set WORKSHOPPROJ

oc project $WORKSHOPPROJ || oc new-project $WORKSHOPPROJ

set -e

OPENSHIFT_API=$(oc whoami --show-server)
OPENSHIFT_CONSOLE="http://$(oc get route -n openshift-console console -o jsonpath='{.spec.host}')"
REST_CXFRS_URL="http://$(oc get route rest-cxfrs-service -n $RESTPROJ -o jsonpath='{.spec.host}')"
TERMINAL_URL="http://$(oc get route terminal-server-spawner -n $TERMPROJ -o jsonpath='{.spec.host}')"
AMQ_BROKER_URL="http://$(oc get route amq-wconsj-0-svc-rte -n $AMQPROJ -o jsonpath='{.spec.host}')"
SUFFIX=$(oc get route -n openshift-console console -o jsonpath='{.spec.host}' | sed -e 's/^[^.]*\.//')


ensure_set OPENSHIFT_API
ensure_set OPENSHIFT_CONSOLE
ensure_set REST_CXFRS_URL
ensure_set TERMINAL_URL
ensure_set AMQ_BROKER_URL
ensure_set AMQADMINUSER
ensure_set AMQADMINPASSWORD
ensure_set SUFFIX

oc new-build \
  -n $WORKSHOPPROJ \
  --binary \
  --docker-image=quay.io/kwkoo/workshopper-uid:1.0 \
  --name=workshopper \
  --strategy=source

echo -n "Waiting for imagestream tag to appear..."
while [ $(oc get istag | grep workshopper-uid | wc -l) -lt 1 ]; do
  echo -n "."
  sleep 1
done
echo "done"

oc start-build workshopper -n $WORKSHOPPROJ --from-dir=${BASE}/../workshop --follow

oc new-app \
  -i workshopper \
  -e OPENSHIFT_API="${OPENSHIFT_API}" \
  -e OPENSHIFT_CONSOLE="${OPENSHIFT_CONSOLE}" \
  -e REST_CXFRS_URL="${REST_CXFRS_URL}" \
  -e TERMINAL_URL="${TERMINAL_URL}" \
  -e AMQ_BROKER_URL="${AMQ_BROKER_URL}" \
  -e AMQ_ADMIN_USER="${AMQADMINUSER}" \
  -e AMQ_ADMIN_PASSWORD="${AMQADMINPASSWORD}" \
  -e SUFFIX="${SUFFIX}"

oc expose -n $WORKSHOPPROJ svc/workshopper

echo "The lab instructions are now available at http://$(oc get route/workshopper -n $WORKSHOPPROJ -o jsonpath='{.spec.host}')"
