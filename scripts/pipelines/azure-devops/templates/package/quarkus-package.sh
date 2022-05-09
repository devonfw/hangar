#!/bin/bash
################################ Description ############################################
# This script is used to build and push a quarkus project image to a container registry
################################# Arguments #############################################
# -t : Path to the pom.xml
#########################################################################################
set -e

while getopts t: flag
do
    case "${flag}" in
        t) pomPath=${OPTARG};;
    esac
done
# We define the tag using the version set in the pom.xml
tag=$(grep version "${pomPath}" | grep -v -e '<?xml'| head -n 1 | sed 's/[[:space:]]//g' | sed -E 's/<.{0,1}version>//g' | awk '{print $1}')

SCRIPT_PATH="./generic-package.sh"
# shellcheck source="./generic-package.sh"
source "$SCRIPT_PATH" "$@" -q "$tag"