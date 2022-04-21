#!/bin/bash
npm install mocha
npm install chai
npm install mocha-junit-reporter
npx mocha test --reporter mocha-junit-reporter --reporter-options mochaFile=./test/TEST-results.xml