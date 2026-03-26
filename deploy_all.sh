#!/bin/bash
set -e

NC='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
LGREEN='\033[01;32m'
LYELLOW='\033[01;33m'
LBLUE='\033[01;34m'
LCYAN='\033[01;36m'

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}ERROR: .env file not found!${NC}"
    echo -e "${YELLOW}Please create .env file from .env.example:${NC}"
    echo -e "  cp .env.example .env"
    echo -e "  # Edit .env and set your desired values"
    exit 1
fi

# Load environment variables
export $(grep -v '^#' .env | xargs)

# Validate required variables
REQUIRED_VARS=(
    "GRAFANA_PORT"
    "INFLUXDB_PORT"
    "PROMETHEUS_PORT"
    "GF_SECURITY_ADMIN_USER"
    "GF_SECURITY_ADMIN_PASSWORD"
    "INFLUXDB_ADMIN_USER"
    "INFLUXDB_ADMIN_PASSWORD"
    "INFLUXDB_DB"
    "INFLUXDB_USER"
    "INFLUXDB_USER_PASSWORD"
)

echo -e "${BLUE}Validating environment variables...${NC}"
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "$(eval echo \$$var)" ]; then
        echo -e "${RED}ERROR: Required variable $var is not set in .env${NC}"
        exit 1
    fi
done
echo -e "${GREEN}All required variables are set${NC}"

# Check Docker installation
if ! command -v docker &> /dev/null; then
    echo -e "${RED}ERROR: Docker is not installed${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}ERROR: Docker Compose is not installed${NC}"
    exit 1
fi

echo -e "${LBLUE}=== Starting monitoring stack ===${NC}"

# Start services
echo -e "${BLUE}Starting services with docker-compose...${NC}"
docker-compose up -d --remove-orphans

# Wait for services to be healthy
echo -e "${BLUE}Waiting for services to be healthy...${NC}"
sleep 10

# Check Grafana health
echo -e "${BLUE}Waiting for Grafana to be ready...${NC}"
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -sf "http://localhost:${GRAFANA_PORT}/api/health" > /dev/null 2>&1; then
        echo -e "${GREEN}Grafana is ready${NC}"
        break
    fi
    echo -e "${YELLOW}Grafana not ready yet, retrying... ($((attempt+1))/$max_attempts)${NC}"
    sleep 2
    ((attempt++))
done

if [ $attempt -eq $max_attempts ]; then
    echo -e "${RED}ERROR: Grafana failed to become healthy${NC}"
    exit 1
fi

# Add datasources
echo -e "${BLUE}Adding datasources...${NC}"
if docker exec grafana bash /var/lib/grafana/ds/add_datasources.sh; then
    echo -e "${GREEN}Datasources added successfully${NC}"
else
    echo -e "${RED}ERROR: Failed to add datasources${NC}"
    exit 1
fi

# Add dashboards
echo -e "${BLUE}Adding dashboards...${NC}"
if docker exec grafana bash /var/lib/grafana/ds/add_dashboards.sh; then
    echo -e "${GREEN}Dashboards added successfully${NC}"
else
    echo -e "${RED}WARNING: Some dashboards may not have been added${NC}"
fi

echo -e "${LGREEN}=== Deployment complete ===${NC}"
echo -e "${LCYAN}Monitoring stack is running at:${NC}"
echo -e "  Grafana:      ${BLUE}http://localhost:${GRAFANA_PORT}${NC}"
echo -e "  Prometheus:   ${BLUE}http://localhost:${PROMETHEUS_PORT}${NC}"
echo -e "  InfluxDB:     ${BLUE}http://localhost:${INFLUXDB_PORT}${NC}"
echo -e "  AlertManager: ${BLUE}http://localhost:9093${NC}"
echo -e "  cAdvisor:     ${BLUE}http://localhost:8081${NC}"
