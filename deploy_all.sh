#!/bin/bash

NC='\033[0m'

RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
LIGHTGRAY='\033[00;37m'
MAGENTA='\033[00;35m'
LRED='\033[01;31m'
LGREEN='\033[01;32m'
LYELLOW='\033[01;33m'
LBLUE='\033[01;34m'
LPURPLE='\033[01;35m'
LCYAN='\033[01;36m'
WHITE='\033[01;37m'



## INSTALL docker-ce
read -r -p "Do you want to install docker? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
	logout=1
	curl -fsSL get.docker.com -o get-docker.sh
	sudo sh get-docker.sh
	sudo systemctl enable docker
else
	echo -e "'no' chosen for docker installation - docker assummed to be already installed"
fi

## INSTALL docker-compose
read -r -p "Do you want to install docker-compose? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
	logout=1
	sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
else
	echo -e "'no' chosen for docker-compose installation - docker-compose assummed to be already installed"
fi

## LOGOUT IF NEEDED
if [[ "$logout" -eq 1 ]]; then
	if [[ $(whoami) != "root" ]]; then
		if [[ ! $(groups $(whoami) | egrep -oh 'docker') == "docker" ]]; then
			echo -e "${BLUE}your login ${YELLOW}$(whoami)${NC}${BLUE} will be added to "docker" group...${NC}"
			if [[ ! $(cat /etc/group | egrep -oh 'docker:') == "docker:" ]]; then
				sudo groupadd docker
				echo -e "${BLUE}creating group: ${YELLOW}docker${NC}${BLUE}${NC}"
			fi
			sudo usermod -aG docker $(whoami)
			echo -e "${BLUE}you need to logout and login again...${NC}"
			echo -e "${BLUE}start the same script and skip docker related part (answer 'no' two times).${NC}"
			exit
		fi
	fi
	echo -e "${YELLOW}docker was installed, you need to logout and login${NC}"
	echo -e "${RED}login again and start deploy script without docker* installation part (answer no)${NC}"
	exit 0
fi


# START docker-compose
docker-compose up -d --remove-orphans

# ADD DATASOURCES AND DASHBOARDS
sudo systemctl restart docker
docker-compose up -d 

# ADD DATASOURCES AND DASHBOARDS
sleep 5
echo "adding datasources..."
docker exec -it -u 0 grafana /var/lib/grafana/ds/add_datasources.sh

echo "adding dashboards..."
docker exec -it -u 0 grafana /var/lib/grafana/ds/add_dashboards.sh


### NOW LET'S SECURE GRAFANA
### STOPPING and REMOVING GRAFANA CONTAINER
#echo -e "stopping & removing grafana container"
#container_id=$(docker container ls | grep grafana| awk '{print $1}')
#docker stop $container_id
#docker rm $container_id
#find grafana -name '*.pem' -exec chmod 666 {} \;
#
## REPLACING HTTP with HTTPS
#echo -e "changing http to https"
#sed -i 's/GF_SERVER_PROTOCOL: "http"/GF_SERVER_PROTOCOL: "https"/g' docker-compose.yml
#docker-compose up -d grafana
#echo -e "reverting: changing https to http"
#sed -i 's/GF_SERVER_PROTOCOL: "https"/GF_SERVER_PROTOCOL: "http"/g' docker-compose.yml
