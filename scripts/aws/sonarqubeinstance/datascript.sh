#! /bin/bash

white='\e[1;37m'
green='\e[1;32m'

#update Ubuntu
echo -e "${green}Updating the system..."
echo -e ${white}
sudo apt-get update

#install the docker.io
echo -e "${green}Installing docker..."
echo -e ${white}
sudo apt-get install docker.io -y

#official recommended values for sonarqube
echo -e "${green}Setting the SonarQube default values..."
echo -e ${white}
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=65536
ulimit -n 65536
ulimit -u 4096

#getting the long term support version of an sonarqube image. Here it is Version 8.9.3
echo -e "${green}Pulling the docker image..."
echo -e ${white}
sudo docker pull sonarqube:lts

# recommended volumes for the following directories
echo -e "${green}Creating the default volumes for SonarQube..."
echo -e ${white}
sudo docker volume create sonarqube-conf 
sudo docker volume create sonarqube-data
sudo docker volume create sonarqube-logs
sudo docker volume create sonarqube-extensions

# run sonarqube and connection the new created volumes
echo -e "${green}Running the SonarQube container..."
echo -e ${white}
sudo docker run -d --name sonarqube -p 9000:9000 -p 9092:9092 -v sonarqube-conf:/opt/sonarqube/conf -v sonarqube-data:/opt/sonarqube/data -v sonarqube-logs:/opt/sonarqube/logs -v sonarqube-extensions:/opt/sonarqube/extensions sonarqube:lts
                
