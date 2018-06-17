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
docker-compose up -d --remove-orphans

# ADD DATASOURCES AND DASHBOARDS
echo "adding datasources..."
docker exec -it -u 0 grafana /var/lib/grafana/ds/add_datasources.sh

echo "adding dashboards..."
docker exec -it -u 0 grafana /var/lib/grafana/ds/add_dashboards.sh


## NOW LET'S SECURE GRAFANA
# CHECKING OUT ORIGINAL FILE
#echo -e "checking out original docker-compose.yml"
#git checkout docker-compose.yml

## STOPPING and REMOVING GRAFANA CONTAINER
echo -e "stopping & removing grafana container"
container_id=$(docker container ls | grep grafana| awk '{print $1}')
docker stop $container_id
docker rm $container_id

# REPLACING HTTP with HTTPS
echo -e "changing http to https"
sed -i 's/GF_SERVER_PROTOCOL: "http"/GF_SERVER_PROTOCOL: "https"/g' docker-compose.yml
docker-compose up -d grafana
