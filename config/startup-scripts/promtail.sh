#!/bin/sh
echo "Firing up Promtail"
exec /promtail/promtail-linux-amd64 -config.file=/promtail/promtail-config.yaml

