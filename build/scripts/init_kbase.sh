#!/usr/bin/env bash

mysql_ready() {
    mysqladmin ping --host=localhost --user=root --password=root > /dev/null 2>&1
}

handle_service_ready() {
    curl -X GET http://localhost:7044
}

handle_manager_ready() {
    curl -X GET http://localhost:9001
}

# wait for mysql to start
while !(mysql_ready)
do
   sleep 1
   echo "waiting for mysql to start..."
done

# init the handle db
mysql --user=root --password=root < /opt/run/build/config/hsi.sql

source /kb/deployment/user-env.sh

# start handle service
cd /kb/deployment/services/handle_service
/kb/deployment/services/handle_service/start_service

while !(handle_service_ready)
do
    sleep 1
    echo "waiting for handle service to start..."
done

# start handle manager service
cd /kb/deployment/services/handle_mngr
/kb/deployment/services/handle_mngr/start_service

while !(handle_manager_ready)
do
    sleep 1
    echo "waiting for handle manager to start..."
done

# load workspace types here

# start workspace service
cd /kb/deployment/services/workspace
/kb/deployment/services/workspace/start_service
