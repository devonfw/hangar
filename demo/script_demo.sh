#!/bin/bash
set -x
set -e
trap read debug

project_id="$1"
repo_path="$2"
language="$3"
git config --global user.email "bob@example.com"
git config --global user.name "Bob"


# Prerequisites:
#   - project already created with all API enabled and roles given
#   - repo already created with a develop branch
#   - Variable for gcloud sonarqube already set correctly
#   - be located in the root of the repository to execute this script


# Additional info:
#   Change the password, image name, port in the package part

# Set up Sonarqube
# (cd scripts/sonarqube/gcloud; terraform init; terraform apply -auto-approve)


######################
# Setting up pipeleine
######################

# Build pipeline
scripts/pipelines/gcloud/pipeline_generator.sh -c scripts/pipelines/gcloud/templates/build/build-pipeline.cfg -n build-trigger-demo3 -d "$repo_path" -l "$language" -b develop

# Test pipeline
scripts/pipelines/gcloud/pipeline_generator.sh -c scripts/pipelines/gcloud/templates/test/test-pipeline.cfg -n test-trigger-demo3 -d "$repo_path" -l "$language" --build-pipeline-name build-trigger-demo3 -b develop

# Quality pipeline
#   We first get the token:
echo -e "\e[33mPlease give the URL and the token for the sonarqube connection:\e[0m"
echo "Use this command to get it: 'curl -X POST -H \"Content-Type: application/x-www-form-urlencoded\" -d \"name=testToken\" -u admin:admin http://<ip>:9000/api/user_tokens/generate"
echo "SONAR_URL:"
read -r SONAR_URL
echo "SONAR_TOKEN:"
read -r SONAR_TOKEN
scripts/pipelines/gcloud/pipeline_generator.sh -c scripts/pipelines/gcloud/templates/quality/quality-pipeline.cfg -n quality-trigger-demo3 -d "$repo_path" -l "$language" --build-pipeline-name build-trigger-demo3 --sonar-url $SONAR_URL --sonar-token $SONAR_TOKEN -b develop


# Package pipeline
# Change password with yours
scripts/pipelines/gcloud/pipeline_generator.sh -c scripts/pipelines/gcloud/templates/package/package-pipeline.cfg -n package-trigger-demo3 -d "$repo_path" -l "$language" --build-pipeline-name build-trigger-demo3 -i ultimatom/demo-gcloud -u ultimatom -p Hangar12345! -b develop

# Deploy in cloud run pipeline
scripts/pipelines/gcloud/pipeline_generator.sh -c scripts/pipelines/gcloud/templates/deploy-cloud-run/deploy-cloud-run-pipeline.cfg -n deploy-cloud-run-trigger-demo3 -d "$repo_path" --port 3000 --service-name demo3-ensayo --gcloud-region europe-southwest1 -b develop


