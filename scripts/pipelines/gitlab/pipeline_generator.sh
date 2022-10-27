#!/bin/bash
set -e
FLAGS=$(getopt -a --options c:n:d:a:b:l:i:u:p:hw --long "config-file:,pipeline-name:,local-directory:,artifact-path:,target-branch:,language:,build-pipeline-name:,sonar-url:,sonar-token:,image-name:,registry-user:,registry-password:,storage-container:,cluster-name:,s3-bucket:,s3-key-path:,quality-pipeline-name:,dockerfile:,test-pipeline-name:,aws-access-key:,aws-secret-access-key:,aws-region:,package-pipeline-name:,env-provision-pipeline-name:,k8s-provider:,k8s-namespace:,k8s-deploy-files-path:,k8s-image-pull-secret-name:,help,rancher" -- "$@")

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
        --storage-container)      storageContainerName=$2; shift 2;;
        --rancher)                installRancher="true"; shift 1;;
        --cluster-name)           clusterName=$2; shift 2;;
        --s3-bucket)              s3Bucket=$2; shift 2;;
        --s3-key-path)            s3KeyPath=$2; shift 2;;
        --quality-pipeline-name)  export qualityPipelineName=$2; shift 2;;
        --test-pipeline-name)     export testPipelineName=$2; shift 2;;
        --dockerfile)             dockerFile=$2; shift 2;;
        --aws-access-key)         awsAccessKey="$2"; shift 2;;
        --aws-secret-access-key)  awsSecretAccessKey="$2"; shift 2;;
        --aws-region)             awsRegion="$2"; shift 2;;
        --package-pipeline-name)    export packagePipelineName=$2; shift 2;;
        --env-provision-pipeline-name)  envProvisionPipelineName="$2"; shift 2;;
      	--k8s-provider)             k8sProvider=$2; shift 2;;
        --k8s-namespace)            k8sNamespace="$2"; shift 2;;
      	--k8s-deploy-files-path)    k8sDeployFiles=$2; shift 2;;
        --k8s-image-pull-secret-name)  k8sImagePullSecret=$2; shift 2;;
        -h | --help)              help="true"; shift 1;;
        -w)                       webBrowser="true"; shift 1;;
        --) shift; break;;
    esac
done

# Colours for the messages.
white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

# Common var
commonTemplatesPath="scripts/pipelines/gitlab/templates/common" # Path for common files of the pipelines
pipelinePath=".pipelines" # Path to the pipelines.
scriptFilePath=".pipelines/scripts" # Path to the scripts.
gitlabCiFile=".gitlab-ci.yml"
export provider="gitlab"

function obtainHangarPath {

    # This line goes to the script directory independent of wherever the user is and then jumps 3 directories back to get the path
    hangarPath=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd ../../.. && pwd )
}

function addAdditionalArtifact {
  # Check if an extra artifact to store is supplied.
    if test ! -z "$artifactPath"
    then
        # Add the extra step to the YAML.
        grep "  artifacts:" "${localDirectory}/${pipelinePath}/${yamlFile}" > /dev/null && storeExtraPathContent="      - \"$artifactPath\""
        grep "  artifacts:" "${localDirectory}/${pipelinePath}/${yamlFile}" > /dev/null || storeExtraPathContent="\n  artifacts:\n    paths:\n      - \"$artifactPath\""
        sed -i "s/# mark to insert step for additonal artifact #/$storeExtraPathContent\n/" "${localDirectory}/${pipelinePath}/${yamlFile}"
    else
        echo "The '-a' flag has not been set, skipping the step to add additional artifact."
        sed -i '/# mark to insert step for additonal artifact #/d' "${localDirectory}/${pipelinePath}/${yamlFile}"
    fi
}

# Function that adds the variables to be used in the pipeline.
function addCommonPipelineVariables {
    if test -z "${artifactPath}"
    then
        echo "Skipping creation of the variable artifactPath as the flag has not been used."
        # Delete the commentary to set the artifactPath input/var
        sed -i '/# mark to insert additional artifact env var #/d' "${localDirectory}/${pipelinePath}/${yamlFile}"
    else
        # add the input for the additional artifact
        grep "variables:" "${localDirectory}/${pipelinePath}/${yamlFile}" > /dev/null && textArtifactPathVar="  artifactPath: ${artifactPath//\//\\/}"
        grep "variables:" "${localDirectory}/${pipelinePath}/${yamlFile}" > /dev/null || textArtifactPathVar="variables:\n  artifactPath: \"${artifactPath//\//\\/}\""
        sed -i "s/# mark to insert additional artifact env var #/$textArtifactPathVar/" "${localDirectory}/${pipelinePath}/${yamlFile}"
    fi
}

function addCiFile {
  echo -e "${green}Copying and commiting the gitlab ci file."
  echo -ne ${white}

  cp "${hangarPath}/${commonTemplatesPath}/${gitlabCiFile}" "${localDirectory}/${gitlabCiFile}"
  testCommit=$(git status)
  if echo "$testCommit" | grep "nothing to commit, working tree clean" > /dev/null
  then
    echo "gilab-ci file already present with same content, nothing to commit."
  else
    git add "${gitlabCiFile}" -f
    git commit -m "adding gitlab-ci.yml"
    git push
  fi
}

function createPR {
    # Check if a target branch is supplied.
    if test -z "$targetBranch"
    then
        # No branch specified in the parameters, no Pull Request is created, the code will be stored in the current branch.
        echo -e "${green}No branch specified to do the Pull Request, changes left in the ${sourceBranch} branch."
        exit
    else
        echo -e "${green}Creating a Pull Request..."
        echo -ne "${white}"
        repoURL=$(git config --get remote.origin.url)
        repoNameWithGit="${repoURL/https:\/\/gitlab.com\/}"
        repoName="${repoNameWithGit/.git}"
        # Create the Pull Request to merge into the specified branch.
        #debug
        echo "glab mr create -b \"$targetBranch\" -d \"merge request $sourceBranch\" -s \"$sourceBranch\" -H \"${repoName}\" -t \"merge $sourceBranch\""
        pr=$(glab mr create -b "$targetBranch" -d "merge request $sourceBranch" -s "$sourceBranch" -H "${repoName}" -t "merge $sourceBranch")

        # Create merge approval to the pull request.
        glab mr approvers "$sourceBranch" -R "${repoName}"

        #trying to merge
        if glab mr merge -s $(basename "$pr") -y
        then
            # Pull Request merged successfully.
            echo -e "${green}Pull Request merged into $targetBranch branch successfully."
            exit
        else
            # Check if the -w flag is activated.
            if [[ "$webBrowser" == "true" ]]
            then
                # -w flag is activated and a page with the corresponding Pull Request is opened in the web browser.
                echo -e "${green}Pull Request successfully created."
                echo -e "${green}Opening the Pull Request on the web browser..."
                python -m webbrowser "$pr"
                exit
            else
                # -w flag is not activated and the URL to the Pull Request is shown in the console.
                echo -e "${green}Pull Request successfully created."
                echo -e "${green}To review the Pull Request and accept it, click on the following link:"
                echo "${pr}"
                exit
            fi
        fi
    fi
}


obtainHangarPath

# Load common functions
. "$hangarPath/scripts/pipelines/common/pipeline_generator.lib"

if [[ "$help" == "true" ]]; then help; fi

ensurePathFormat

importConfigFile

checkInstallations

createNewBranch

type addPipelineVariables &> /dev/null && addPipelineVariables

copyYAMLFile

addAdditionalArtifact

copyCommonScript

type copyScript &> /dev/null && copyScript

# This function does not exists for the github pipeline generator at this moment, but I let the line with 'type' to keep the same structure as the others pipeline generator
type addCommonPipelineVariables &> /dev/null && addCommonPipelineVariables

commitCommonFiles

type commitFiles &> /dev/null && commitFiles

addCiFile

createPR