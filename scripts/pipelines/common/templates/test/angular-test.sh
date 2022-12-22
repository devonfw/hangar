#!/bin/bash

npm install @angular/cli@latest

npm run test -- --karma-config ./karma.conf.js --no-watch --no-progress --browsers=ChromeHeadless
mv ./coverage/lcov.info ./lcov.info