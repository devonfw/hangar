#! /bin/bash
                #update Ubuntu 
                sudo apt-get update
                #install the docker.io
                sudo apt-get install docker.io -y
                #official recommended values for sonarqube
                sudo sysctl -w vm.max_map_count=262144
                sudo sysctl -w fs.file-max=65536
                ulimit -n 65536
                ulimit -u 4096
                #getting the long term support version of an sonarqube image. Here it is Version 8.9.3 
                sudo docker pull sonarqube:lts
                # recommend volumes for the following directories
                sudo docker volume create sonarqube-conf 
                sudo docker volume create sonarqube-data
                sudo docker volume create sonarqube-logs
                sudo docker volume create sonarqube-extensions
                # run sonarqube and connection the new created volumes
                sudo docker run -d --name sonarqube -p 9000:9000 -p 9092:9092 -v sonarqube-conf:/opt/sonarqube/conf -v sonarqube-data:/opt/sonarqube/data -v sonarqube-logs:/opt/sonarqube/logs -v sonarqube-extensions:/opt/sonarqube/extensions sonarqube:lts
                