#!/bin/bash
url=<sonarqube-url>
login=<sonarqube-token>
mvn sonar:sonar -Dsonar.host.url=$url -Dsonar.login=$login -Dsonar.java.binaries=$1/target/classes