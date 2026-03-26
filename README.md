# Monitoring Stack

Easily deployable monitoring solution using Docker Compose with the following components:
- **Grafana** - Frontend for monitoring and alerting
- **Prometheus** - Time-series database and metrics scraper
- **InfluxDB 2.x** - Alternative time-series storage (Telegraf backend)
- **Telegraf** - Metrics collector agent
- **Node Exporter** - System metrics exporter for Prometheus
- **cAdvisor** - Container metrics exporter
- **AlertManager** - Alert routing and management

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- 4GB+ RAM and 10GB+ disk space recommended

### Setup

1. **Clone the repository**
```bash
git clone <repo-url>
cd monitoring-grafana-influxdb-telegraf-prometheus
```

2. **Create environment configuration**
```bash
cp .env.example .env
# Edit .env and customize settings (passwords, ports, etc.)
nano .env
```

**Important security notes:**
- Change all default passwords in `.env` (especially `GF_SECURITY_ADMIN_PASSWORD`, `INFLUXDB_ADMIN_PASSWORD`)
- Never commit `.env` to version control (it's in `.gitignore`)
- Use strong, unique passwords for production deployments

3. **Deploy the stack**
```bash
chmod +x deploy_all.sh undeploy_all.sh
./deploy_all.sh
```

The deployment script will:
- Validate all required environment variables
- Start all Docker containers
- Wait for services to be healthy
- Automatically add InfluxDB and Prometheus datasources
- Load Grafana dashboards

### Access Services

After deployment, access services using the ports configured in `.env`:
- **Grafana**: `http://localhost:3001` (or configured `GRAFANA_PORT`)
- **Prometheus**: `http://localhost:9090` (or configured `PROMETHEUS_PORT`)
- **InfluxDB**: `http://localhost:8086` (or configured `INFLUXDB_PORT`)
- **AlertManager**: `http://localhost:9093`
- **cAdvisor**: `http://localhost:8081`

Default Grafana credentials: `admin` / password from `GF_SECURITY_ADMIN_PASSWORD` in `.env`

## Configuration

All configuration is managed through environment variables in the `.env` file:

| Variable | Purpose | Example |
|----------|---------|---------|
| `GRAFANA_PORT` | Grafana web UI port | `3001` |
| `INFLUXDB_PORT` | InfluxDB API port | `8086` |
| `PROMETHEUS_PORT` | Prometheus web UI port | `9090` |
| `GF_SECURITY_ADMIN_USER` | Grafana admin username | `admin` |
| `GF_SECURITY_ADMIN_PASSWORD` | Grafana admin password | `changeme123!` |
| `GF_SERVER_DOMAIN` | Domain for external access | `localhost` |
| `GF_AUTH_ANONYMOUS_ENABLED` | Allow anonymous dashboard access | `false` |
| `GF_SERVER_PROTOCOL` | HTTP or HTTPS | `http` |
| `INFLUXDB_ADMIN_USER` | InfluxDB admin username | `admin` |
| `INFLUXDB_ADMIN_PASSWORD` | InfluxDB admin password | `changeme123!` |
| `INFLUXDB_DB` | Default InfluxDB database | `telegraf` |
| `INFLUXDB_USER` | InfluxDB user | `telegraf` |
| `INFLUXDB_USER_PASSWORD` | InfluxDB user password | `changeme123!` |
| `METRICS_INTERVAL` | Grafana metrics interval (seconds) | `10` |
| `RETENTION_DAYS` | Prometheus data retention | `30` |
| `TELEGRAF_DEBUG` | Enable Telegraf debug logging | `false` |
| `HOSTNAME` | Container hostname for metrics | `localhost` |

## Monitoring Configuration

### telegraf.conf
Configure which metrics Telegraf collects. Default includes:
- System metrics (CPU, memory, disk, network)
- Docker container metrics
- Network interfaces

### prometheus/prometheus.yml
Defines Prometheus scrape targets:
- Node Exporter (9100)
- cAdvisor (8080)
- Prometheus itself (9090)

### alertmanager/config.yml
Configure alert routing and notification channels (email, Slack, PagerDuty, etc.)

## Scaling and Resource Limits

The `docker-compose.yml` includes resource limits and reservations for all services:
- **InfluxDB**: 2 CPU / 2GB RAM limit, 0.5 CPU / 512MB reserved
- **Grafana**: 1 CPU / 1GB RAM limit, 0.25 CPU / 256MB reserved
- **Prometheus**: 1 CPU / 1GB RAM limit, 0.25 CPU / 256MB reserved
- **Telegraf**: 0.5 CPU / 512MB RAM limit, 0.25 CPU / 128MB reserved

Adjust `deploy.resources` sections in `docker-compose.yml` for your environment.

## Maintenance

### Viewing Logs
```bash
docker-compose logs -f <service>  # e.g., docker-compose logs -f grafana
```

### Restarting a Service
```bash
docker-compose restart <service>
```

### Stopping the Stack
```bash
./undeploy_all.sh
```

The script will prompt to remove dangling volumes and images.

### Database Backups
Backup InfluxDB:
```bash
docker exec influxdb influx backup -portable /influxdb_backup
```

Backup Prometheus:
```bash
cp -r /var/lib/docker/volumes/prometheus_data/_data ~/.backup/prometheus_$(date +%Y%m%d)
```

## Troubleshooting

### Grafana not starting
Check logs: `docker-compose logs grafana`
Ensure ports are not in use: `netstat -tuln | grep :3001`

### Datasources show as "unhealthy"
Wait 30-60 seconds for services to become healthy
Check health: `curl http://localhost:3001/api/health`

### No data appearing in dashboards
Verify Telegraf is running: `docker-compose logs telegraf`
Check InfluxDB has data: `docker exec influxdb influx query 'from(bucket:"telegraf") |> range(start: -1h)'`

## License

MIT
