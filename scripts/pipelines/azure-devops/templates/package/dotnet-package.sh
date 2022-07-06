#!/bin/bash
# We define the tag using the version set in the pom.xml
tag=$(echo 'cat //Project/ItemGroup/PackageReference[@Include="Devon4Net.Infrastructure.Common"]/@Version' | xmllint --shell "${imageTagFilePath}" | awk -F'[="]' '!/>/{print $(NF-1)}')