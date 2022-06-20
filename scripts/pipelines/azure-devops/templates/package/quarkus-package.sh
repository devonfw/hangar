#!/bin/bash
################################ Description ############################################
# This script is used to build and push a quarkus project image to a container registry
################################# Arguments #############################################
# -f : Path to the dockerfile
# -c : The context of the build (in our case, the repository cloned and the build application are not in the same directory, we need to execute the docker build knowing that)
# -u : Username to connect to the registry
# -p : Password to connect to the registry
# -r : Registry used to store the image
# -i : Name of the image (containing the name of the registry and the path to the image)
# -b : Name of the branch from where the version is coming
# -t : Path to the pom.xml
#########################################################################################
set -e

while getopts f:c:u:p:r:i:b:t:a:s:l: flag
do
    case "${flag}" in
        f) dockerFile=${OPTARG};;
        c) context=${OPTARG};;
        u) username=${OPTARG};;
        p) password=${OPTARG};;
        r) registry=${OPTARG};;
        i) imageName=${OPTARG};;
        b) branch=${OPTARG};;
        t) pomPath=${OPTARG};;
        a) aws_access_key=${OPTARG};;
        s) aws_secret_access_key=${OPTARG};;
        l) region=${OPTARG};;
        *) echo "flag ${flag} not specified"
    esac
done

# We define the tag using the version set in the pom.xml
tag=$(grep version "${pomPath}" | grep -v -e '<?xml'| head -n 1 | sed 's/[[:space:]]//g' | sed -E 's/<.{0,1}version>//g' | awk '{print $1}')

SCRIPT_PATH="./.pipelines/scripts/package-common.sh"
# shellcheck source="package-common.sh"
source "$SCRIPT_PATH" -q "$tag"