# What is in this repository?

This repository contains easily deployable monitoring solution which uses:
 - Grafana (frontend for monitoring + alerts)
 - Prometheus (monitoring solution pulling metrics from exporter)
 - Node Exporter for Prometheus (metrics exporter-exposer for Prometheus)
 - Telegraf (monitoring agent)
 - InfluxDB (persistent timeseries storage)
 - cAdvisor (containers monitoring)
 - alertmanager (alerting)


# How to use it?

If you have docker and docker-compose installed, this will take roughly 1 minute to have it up and running.
If not - it will still take mentioned ~ 1 minute + time needed for docker installation.

## Here is how to install:

* $ clone the repository
* $ cd to cloned dir
* $ chmod +x ./deploy_all.sh; ./deploy_all.sh
    
    
    Monitoring should be up and running http://_**hostname**_:3001/




