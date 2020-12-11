#!/bin/sh

GUNICORN=/usr/local/bin/gunicorn
ROOT=/app/webapp
PID=/var/run/passenger.pid

if [ -f $PID ]; then rm $PID; fi

echo "Firing up passenger!"
cd $ROOT
exec passenger start --pid-file=$PID