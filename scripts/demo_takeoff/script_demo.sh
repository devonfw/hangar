#!/bin/bash
set -x
trap read debug

project_id=$1
rm -r local_hangar
rm -r example_folder/.git

gcloud config set account abel-antonio.carrion-collado@capgemini.com
./create-project.sh -h
./create-project.sh -n $project_id -d "Testing the Demo"
gcloud projects list
./create-bindings.sh -h
./create-bindings.sh -s sa-test -p $project_id -f ./gke-predefined-roles.txt
./verify-account-roles.sh -h
cat gke-predefined-roles.txt
./verify-account-roles.sh -s sa-test -p $project_id -f ./gke-predefined-roles.txt
gcloud auth activate-service-account --key-file=./key.json
gcloud auth list
mkdir local_hangar
./create-repo.sh -a import -g https://github.com/devonfw/hangar.git -s gitflow -p $project_id -n hangar_imported -d local_hangar
./create-repo.sh -a import -d example_folder -p $project_id -n my_imported_repo
./validate-cloudrun.sh -h
./validate-cloudrun.sh -p $project_id -r europe-southwest1
