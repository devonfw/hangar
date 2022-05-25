#!/bin/bash
################################ Description ############################################
# This script is used to build and push an angular project image to a container registry
################################# Arguments #############################################
# -t : Path to the package.json
#########################################################################################
set -e

while getopts f:c:u:p:r:i:b:a:s:l:t: flag
do
    case "${flag}" in
        f) ;; c) ;; u) ;; p) ;; r) ;; i) ;; b) ;; a) ;; s) ;; l) ;;
        t) packagePath=${OPTARG};;
        *) echo "flag ${flag} not specified"
    esac
done

# We define the tag using the version set in the package.json
tag=$(grep version "${packagePath}" | sed 's/.*"version": "\(.*\)".*/\1/')

# filter -t tag from arguments
args=("${@}")
filter="-t"

for ((i=0; i<"${#args[@]}"; ++i));
do
    case ${args[i]} in
        "$filter") unset "args[i]"; unset "args[i+1]"; break ;;
    esac
done

SCRIPT_PATH="./.pipelines/scripts/package-common.sh"
# shellcheck source="package-common.sh"
source "$SCRIPT_PATH" "${args[@]}" -q "$tag"
