#!/bin/bash
npm install
npm install jest-junit
JEST_SUITE_NAME="jest tests" JEST_JUNIT_OUTPUT_NAME="TEST-junit.xml" JEST_JUNIT_OUTPUT_DIR="." npm run test -- --ci --coverage --reporters=default --reporters=jest-junit
mv ./coverage/lcov.info ./lcov.info
#projectKey=$(python -c "from json import load; print(load(open('./package.json', 'r'))['name']);")
#npx sonar-scanner -Dsonar.host.url="$SONAR_URL" -Dsonar.login="$SONAR_TOKEN" -Dsonar.projectKey=$projectKey -Dsonar.javascript.lcov.reportPaths=lcov.info -Dsonar.sources="."
