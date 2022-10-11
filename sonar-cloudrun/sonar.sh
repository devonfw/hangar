#!/usr/bin/env bash
# Start the application
java -jar lib/sonar-application-"${SONAR_VERSION}".jar -Dsonar.log.console=true "$@"