#!/bin/bash
################################ Description ############################################
# This script is used to build and push a quarkus project image to a container registry
################################# Arguments #############################################
# -t : Path to the pom.xml
#########################################################################################
set -e

while getopts f:c:u:p:r:i:b:a:s:l:t: flag
do
    case "${flag}" in
        f) ;; c) ;; u) ;; p) ;; r) ;; i) ;; b) ;; a) ;; s) ;; l) ;;
        t) pomPath=${OPTARG};;
        *) echo "flag ${flag} not specified"
    esac
done
# We define the tag using the version set in the pom.xml
tag=$(grep version "${pomPath}" | grep -v -e '<?xml'| head -n 1 | sed 's/[[:space:]]//g' | sed -E 's/<.{0,1}version>//g' | awk '{print $1}')

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