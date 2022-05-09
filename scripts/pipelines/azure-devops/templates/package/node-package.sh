#!/bin/bash
################################ Description ############################################
# This script is used to build and push a node project image to a container registry
################################# Arguments #############################################
# -t : Path to the package.json
#########################################################################################
set -e

while getopts t: flag
do
    case "${flag}" in
        t) packagePath=${OPTARG};;
    esac
done

# We define the tag using the version set in the package.json
tag=$(grep version "${packagePath}" | sed 's/.*"version": "\(.*\)".*/\1/')

SCRIPT_PATH="./generic-package.sh"
# shellcheck source="./generic-package.sh"
source "$SCRIPT_PATH" "$@" -q "$tag"
