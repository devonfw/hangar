#!/bin/bash
npm install
npm run test -- --ci --reporters=default --reporters=jest-junit
