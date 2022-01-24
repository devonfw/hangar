#!/bin/bash
mvn sonar:sonar -Dsonar.host.url=<sonarqube-url> -Dsonar.login=<sonarqube-token> -Dsonar.java.binaries=$1/build/classes