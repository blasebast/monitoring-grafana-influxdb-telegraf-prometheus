## INSTALL docker-compose
## uncomment if you don't have docker-compose installed  #sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
## uncomment if you don't have docker-compose installed  #sudo chmod +x /usr/local/bin/docker-compose

# START docker-compose
docker-compose up -d 

# ADD DATASOURCES AND DASHBOARDS
echo "adding dashboards..."
docker exec -it -u 0 grafana /var/lib/grafana/ds/add_dashboards.sh

echo "adding datasources..."
docker exec -it -u 0 grafana /var/lib/grafana/ds/add_datasources.sh
