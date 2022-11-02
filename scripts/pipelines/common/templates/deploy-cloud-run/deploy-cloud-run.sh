#!/bin/bash
set -e

projectId="$1"
branch="$2"
serviceName="$3"
imageName="$4"
gCloudRegion="$5"
port="$6"
. "$(dirname "$0")/package-extra.sh"
# we get what is located after the last '/' in the branch name, so it removes /ref/head or /ref/head/<folder> if your branche is named correctly"
branch_short=$(echo "$branch" | awk -F '/' '{ print $NF }')

# We change the name of the tag depending if it is a release or another branch
echo "$branch" | grep release && tag_completed="${tag}"
echo "$branch" | grep release || tag_completed="${tag}_${branch_short}"

gcloud run deploy "$serviceName" --image="${imageName}:${tag_completed}" --region="$gCloudRegion" --port="$port" --allow-unauthenticated --revision-suffix="${branch_short}-$(date +%Y%m%d-%H%M)"