## INSTALL docker-ce
read -r -p "Do you want to install docker? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
	curl -fsSL get.docker.com -o get-docker.sh
	sudo sh get-docker.sh
	sudo usermod -aG docker $(whoami)
else
	echo -e "'no' chosen for docker installation - docker assummed to be already installed"
fi

## INSTALL docker-compose
read -r -p "Do you want to install docker-compose? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
	sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
else
	echo -e "'no' chosen for docker-compose installation - docker-compose assummed to be already installed"
fi

# START docker-compose
docker-compose up -d 

# ADD DATASOURCES AND DASHBOARDS
echo "adding dashboards..."
docker exec -it -u 0 grafana /var/lib/grafana/ds/add_dashboards.sh

echo "adding datasources..."
docker exec -it -u 0 grafana /var/lib/grafana/ds/add_datasources.sh
