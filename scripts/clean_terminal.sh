#!/bin/bash

cd `dirname $0`
BASE=`pwd`
cd - >> /dev/null

source ${BASE}/../config.sh

oc delete -n $TERMPROJ all -l app=terminal-server
oc delete -n $TERMPROJ sa/terminal-server-spawner
oc delete -n $TERMPROJ pvc/terminal-server-spawner-data
oc delete -n $TERMPROJ cm/terminal-server-session-envvars
oc delete -n $TERMPROJ cm/terminal-server-spawner-configs

if [ $(oc get -n $TERMPROJ secrets 2>/dev/null | grep terminal-server | wc -l ) -gt 0 ]; then
  for s in $(oc get -n $TERMPROJ secrets -o name --no-headers | grep terminal-server); do
    oc delete -n $TERMPROJ $s
  done
fi

exit 0
