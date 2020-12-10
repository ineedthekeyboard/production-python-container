#!/bin/sh

GUNICORN=/usr/local/bin/gunicorn
ROOT=/app/webapp
PID=/var/run/gunicorn.pid

APP=main:app

if [ -f $PID ]; then rm $PID; fi

echo "Firing up gunicorn!"
cd $ROOT
exec $GUNICORN --capture-output --log-file=- --worker-tmp-dir /dev/shm --workers=3 --threads=3 --worker-class=gthread --bind 127.0.0.1:8080 --pid=$PID $APP