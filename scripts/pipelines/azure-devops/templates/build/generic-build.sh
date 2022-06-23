#!/bin/bash

sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d

cd "./.pipelines/scripts"

# We take the first 2 elements of the array because the vso command has a space and is therefore split up by bash.
vsoCommand=$(../../bin/task build-configuration | { read -a array ; echo ${array[@]:0:2} ; })
echo $vsoCommand

../../bin/task build