#!/bin/bash

# Create a postgresql database, then creates users starting from user1 up to
# the number of users given. The password for each user is openshift.
#
# A database is also created for each user.
#
# Once provisioned, the database will be available at:
# postgresql.database.svc.cluster.local
#
# To connect to the user1 database as user1,
# psql --host=postgresql.database.svc.cluster.local user1 user1

cd `dirname $0`
BASE=`pwd`
cd - >> /dev/null

source ${BASE}/../config.sh

oc project $DBPROJ || oc new-project $DBPROJ

set -e

oc new-app \
  -n $DBPROJ \
  --name=postgresql \
  --template=postgresql-persistent \
  -p POSTGRESQL_USER=${DBADMINUSER} \
  -p POSTGRESQL_PASSWORD=${DBADMINPASSWORD}

sleep 5
POSTGRESPOD=$(oc get po -n $DBPROJ -l name=postgresql -o name --no-headers)

echo "Waiting for pod to be ready..."
oc wait -n $DBPROJ --for=condition=ready --timeout=120s $POSTGRESPOD 

echo "Creating users and databases..."
u=1 \
&& \
while [ $u -le $USERCOUNT ]; do
  echo "Creating user${u}..."
  oc rsh -n $DBPROJ $POSTGRESPOD createdb -O postgresql user${u}
  oc rsh -n $DBPROJ $POSTGRESPOD psql --command="CREATE USER user${u} WITH ENCRYPTED PASSWORD 'openshift';GRANT ALL PRIVILEGES ON DATABASE user${u} to user${u};" user${u}
  oc rsh -n $DBPROJ $POSTGRESPOD psql --command="CREATE SCHEMA USECASE;CREATE TABLE USECASE.T_ACCOUNT (id  SERIAL PRIMARY KEY,CLIENT_ID integer,SALES_CONTACT VARCHAR(30),COMPANY_NAME VARCHAR(50),COMPANY_GEO CHAR(20) ,COMPANY_ACTIVE BOOLEAN,CONTACT_FIRST_NAME VARCHAR(35),CONTACT_LAST_NAME VARCHAR(35),CONTACT_ADDRESS VARCHAR(255),CONTACT_CITY VARCHAR(40),CONTACT_STATE VARCHAR(40),CONTACT_ZIP VARCHAR(10),CONTACT_EMAIL VARCHAR(60),CONTACT_PHONE VARCHAR(35),CREATION_DATE TIMESTAMP,CREATION_USER VARCHAR(255));" user${u} user${u}
  u=$(( $u + 1))
done