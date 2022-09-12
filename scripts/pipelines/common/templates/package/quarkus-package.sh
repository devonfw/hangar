#!/bin/bash
# We define the tag using the version set in the pom.xml
imageTagFilePath="pom.xml"
tag=$(grep version "${imageTagFilePath}" | grep -v -e '<?xml'| head -n 1 | sed 's/[[:space:]]//g' | sed -E 's/<.{0,1}version>//g' | awk '{print $1}')