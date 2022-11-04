# Installation of sonar scanner 
apt-get update
apt-get install unzip wget nodejs
mkdir sonarqube -p
cd sonarqube
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.2.0.1873-linux.zip
unzip sonar-scanner-cli-4.2.0.1873-linux.zip
mv sonar-scanner-4.2.0.1873-linux /opt/sonar-scanner
cd ..
export PATH="$PATH:/opt/sonar-scanner/bin"