#!/bin/sh

PID=/var/run/loki.pid

if [ -f $PID ]; then rm $PID; fi

echo "Firing up Loki"
exec /loki/loki-linux-amd64 -config.file=/loki/loki-config.yaml --pid=$PID