#!/bin/bash

# Start Apache2.
service apache2 start > /dev/null 2>&1

APACHE2_STATUS=1
while [[ APACHE2_STATUS -ne 0 ]]; do
    echo "== Waiting for confirmation of Apache2 service startup..."
    sleep 5
    service apache2 status > /dev/null 2>&1
    APACHE2_STATUS=$?
done

echo "== Service apache2 started."

# Prevent immediate stop of the docker container.
rm /var/run/supervisor.sock
exec supervisord -n
