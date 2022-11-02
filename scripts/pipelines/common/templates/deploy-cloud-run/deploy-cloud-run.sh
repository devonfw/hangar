#!/bin/bash
set -e

projectId="$1"
branch="$2"
serviceName="$3"
imageName="$4"
gCloudRegion="$5"
port="$6"
registry="$7"
dockerUser="$8"
dockerPassword="$9"
awsAccessKey="${10}"
awsSecretAccessKey="${11}"
awsRegion="${12}"


. "$(dirname "$0")/package-extra.sh"
# we get what is located after the last '/' in the branch name, so it removes /ref/head or /ref/head/<folder> if your branche is named correctly"
branch_short=$(echo "$branch" | awk -F '/' '{ print $NF }')

# We change the name of the tag depending if it is a release or another branch
echo "$branch" | grep release && tag_completed="${tag}"
echo "$branch" | grep release || tag_completed="${tag}_${branch_short}"

# If the registry is not the google cloud artifact registry, we need to push it to a tenmporary one
if ! { [[ "$registry" =~ .*docker.pkg.dev.* ]] || [[ "$registry" =~ .*gcr.io.* ]] }
then
  # If in AWS
  if [ "$awsAccessKey" == "" ]
  then
    docker login -u "$dockerUser " -p "$dockerPassword" "$registry"
  # other regitries
  else
    aws configure set aws_access_key_id "$awsAccessKey"
    aws configure set aws_secret_access_key "$awsSecretAccessKey"
    echo "aws ecr get-login-password --region $awsRegion | docker login --username AWS --password-stdin $registry"
    aws ecr get-login-password --region "$awsRegion" | docker login --username AWS --password-stdin "$registry"
  fi
  [[ $(gcloud artifacts repositories list | awk  '$1=="temporaryrepo" {print $1}') != "" ]] || gcloud artifacts repositories create temporaryrepo --repository-format=docker --location="$gCloudRegion"
  docker pull "$imageName:${tag_completed}"
  docker tag "$imageName:${tag_completed}" "${gCloudRegion}-docker.pkg.dev/${projectId}/temporaryrepo/temporaryimage:latest"
  docker push "${gCloudRegion}-docker.pkg.dev/${projectId}/temporaryrepo/temporaryimage:latest"
  gcloud run deploy "$serviceName" --image="${gCloudRegion}-docker.pkg.dev/${projectId}/temporaryrepo/temporaryimage:latest" --region="$gCloudRegion" --port="$port" --allow-unauthenticated --revision-suffix="${branch_short}-$(date +%Y%m%d-%H%M)"
  gcloud artifacts docker tags delete "${gCloudRegion}-docker.pkg.dev/${projectId}/temporaryrepo/temporaryimage:latest" --quiet
else
  gcloud run deploy "$serviceName" --image="${imageName}:${tag_completed}" --region="$gCloudRegion" --port="$port" --allow-unauthenticated --revision-suffix="${branch_short}-$(date +%Y%m%d-%H%M)"
fi
