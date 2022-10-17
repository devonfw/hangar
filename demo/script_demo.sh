#!/bin/bash
set -x
trap read debug

project_id=$1
#rm -r demoapp
#rm -r example_folder/.git

# exit when any command fails
set -e
# keep track of the last executed command
#trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
#trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT 
git config --global user.email "bob@example.com"
git config --global user.name "Bob"
gcloud auth login
#gcloud config set account miguel-angel.cerver-copovi@capgemini.com
../scripts/accounts/gcloud/create-project.sh -h
../scripts/accounts/gcloud/create-project.sh -n $project_id -d "Testing the Demo" -b 019474-7EADFB-04C80A
gcloud projects list
../scripts/accounts/gcloud/setup-principal-account.sh -h
../scripts/accounts/gcloud/setup-principal-account.sh -s sa-test -p $project_id -f ../scripts/accounts/gcloud/predefined-roles.txt
../scripts/accounts/gcloud/verify-principal-roles-and-permissions.sh -h
#cat ../scripts/accounts/gcloud/predefined-roles.txt
../scripts/accounts/gcloud/verify-principal-roles-and-permissions.sh -s sa-test -p $project_id -f ../scripts/accounts/gcloud/predefined-roles.txt
gcloud auth activate-service-account --key-file=./key.json
gcloud auth list
mkdir demoapp
../scripts/repositories/gcloud/create-repo.sh -a import -g https://github.com/albertdb/k8s-hello-node.git -s gitflow -p $project_id -n demoapprepo -d demoapp
#./create-repo.sh -a import -d example_folder -p $project_id -n my_imported_repo
#../scripts/validate-cloudrun.sh -h
#../scripts/validate-cloudrun.sh -p $project_id -r europe-southwest1
gcloud storage buckets create gs://${project_id}_cloudbuild
../scripts/pipelines/gcloud/pipeline_generator.sh -c ../scripts/pipelines/gcloud/templates/build/build-pipeline.cfg -n build-trigger -d demoapp/demoapprepo/ -l node -b master