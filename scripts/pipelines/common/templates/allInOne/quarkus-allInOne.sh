#!/bin/bash
mvn package -B -Pnative

mvn test -B -Dmaven.install.skip=true -Pnative

# Quality
mvn sonar:sonar -B -Dsonar.host.url="$SONAR_URL" -Dsonar.login="$SONAR_TOKEN" -Dsonar.java.binaries=$PROJECT_PATH/target/classes
