#!/bin/bash

cd `dirname $0`
BASE=`pwd`
cd - >> /dev/null

docker run \
  --name workshopper \
  -it \
  --rm \
  -p 8080:8080 \
  -v ${BASE}/../workshop:/app-data \
  -e CONTENT_URL_PREFIX="file:///app-data" \
  -e WORKSHOPS_URLS="file:///app-data/_workshop.yml" \
  -e OPENSHIFT_API=https://api.test.example.com:6443 \
  -e OPENSHIFT_CONSOLE=http://console-openshift-console.apps.test.example.com \
  -e REST_CXFRS_URL=http://rest-cxfrs-service-enterprise-services.apps.test.example.com \
  -e TERMINAL_URL=http://terminal-server-labs-infra.apps.test.example.com \
  -e AMQ_BROKER_URL=http://amq-wconsj-0-svc-rte-enterprise-services.apps.test.example.com \
  -e AMQ_ADMIN_USER=amqadminusername \
  -e AMQ_ADMIN_PASSWORD=amqadminpassword \
  -e SUFFIX=apps.test.example.com \
  quay.io/openshiftlabs/workshopper:1.0
