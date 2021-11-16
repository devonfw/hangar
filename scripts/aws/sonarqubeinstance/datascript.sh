#! /bin/bash
                echo "script start"
                sudo apt-get update
                sudo apt-get install docker.io -y
                sudo sysctl -w vm.max_map_count=262144
                sudo sysctl -w fs.file-max=65536
                ulimit -n 65536
                ulimit -u 4096 
                sudo docker pull sonarqube:lts
                sudo docker volume create sonarqube-conf 
                sudo docker volume create sonarqube-data
                sudo docker volume create sonarqube-logs
                sudo docker volume create sonarqube-extensions
                sudo docker run -d --name sonarqube -p 9000:9000 -p 9092:9092 -v sonarqube-conf:/opt/sonarqube/conf -v sonarqube-data:/opt/sonarqube/data -v sonarqube-logs:/opt/sonarqube/logs -v sonarqube-extensions:/opt/sonarqube/extensions sonarqube:lts
                echo "skript end"