#!/bin/bash
# We define the tag using the version set in the package.json
imageTagFilePath="package.json"
tag=$(awk -F'"' '/"version": ".+"/{ print $4; exit; }' "${imageTagFilePath}")
