#!/bin/bash
set -e

while getopts d:u:p:r:i:b:a:s:l:n:g:t: flag
do
    case "${flag}" in
        d) projectId=${OPTARG};;
        u) dockerUser=${OPTARG};;
        p) dockerPassword=${OPTARG};;
        r) registry=${OPTARG};;
        i) imageName=${OPTARG};;
        b) branch=${OPTARG};;
        a) awsAccessKey=${OPTARG};;
        s) awsSecretAccessKey=${OPTARG};;
        l) awsRegion=${OPTARG};;
        n) serviceName=${OPTARG};;
        g) gCloudRegion=${OPTARG};;
        t) port=${OPTARG};;
        *) echo "Error: Unexpected flag." >&2
            exit 1;;
    esac
done

. "$(dirname "$0")/package-extra.sh"
# we get what is located after the last '/' in the branch name, so it removes /ref/head or /ref/head/<folder> if your branche is named correctly"
branch_short=$(echo "$branch" | awk -F '/' '{ print $NF }')

# We change the name of the tag depending if it is a release or another branch
echo "$branch" | grep release && tag_completed="${tag}"
echo "$branch" | grep release || tag_completed="${tag}_${branch_short}"

# If the registry is not the Google Cloud Artifact Registry, we need to push it to a temporary one
if ! { [[ "$registry" =~ .*docker.pkg.dev.* ]] || [[ "$registry" =~ .*gcr.io.* ]] ; }
then
  # If in AWS
  if [ "$awsAccessKey" == "" ]
  then
    docker login -u "$dockerUser " -p "$dockerPassword" "$registry"
  # other registries
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
