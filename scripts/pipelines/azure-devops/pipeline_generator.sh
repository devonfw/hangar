#!/bin/bash
set -e
FLAGS=$(getopt -a --options c:n:d:a:b:l:t:i:u:p:hw --long "config-file:,pipeline-name:,local-directory:,artifact-path:,target-branch:,language:,target-directory:,build-pipeline-name:,sonar-url:,sonar-token:,image-name:,registry-user:,registry-password:,resource-group:,storage-account:,storage-container:,cluster-name:,s3-bucket:,s3-key-path:,quality-pipeline-name:,dockerfile:,test-pipeline-name:,aws-access-key:,aws-secret-access-key:,aws-region:,rancher:,package-pipeline-name:,env-provision-pipeline-name:,k8s-provider:,k8s-namespace:,k8s-deploy-files-path:,k8s-image-pull-secret-name:,help" -- "$@")
eval set -- "$FLAGS"
while true; do
    case "$1" in
        -c | --config-file)         configFile=$2; shift 2;;
        -n | --pipeline-name)       pipelineName=$2; shift 2;;
        -d | --local-directory)     localDirectory=$2; shift 2;;
        -a | --artifact-path)       artifactPath=$2; shift 2;;
        -b | --target-branch)       targetBranch=$2; shift 2;;
        -l | --language)            language=$2; shift 2;;
        -t | --target-directory)    targetDirectory=$2; shift 2;;
        --build-pipeline-name)      export buildPipelineName=$2; shift 2;;
        --sonar-url)                sonarUrl=$2; shift 2;;
        --sonar-token)              sonarToken=$2; shift 2;;
        -i | --image-name)          imageName=$2; shift 2;;
        -u | --registry-user)       dockerUser=$2; shift 2;;
        -p | --registry-password)   dockerPassword=$2; shift 2;;
        --resource-group)           resourceGroupName=$2; shift 2;;
        --storage-account)          storageAccountName=$2; shift 2;;
        --storage-container)        storageContainerName=$2; shift 2;;
        --rancher)                  installRancher="true"; shift 1;;
        --cluster-name)             clusterName=$2; shift 2;;
        --s3-bucket)                s3Bucket=$2; shift 2;;
        --s3-key-path)              s3KeyPath=$2; shift 2;;
        --quality-pipeline-name)    export qualityPipelineName=$2; shift 2;;
        --test-pipeline-name)       export testPipelineName=$2; shift 2;;
        --dockerfile)               dockerFile=$2; shift 2;;
        --aws-access-key)           awsAccessKey="$2"; shift 2;;
        --aws-secret-access-key)    awsSecretAccessKey="$2"; shift 2;;
        --aws-region)               awsRegion="$2"; shift 2;;
      	--package-pipeline-name)    export packagePipelineName=$2; shift 2;;
        --env-provision-pipeline-name)  envProvisionPipelineName="$2"; shift 2;;
      	--k8s-provider)             k8sProvider=$2; shift 2;;
        --k8s-namespace)            k8sNamespace="$2"; shift 2;;
      	--k8s-deploy-files-path)    k8sDeployFiles=$2; shift 2;;
        --k8s-image-pull-secret-name)  k8sImagePullSecret=$2; shift 2;;
        -h | --help)                help="true"; shift 1;;
        -w)                         webBrowser="true"; shift 1;;
        --) shift; break;;
    esac
done

# Colours for the messages.
white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

# Common var
commonTemplatesPath="scripts/pipelines/azure-devops/templates/common" # Path for common files of the pipelines
pipelinePath=".pipelines" # Path to the pipelines.
scriptFilePath=".pipelines/scripts" # Path to the scripts.
export provider="azure-devops"
pipeline_type="pipeline"

function obtainHangarPath {

    # This line goes to the script directory independent of wherever the user is and then jumps 3 directories back to get the path
    hangarPath=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd ../../.. && pwd )
}

function addAdditionalArtifact {
  # Check if an extra artifact to store is supplied.
    if test ! -z "$artifactPath"
    then
        # Add the extra step to the YAML.
        cat "${hangarPath}/${commonTemplatesPath}/store-extra-path.yml" >> "${localDirectory}/${pipelinePath}/${yamlFile}"
    else
        echo "The '-a' flag has not been set, skipping the step to add additional artifact."
    fi
}

function createPipeline {
    echo -e "${green}Generating the pipeline from the YAML template..."
    echo -ne ${white}

    # This line go to the localDirectory of the repo and gets the repo name
    repoName="$(basename -s .git "$(git config --get remote.origin.url)")"
    # This line gets the organization name
    orgName="$(git remote -v | grep fetch | cut -d'/' -f4)"

    azRepoShow=$(az repos show -r "$repoName")
    projectName=$(echo "$azRepoShow" | python -c "import sys, json; print(json.load(sys.stdin)['project']['name'])")

    # Create Azure Pipeline
    az pipelines create --name $pipelineName --yml-path "${pipelinePath}/${yamlFile}" --skip-first-run true --organization "https://dev.azure.com/$orgName" --project "$projectName" --repository "$repoName" --repository-type tfsgit
}

# Function that adds the variables to be used in the pipeline.
function addCommonPipelineVariables {
    if test -z ${artifactPath}
    then
        echo "Skipping creation of the variable artifactPath as the flag has not been used."
    else
        # Add the extra artifact to store variable.
        az pipelines variable create --name "artifactPath" --pipeline-name "$pipelineName" --value "${artifactPath}"
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
        echo -ne ${white}
        # Create the Pull Request to merge into the specified branch.
        pr=$(az repos  pr create --source-branch ${sourceBranch} --target-branch $targetBranch --title "Pipeline" --auto-complete true)

        # Obtain the PR id.
        id=$(echo "$pr" | python -c "import sys, json; print(json.load(sys.stdin)['pullRequestId'])")

        # Obtain the PR status.
        showOutput=$(az repos pr show --id $id)
        status=$(echo "$showOutput" | python -c "import sys, json; print(json.load(sys.stdin)['status'])")

        # Check if the Pull Request merge has succeeded.
        if test "$status" = "completed"
        then
            # Pull Request merged successfully.
            echo -e "${green}Pull Request merged into $targetBranch branch successfully."
            exit
        else
            # Obtain the PR URL.
            url=$(echo "$showOutput" | python -c "import sys, json; print(json.load(sys.stdin)['repository']['webUrl'])")
            prURL="$url/pullrequest/$id"

            # Check if the -w flag is activated.
            if [[ "$webBrowser" == "true" ]]
            then
                # -w flag is activated and a page with the corresponding Pull Request is opened in the web browser.
                echo -e "${green}Pull Request successfully created."
                echo -e "${green}Opening the Pull Request on the web browser..."
                az repos pr show --id $id --open > /dev/null
                exit
            else
                # -w flag is not activated and the URL to the Pull Request is shown in the console.
                echo -e "${green}Pull Request successfully created."
                echo -e "${green}To review the Pull Request and accept it, click on the following link:"
                echo ${prURL}
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

checkInstallations

validateRegistryLoginCredentials

importConfigFile

createNewBranch

copyYAMLFile

addAdditionalArtifact

copyCommonScript

type copyScript &> /dev/null && copyScript

commitCommonFiles

type commitFiles &> /dev/null && commitFiles

createPipeline

type addPipelineVariables &> /dev/null && addPipelineVariables

addCommonPipelineVariables

createPR
