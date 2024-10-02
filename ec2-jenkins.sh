#!/bin/bash

# Check if docker is installed

if ! command -v docker &> /dev/null
then
    echo "####################################"
    echo "###   Install docker on host     ###"
    echo "####################################"
    echo

    echo "Installing docker on host"
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

echo "####################################"
echo "###    Build Jenkins Image       ###"
echo "####################################"
echo

sudo docker build -t jenkins .


echo "####################################"
echo "###   Create Jenkins Network     ###"
echo "####################################"
echo

sudo docker network create jenkins

echo "####################################"
echo "###   Create Jenkins Container   ###"
echo "####################################"
echo

sudo docker run \
  --name jenkins-controller \
  --restart=on-failure \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 \
  --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  jenkins


echo "####################################"
echo "###  Generate ssh key for agent  ###"
echo "####################################"
echo

# Define a passphrase
sudo docker exec -it jenkins-controller bash -c 'read -sp "Enter passphrase: " PASSPHRASE'
echo

# Automate SSH key generation with a passphrase
sudo docker exec -it jenkins-controller bash -c 'yes | ssh-keygen -t ed25519 -f ~/.ssh/jenkins_agent_key -N "$PASSPHRASE"'

sudo docker exec -it jenkins-controller bash -c 'cat ~/.ssh/jenkins_agent_key'
echo

sudo docker exec -it jenkins-controller bash -c 'cat ~/.ssh/jenkins_agent_key.pub'
echo

PUBLIC_KEY=$(sudo docker exec -it jenkins-controller bash -c 'cat ~/.ssh/jenkins_agent_key.pub')


echo "####################################"
echo "###     Create api node          ###"
echo "####################################"
echo

sudo docker run -d --name=api-node \
-p 3001:3001 \
-p 2222:22 \
-e "JENKINS_AGENT_SSH_PUBKEY=$PUBLIC_KEY" \
--network jenkins \
jenkins/ssh-agent:latest-jdk17

# # copy initial jenkins password to file
sudo docker cp jenkins-controller:/var/jenkins_home/secrets/initialAdminPassword .


echo "####################################"
echo "###   Install nvm inside agent   ###"
echo "####################################"

sudo docker exec -it api-node bash -c 'apt-get update && yes | apt install curl'

sudo docker exec -it api-node bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash'

sudo docker exec -it api-node bash -c 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm install 20'

echo "###########################################################################################"
echo "### All successfull. Continue to setup jenkins on localhost:8080 and connect agent node ###"
echo "###########################################################################################"