#!/bin/bash
#set -e

# ADD INFLUXDB DATASOURCE
curl -s -H "Content-Type: application/json" \
    -XPOST http://admin:admin@localhost:3000/api/datasources \
    -d @- <<EOF
{
    "name": "influxdb",
    "type": "influxdb",
    "access": "proxy",
    "url": "http://influxdb:8086",
    "database": "telegraf",
    "user":"telegraf",
    "password":"nimda",
    "basicAuth":false
}
EOF

## ADD PROMETHEUS DATASOURCE
curl -s -H "Content-Type: application/json" \
    -XPOST http://admin:admin@localhost:3000/api/datasources \
    -d @- <<EOF
{
    "name": "prometheus",
    "type": "prometheus",
    "access": "proxy",
    "url": "http://prometheus:9090"
}
EOF

