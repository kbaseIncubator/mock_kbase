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

# init the mongo admin user
mongo < /opt/run/build/scripts/mongo_users.js

# start shock service
supervisorctl start shock-server

# init the handle db
mysql --user=root --password=root < /opt/run/build/config/hsi.sql

source /kb/deployment/user-env.sh

# copy credentials into service configs
sed -i 's/kbaseuserid/'"$KB_USER"'/g' /kb/deployment/deployment.cfg
sed -i 's/kbasepasswd/'"$KB_PASS"'/g' /kb/deployment/deployment.cfg

# proxy to specific instance of catalog service
sed -i 's/kbaseinstance/'"$KB_INSTANCE"'/g' /etc/nginx/sites-enabled/default

# start handle service
cd /kb/deployment/services/handle_service
supervisorctl start handle-service

while !(handle_service_ready)
do
    sleep 1
    echo "waiting for handle service to start..."
done

# start handle manager service
cd /kb/deployment/services/handle_mngr
supervisorctl start handle-manager-service

while !(handle_manager_ready)
do
    sleep 1
    echo "waiting for handle manager to start..."
done

echo "loading workspace types..."
# load workspace types here
cd /tmp
curl ftp://dtn.chicago.kbase.us/mongo/workspace_types-latest.tar.gz|tar xzf -
mongorestore --host localhost --db wstypes ./workspace_types/

mongo < /opt/run/build/scripts/mongo_init_workspace.js

echo "starting workspace service..."
# start workspace service
cd /kb/deployment/services/workspace
supervisorctl start workspace-service

echo "starting nginx..."
supervisorctl start nginx