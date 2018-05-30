#!/bin/bash
VERSION=`cat /etc/lsb-release | grep RELEASE | cut -d"=" -f2`
if [ $VERSION = "18.04" ]; then
  DOCKER="docker.io"
else
  DOCKER="docker-ce"
fi
apt update
if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "Installing git"
  apt install -y git
else
  echo "Git is already installed"
fi
if [ $(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "Installing curl"
  apt install -y curl
else
  echo "Curl is already installed"
fi

if [ ! -d /opt/elastic_stack ];
then
  echo "Cloning elastic_stack repo"
  cd /opt
  git clone https://github.com/HASecuritySolutions/elastic_stack.git
  chown -R ${SUDO_USER} /opt/elastic_stack
fi
if grep -q 'deb \[arch=amd64\] https://download.docker.com/linux/ubuntu' /etc/apt/sources.list
then
  echo "Docker software repository is already installed"
else
  echo "Docker software repository is not installed. Installing"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update
  if grep -q 'deb \[arch=amd64\] https://download.docker.com/linux/ubuntu' /etc/apt/sources.list
  then
    echo "Docker software repository is now installed"
  fi
fi
if [ $(dpkg-query -W -f='${Status}' docker 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "Installing docker"
  sudo apt-get install -y $DOCKER
else
  echo "Docker is already installed"
fi
if grep docker /etc/group | grep -q ${SUDO_USER}
then
  echo "Current user already member of docker group"
else
  echo "Adding current user to docker group"
  sudo usermod -aG docker ${SUDO_USER}
fi
if [ -f /usr/local/bin/docker-compose ];
then
  echo "Docker Compose is already installed"
else
  echo "Installing Docker Compose"
  sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi
if grep -q 'vm.max_map_count' /etc/sysctl.conf
then
  echo "VM Max Map Count already configured"
else
  echo "Setting vm.max_map_count to 262144"
  sudo sysctl -w vm.max_map_count=262144
  echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
fi
chown -R ${SUDO_USER}: /opt/elastic_stack
