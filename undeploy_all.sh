# START docker-compose
do_cleanup () {
	docker-compose down

	read -r -p "Do you want to delete all docker dangling volumes? [y/N] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
	then
		for d in $(docker volume ls -qf dangling=true); do 
			docker volume rm $d
		done
	else
        	echo -e "'no' chosen"
	fi

	
#	read -r -p "Do you want to delete all docker \"bridge\" networks? [y/N] " response
#	if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
#	then
#		for n in $(docker network ls | grep "bridge" | awk '/ / { print $1 }'); do
#			echo -e "attempting to delete network: $n"
#			docker network rm $n || echo "cannot remove: $n"
#		done
#	else
#        	echo -e "'no' chosen"
#	fi

	read -r -p "Do you want to delete all docker dangling images? [y/N] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
	then
		for i in $(docker images --filter "dangling=true" -q --no-trunc); do
			docker rmi $i
		done
	else
        	echo -e "'no' chosen"
	fi

	read -r -p "Do you want to delete all docker \"none\" images? [y/N] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
	then
		for i in $(docker images | grep "none"); do
			i=$(echo $i | awk '/ / { print $3 }')
			docker rmi $i
		done
	else
        	echo -e "'no' chosen"
	fi
	
	read -r -p "Do you want to delete all docker exited containers? [y/N] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
	then
		for d in $(docker ps -qa --no-trunc --filter "status=exited"); do
			docker rm $d
		done
	else
        	echo -e "'no' chosen"
	fi
}

do_cleanup || exit 
