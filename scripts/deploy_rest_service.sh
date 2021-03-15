#!/bin/bash

# Deploys the REST CXF-RS Service in lab 2 from:
# https://gitlab.com/redhatsummitlabs/agile-integration-for-the-enterprise.git
#
# Lab instructions are at:
# https://gitlab.com/redhatsummitlabs/agile-integration-for-the-enterprise/-/blob/master/2a_REST_Enrich_Application.adoc

cd `dirname $0`
BASE=`pwd`
cd - >> /dev/null

source ${BASE}/../config.sh

oc project $RESTPROJ || oc new-project $RESTPROJ

set -e

oc new-app \
  -n $RESTPROJ \
  --name rest-cxfrs-service \
  --context-dir=labs/lab02/01_rest-cxfrs-service \
  java:8~https://gitlab.com/redhatsummitlabs/agile-integration-for-the-enterprise.git

sleep 5
oc logs -n $RESTPROJ -f bc/rest-cxfrs-service

oc expose -n $RESTPROJ svc/rest-cxfrs-service

# The service should now be accessible at:
# http://rest-cxfrs-service-enterprise-services.apps.cluster-XXXX.XXXX.example.opentlc.com/rest/customerservice/enrich
