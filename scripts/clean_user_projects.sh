#!/bin/bash

cd `dirname $0`
BASE=`pwd`
cd - >> /dev/null

source ${BASE}/../config.sh

oc project default

u=1 \
&& \
while [ $u -le $USERCOUNT ]; do
  oc delete project labs-user${u}
  u=$(( $u + 1))
done

exit 0
