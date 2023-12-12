#!/bin/bash
projectKey=$(python -c "from json import load; print(load(open('./package.json', 'r'))['name']);")

npx sonar-scanner -Dsonar.host.url="$SONAR_URL" -Dsonar.login="$SONAR_TOKEN" -Dsonar.projectKey=$projectKey -Dsonar.javascript.lcov.reportPaths=lcov.info -Dsonar.sources="."