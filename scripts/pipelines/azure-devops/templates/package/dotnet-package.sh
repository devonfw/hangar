#!/bin/bash
# We define the tag using the version set in one of the modules (since there is no version given in a template!)
tag=tag=$(xmllint --xpath "string(//Project/PropertyGroup/Version/text())" "${imageTagFilePath}")