#!/bin/bash
mvn package -B

mvn test -B -Dmaven.install.skip=true

# Quality
mvn sonar:sonar -B -Dsonar.host.url="$SONAR_URL" -Dsonar.login="$SONAR_TOKEN" -Dsonar.java.binaries=$PROJECT_PATH/target/classes
