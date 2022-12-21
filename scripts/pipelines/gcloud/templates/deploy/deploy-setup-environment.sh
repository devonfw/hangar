#!/bin/bash
set -e
apt-get update
apt-get install sudo -y
apt-get install -y wget
apt-get install curl -y
apt-get install zip -y
# INSTALL yq
wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
chmod a+x /usr/local/bin/yq
# INSTALL KUBECTL
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
# We get the name of the registry from the full image name
firstPartImage=$(echo $_IMAGE_NAME | cut -d'/' -f1)
echo "$firstPartImage" | grep "\." > /dev/null && REGISTRY="$firstPartImage" || REGISTRY="docker.io"
echo -e "\n\n"
echo "LOADING CREDENTIALS AND GETTING REGISTRY"
# shellcheck source=/dev/null
. credentials.env
echo "LOADING CLUSTER INFOS"
# shellcheck source=/dev/null
. cluster_info.env
