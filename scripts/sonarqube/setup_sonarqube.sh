#! /bin/bash

white='\e[1;37m'
green='\e[1;32m'

echo -e "${green}Updating repositories..."
echo -e ${white}
sudo apt-get update

echo -e "${green}Setting proper system limits for SonarQube..."
echo -e ${white}
sudo bash -c 'cat > /etc/sysctl.d/99-sonarqube.conf' << EOF 
vm.max_map_count=524288
fs.file-max=131072
EOF
sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072

echo -e "${green}Installing Docker..."
echo -e ${white}
sudo apt-get install docker.io -y

echo -e "${green}Pulling the SonarQube LTS image..."
echo -e ${white}
sudo docker pull sonarqube:lts

echo -e "${green}Creating the default volumes for SonarQube..."
echo -e ${white}
sudo docker volume create sonarqube-conf 
sudo docker volume create sonarqube-data
sudo docker volume create sonarqube-logs
sudo docker volume create sonarqube-extensions

# Get the maximum memory for the container.
mem=$(grep MemTotal /proc/meminfo)
length=${#mem}
mem=${mem:10:length-10-3}
mem=$(echo "scale=2;$mem/1000" |bc)
mem=$(echo "scale=2;$mem*0.8" |bc)
mem="$mem"m

echo -e "${green}Launching SonarQube container..."
echo -e ${white}
sudo docker run -d --restart always --memory "$mem" --name sonarqube -p 9000:9000 -p 9092:9092 --ulimit nofile=131072 --ulimit nproc=8192 -v sonarqube-conf:/opt/sonarqube/conf -v sonarqube-data:/opt/sonarqube/data -v sonarqube-logs:/opt/sonarqube/logs -v sonarqube-extensions:/opt/sonarqube/extensions sonarqube:lts
                
