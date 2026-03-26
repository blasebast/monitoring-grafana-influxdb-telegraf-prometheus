#!/bin/bash
set -e

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "ERROR: .env file not found. Please create it from .env.example"
    exit 1
fi

# Validate required environment variables
for var in GF_SECURITY_ADMIN_USER GF_SECURITY_ADMIN_PASSWORD INFLUXDB_DB INFLUXDB_USER INFLUXDB_USER_PASSWORD GRAFANA_PORT; do
    if [ -z "$(eval echo \$$var)" ]; then
        echo "ERROR: Required environment variable $var is not set"
        exit 1
    fi
done

GRAFANA_URL="http://${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}@localhost:${GRAFANA_PORT}"
INFLUXDB_ADDR="http://influxdb:${INFLUXDB_PORT}"

# Add InfluxDB datasource
echo "Adding InfluxDB datasource..."
curl -s -H "Content-Type: application/json" \
    -XPOST "${GRAFANA_URL}/api/datasources" \
    -d @- <<EOF
{
    "name": "influxdb",
    "type": "influxdb",
    "access": "proxy",
    "url": "${INFLUXDB_ADDR}",
    "database": "${INFLUXDB_DB}",
    "user": "${INFLUXDB_USER}",
    "password": "${INFLUXDB_USER_PASSWORD}",
    "basicAuth": false
}
EOF

if [ $? -eq 0 ]; then
    echo "InfluxDB datasource added successfully"
else
    echo "ERROR: Failed to add InfluxDB datasource"
    exit 1
fi

# Add Prometheus datasource
echo "Adding Prometheus datasource..."
curl -s -H "Content-Type: application/json" \
    -XPOST "${GRAFANA_URL}/api/datasources" \
    -d @- <<EOF
{
    "name": "prometheus",
    "type": "prometheus",
    "access": "proxy",
    "url": "http://prometheus:${PROMETHEUS_PORT}"
}
EOF

if [ $? -eq 0 ]; then
    echo "Prometheus datasource added successfully"
else
    echo "ERROR: Failed to add Prometheus datasource"
    exit 1
fi

