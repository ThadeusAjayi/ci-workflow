#!/bin/bash

# Check if docker is installed
if ! command -v docker &> /dev/null
then
    echo "####################################"
    echo "###   Install docker on host     ###"
    echo "####################################"
    echo

    echo "Installing docker on host"
    apt-get update && apt-get install -y lsb-release

    curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
        https://download.docker.com/linux/debian/gpg

    echo "deb [arch=$(dpkg --print-architecture) \
        signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
        https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

    apt-get update && apt-get install -y docker-ce-cli
fi

echo "####################################"
echo "###    Build Jenkins Image       ###"
echo "####################################"
echo

docker build -t jenkins .


echo "####################################"
echo "###   Create Jenkins Network     ###"
echo "####################################"
echo

docker network create jenkins

echo "####################################"
echo "###   Create Jenkins Container   ###"
echo "####################################"
echo

docker run \
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
docker exec -it jenkins-controller bash -c 'read -sp "Enter passphrase: " PASSPHRASE'
echo

# Automate SSH key generation with a passphrase
docker exec -it jenkins-controller bash -c 'yes | ssh-keygen -t ed25519 -f ~/.ssh/jenkins_agent_key -N "$PASSPHRASE"'

docker exec -it jenkins-controller bash -c 'cat ~/.ssh/jenkins_agent_key'
echo

docker exec -it jenkins-controller bash -c 'cat ~/.ssh/jenkins_agent_key.pub'
echo

PUBLIC_KEY=$(docker exec -it jenkins-controller bash -c 'cat ~/.ssh/jenkins_agent_key.pub')


echo "####################################"
echo "###     Create agent node        ###"
echo "####################################"
echo

docker run -d --name=agent-node -p 22:22 \
-e "JENKINS_AGENT_SSH_PUBKEY=$PUBLIC_KEY" \
--network jenkins \
jenkins/ssh-agent:latest-jdk17

# copy initial jenkins password to file
docker cp jenkins-controller:/var/jenkins_home/secrets/initialAdminPassword .


echo "####################################"
echo "###     Create agent node        ###"
echo "####################################"

docker exec -it agent-node bash -c 'apt-get update && yes | apt install curl'

docker exec -it agent-node bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash'

#Persist NVM session
#docker exec -it agent-node bash -c 'echo -e "\nexport NVM_DIR=\"$HOME/.nvm\"\n[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\"\n[ -s \"$NVM_DIR/bash_completion\" ] && \. \"$NVM_DIR/bash_completion\"" >> ~/.bashrc'

docker exec -it agent-node bash -c 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm install 20'

echo "###########################################################################################"
echo "### All successfull. Continue to setup jenkins on localhost:8080 and connect agent node ###"
echo "###########################################################################################"