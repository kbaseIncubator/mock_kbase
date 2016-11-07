#!/usr/bin/env bash
mongod -f /etc/mongodb.conf &
sleep 2
yes | /opt/go/bin/shock-server -conf /opt/run/config/shock.conf &
sleep 3
pkill shock-server
pkill mongod
