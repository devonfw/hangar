#!/bin/bash
set -e

projectId="$1"
branch="$2"

. "$(dirname "$0")/package-extra.sh"
# we get what is located after the last '/' in the branch name, so it removes /ref/head or /ref/head/<folder> if your branche is named correctly"
branch_short=$(echo "$branch" | awk -F '/' '{ print $NF }')

# We change the name of the tag depending if it is a release or another branch
echo "$branch" | grep release && tag_completed="${tag}"
echo "$branch" | grep release || tag_completed="${tag}_${branch_short}"

gcloud run deploy $_SERVICE_NAME --image=${_IMAGE_NAME}:${tag_completed} --region=$_GCLOUD_REGION --port=$_PORT --allow-unauthenticated --revision-suffix=${tag_completed}