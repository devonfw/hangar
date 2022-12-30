#!/bin/bash
npm install jest-junit
JEST_SUITE_NAME="jest tests" JEST_JUNIT_OUTPUT_NAME="TEST-junit.xml" JEST_JUNIT_OUTPUT_DIR="." npm run test -- --ci --coverage --reporters=default --reporters=jest-junit
mv ./coverage/lcov.info ./lcov.info