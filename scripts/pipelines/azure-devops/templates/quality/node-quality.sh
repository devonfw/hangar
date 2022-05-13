#!/bin/bash
url=<sonarqube-url>
login=<sonarqube-token>
projectKey=$(python <<EOF
from json import load
with open('../../package.json', 'r') as file:
    package = load(file)
print(package["name"])
EOF
)

npx sonar-scanner -Dsonar.host.url=$url -Dsonar.login=$login -Dsonar.projectKey=$projectKey -Dsonar.projectBaseDir="../../" -Dsonar.sources="."
