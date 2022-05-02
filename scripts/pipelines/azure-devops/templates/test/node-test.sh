#!/bin/bash
npm install jest
npm install jest-junit
JEST_SUITE_NAME="jest tests" JEST_JUNIT_OUTPUT_NAME="TEST-junit.xml" JEST_JUNIT_OUTPUT_DIR="./test-data" npm run test -- --ci --reporters=default --reporters=jest-junit
