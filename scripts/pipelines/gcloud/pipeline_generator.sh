#!/bin/bash
set -e
FLAGS=$(getopt -a --options c:n:d:a:b:l:i:u:p:h --long "config-file:,pipeline-name:,local-directory:,artifact-path:,target-branch:,language:,build-pipeline-name:,sonar-url:,sonar-token:,image-name:,registry-user:,registry-password:,resource-group:,storage-account:,storage-container:,cluster-name:,s3-bucket:,s3-key-path:,quality-pipeline-name:,dockerfile:,test-pipeline-name:,aws-access-key:,aws-secret-access-key:,aws-region:,ci-pipeline-name:,help" -- "$@")

eval set -- "$FLAGS"
while true; do
    case "$1" in
        -c | --config-file)       configFile=$2; shift 2;;
        -n | --pipeline-name)     export pipelineName=$2; shift 2;;
        -d | --local-directory)   localDirectory=$2; shift 2;;
        -a | --artifact-path)     artifactPath=$2; shift 2;;
        -b | --target-branch)     targetBranch=$2; shift 2;;
        -l | --language)          language=$2; shift 2;;
        --build-pipeline-name)    export buildPipelineName=$2; shift 2;;
        --sonar-url)              sonarUrl=$2; shift 2;;
        --sonar-token)            sonarToken=$2; shift 2;;
        -i | --image-name)        imageName=$2; shift 2;;
        -u | --registry-user)     dockerUser=$2; shift 2;;
        -p | --registry-password) dockerPassword=$2; shift 2;;
        --resource-group)         resourceGroupName=$2; shift 2;;
        --storage-account)        storageAccountName=$2; shift 2;;
        --storage-container)      storageContainerName=$2; shift 2;;
        --cluster-name)           clusterName=$2; shift 2;;
        --s3-bucket)              s3Bucket=$2; shift 2;;
        --s3-key-path)            s3KeyPath=$2; shift 2;;
        --quality-pipeline-name)  export qualityPipelineName=$2; shift 2;;
        --test-pipeline-name)     export testPipelineName=$2; shift 2;;
        --ci-pipeline-name)       export ciPipelineName=$2; shift 2;;
        --dockerfile)             dockerFile=$2; shift 2;;
        --aws-access-key)         awsAccessKey="$2"; shift 2;;
        --aws-secret-access-key)  awsSecretAccessKey="$2"; shift 2;;
        --aws-region)             awsRegion="$2"; shift 2;;
        -h | --help)              help="true"; shift 1;;
        --) shift; break;;
    esac
done

# Colours for the messages.
white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

# Common var
commonTemplatesPath="scripts/pipelines/gcloud/templates/common" # Path for common files of the pipelines
pipelinePath=".pipelines" # Path to the pipelines.
scriptFilePath=".pipelines/scripts" # Path to the scripts.
export provider="gcloud"
pipeline_type="pipeline"

function obtainHangarPath {

    # This line goes to the script directory independent of wherever the user is and then jumps 3 directories back to get the path
    hangarPath=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd ../../.. && pwd )
}

# Function that adds the variables to be used in the pipeline.
function addCommonPipelineVariables {
    if test -z "${artifactPath}"
    then
        echo "Skipping creation of the variable artifactPath as the flag has not been used."
    else
        [[ "$subsitutionVariable" == "" ]] && artifactPathSubStr="_ARTIFACT_PATH=${artifactPath}" || artifactPathSubStr=",_ARTIFACT_PATH=${artifactPath}"
    fi

}

function merge_branch {
    # Check if a target branch is supplied.
    if test -z "$targetBranch"
    then
        # No branch specified in the parameters, no Pull Request is created, the code will be stored in the current branch.
        echo -e "${green}No branch specified to do the merge, changes left in the ${sourceBranch} branch.${white}"
    else
        echo -e "${green}Checking out to the target branch."
        echo -ne "${white}"
        git checkout "$targetBranch"
        echo "Trying to merge"
        git merge "$sourceBranch"
        git push
        git branch -D "$sourceBranch" ; git push origin --delete "$sourceBranch"
    fi
}

function createTrigger {
    cd -- "$localDirectory"
    gitOriginUrl=$(git config --get remote.origin.url)
    gCloudProject=$(echo "$gitOriginUrl" | cut -d'/' -f5)
    gCloudRepo=$(echo "$gitOriginUrl" | cut -d'/' -f7)
    # We check if the bucket we needed exists, we create it if not
    if (gcloud storage ls --project="${gCloudProject}" | grep "${gCloudProject}_cloudbuild" >> /dev/null)
    then
      echo -e "${green}Bucket ${gCloudProject}_cloudbuild already exists.${white}"
    else
      echo -e "${green}The bucket ${gCloudProject}_cloudbuild does not exist, creating it...${white}"
      gcloud storage buckets create "gs://${gCloudProject}_cloudbuild" --project="${gCloudProject}"
    fi
    # We create the trigger
    gcloud beta builds triggers create cloud-source-repositories --repo="$gCloudRepo" --branch-pattern="$branchTrigger"  --build-config="${pipelinePath}/${yamlFile}" --project="$gCloudProject" --name="$pipelineName" --description="$triggerDescription" --substitutions "${subsitutionVariable}${artifactPathSubStr}"
}

obtainHangarPath

# Load common functions
. "$hangarPath/scripts/pipelines/common/pipeline_generator.lib"

if [[ "$help" == "true" ]]; then help; fi

ensurePathFormat

checkInstallations

validateRegistryLoginCredentials

importConfigFile

createNewBranch

type addPipelineVariables &> /dev/null && addPipelineVariables

type addCommonPipelineVariables &> /dev/null && addCommonPipelineVariables

copyYAMLFile

copyCommonScript

type copyScript &> /dev/null && copyScript

commitCommonFiles

type commitFiles &> /dev/null && commitFiles

createTrigger

merge_branch
