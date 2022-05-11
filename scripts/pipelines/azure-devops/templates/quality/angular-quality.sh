#!/bin/bash
url=<sonarqube-url>
login=<sonarqube-token>
npx sonar-scanner -Dsonar.host.url=$url -Dsonar.login=$login # Project key / basedir / sources yet to be added
