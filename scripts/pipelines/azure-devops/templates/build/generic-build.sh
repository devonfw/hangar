#!/bin/bash

# Install taskfile
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d

cd "./.pipelines/scripts" || { echo -e "${red}Error: ./.pipelines/scripts could not be found." >&2; exit 1; }

# We take the first 2 elements of the array because the vso command has a space and is therefore split up by bash.
vsoCommand=$(../../bin/task build-configuration | { read -r -a array ; echo "${array[@]:0:2}" ; })
echo "$vsoCommand"

../../bin/task build