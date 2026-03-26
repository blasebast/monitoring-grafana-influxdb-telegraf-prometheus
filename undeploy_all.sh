#!/bin/bash
set -e

NC='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
LRED='\033[01;31m'
LGREEN='\033[01;32m'
LYELLOW='\033[01;33m'
LBLUE='\033[01;34m'

echo -e "${LBLUE}=== Monitoring Stack Cleanup ===${NC}"

# Stop and remove containers
echo -e "${BLUE}Stopping containers...${NC}"
docker-compose down

# Cleanup dangling volumes
read -r -p "Do you want to delete all docker dangling volumes? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    echo -e "${YELLOW}Removing dangling volumes...${NC}"
    dangling_vols=$(docker volume ls -qf dangling=true)
    if [ -z "$dangling_vols" ]; then
        echo -e "${GREEN}No dangling volumes found${NC}"
    else
        echo "$dangling_vols" | while read vol; do
            echo -e "${BLUE}Removing volume: $vol${NC}"
            docker volume rm "$vol" || echo -e "${RED}Failed to remove: $vol${NC}"
        done
    fi
else
    echo -e "${GREEN}Skipping dangling volume cleanup${NC}"
fi

# Cleanup dangling images
read -r -p "Do you want to delete all docker dangling images? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    echo -e "${YELLOW}Removing dangling images...${NC}"
    dangling_imgs=$(docker images --filter "dangling=true" -q --no-trunc)
    if [ -z "$dangling_imgs" ]; then
        echo -e "${GREEN}No dangling images found${NC}"
    else
        echo "$dangling_imgs" | while read img; do
            echo -e "${BLUE}Removing image: $img${NC}"
            docker rmi "$img" || echo -e "${RED}Failed to remove: $img${NC}"
        done
    fi
else
    echo -e "${GREEN}Skipping dangling image cleanup${NC}"
fi

# Cleanup <none> images
read -r -p "Do you want to delete all docker <none> images? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    echo -e "${YELLOW}Removing <none> images...${NC}"
    none_imgs=$(docker images | grep "<none>" | awk '{print $3}')
    if [ -z "$none_imgs" ]; then
        echo -e "${GREEN}No <none> images found${NC}"
    else
        echo "$none_imgs" | while read img; do
            echo -e "${BLUE}Removing image: $img${NC}"
            docker rmi "$img" || echo -e "${RED}Failed to remove: $img${NC}"
        done
    fi
else
    echo -e "${GREEN}Skipping <none> image cleanup${NC}"
fi

# Cleanup exited containers
read -r -p "Do you want to delete all exited containers? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    echo -e "${YELLOW}Removing exited containers...${NC}"
    exited=$(docker ps -qa --no-trunc --filter "status=exited")
    if [ -z "$exited" ]; then
        echo -e "${GREEN}No exited containers found${NC}"
    else
        echo "$exited" | while read container; do
            echo -e "${BLUE}Removing container: $container${NC}"
            docker rm "$container" || echo -e "${RED}Failed to remove: $container${NC}"
        done
    fi
else
    echo -e "${GREEN}Skipping exited container cleanup${NC}"
fi

echo -e "${LGREEN}=== Cleanup complete ===${NC}"
