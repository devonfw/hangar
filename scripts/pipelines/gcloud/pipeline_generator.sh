#!/bin/bash
set -e
FLAGS=$(getopt -a --options c:n:d:a:b:l:i:u:p:m:h --long "config-file:,pipeline-name:,local-directory:,artifact-path:,target-branch:,language:,build-pipeline-name:,sonar-url:,sonar-token:,image-name:,registry-user:,registry-password:,resource-group:,storage-account:,storage-container:,cluster-name:,s3-bucket:,s3-key-path:,quality-pipeline-name:,dockerfile:,test-pipeline-name:,aws-access-key:,aws-secret-access-key:,aws-region:,ci-pipeline-name:,help,registry-location:,flutter-web-renderer:,machine-type:,language-version:,service-name:,gcloud-region:,port:,flutter-platform:,secret-vars:,env-vars:,rancher:" -- "$@")

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
        --registry-location)      export registryLocation=$2; shift 2;;
        --flutter-platform)       export flutterPlatform=$2; shift 2;;
        --flutter-web-renderer)   export flutterWebRenderer=$2; shift 2;;
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
        --service-name)           serviceName="$2"; shift 2;;
        --gcloud-region)          gCloudRegion="$2"; shift 2;;
        --port)                   port="$2"; shift 2;;
        -h | --help)              help="true"; shift 1;;
        -m | --machine-type)      machineType="$2"; shift 2;;
        --language-version)       languageVersion="$2"; shift 2;;
        --secret-vars)            secretVars="$2"; shift 2;;
        --env-vars)               envVars="$2"; shift 2;;
        --rancher)                installRancher="true"; shift 1;;
        --) shift; break;;
    esac
done

# Colours for the messages.
white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

# Common var
commonTemplatesPath="scripts/pipelines/gcloud/templates/common" # Path for common files of the pipelines
commonPipelineTemplatesPath="scripts/pipelines/common/templates/" # Path for common files of the pipelines
pipelinePath=".pipelines" # Path to the pipelines.
scriptFilePath=".pipelines/scripts" # Path to the scripts.
export provider="gcloud"
pipeline_type="pipeline"
configFilePath=".pipelines/config" # Path to the scripts.


function obtainHangarPath {

    # This line goes to the script directory independent of wherever the user is and then jumps 3 directories back to get the path
    hangarPath=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd ../../.. && pwd )
}

function checkMachineType {

    # The type of machine can only be two possible values:
    if [[ "$machineType" != "E2_HIGHCPU_8" ]] && [[ "$machineType" != "E2_HIGHCPU_32" ]] && [[ "$machineType" != "N1_HIGHCPU_8" ]] && [[ "$machineType" != "N1_HIGHCPU_32" ]]
    then
      echo -e "${red}Error: Chosen machine type is not a valid one." >&2
      echo -e "${red}Use -h or --help flag to display help." >&2
      echo -e "${red}Also check official documentation: https://cloud.google.com/build/docs/api/reference/rest/v1/projects.builds?hl=en#machinetype" >&2
      echo -ne "${white}" >&2
      exit 2
    fi
}

function getProjectRepo {
  # Function used to get the repo name and project ID
  cd "$localDirectory"
  gitOriginUrl=$(git config --get remote.origin.url)
  gCloudProject=$(echo "$gitOriginUrl" | cut -d'/' -f5)
  export gCloudProject
  gCloudRepo=$(echo "$gitOriginUrl" | cut -d'/' -f7)
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

function addMachineType {
  echo -e "${green}Setting machine type value on pipeline.${white}"
  {
    echo ""
    echo "options:"
    echo "  machineType: $machineType"
  } >> "${localDirectory}/${pipelinePath}/${yamlFile}"

}

function addTriggers {
    case "$previousPipelineyaml" in
        "")
            echo -e "Previous pipeline is not defined. Skipping adding trigger function."
            ;;
        "build-pipeline.yml")
            echo -e "${green}Previous pipeline defined. Adding trigger inside: ${localDirectory}/${pipelinePath}/${previousPipelineyaml}.${white}."
            sed -e "s/# mark to insert trigger/- name: gcr.io\/cloud-builders\/gsutil\n  entrypoint: bash\n  args:\n  - -c\n  - |\n    if [[ "\$BRANCH_NAME" =~ $branchTrigger ]] || exit 0; then\n      token=\$(gcloud auth print-access-token)\n      curl -H \"Content-Type: application\/json; charset=utf-8\" -X POST --data '{\"substitutions\":{\"_BRANCH_NAME\":\"'\${BRANCH_NAME}'\"},\"commitSha\":\"'\${COMMIT_SHA}'\"}\' \"https:\/\/cloudbuild.googleapis.com\/v1\/projects\/\${PROJECT_ID}\/triggers\/$pipelineName:run?access_token=\${token}\&alt=json\"\n      fi\n\n&/g" $localDirectory/$pipelinePath/$previousPipelineyaml -i
            ;;
        "*package-pipeline.yml")
            echo -e "${green}Previous pipeline defined. Adding trigger inside: ${localDirectory}/${pipelinePath}/${previousPipelineyaml}.${white}."
            sed -e "s/# mark to insert trigger/- name: gcr.io\/cloud-builders\/gsutil\n  entrypoint: bash\n  args:\n  - -c\n  - |\n    if [[ "\$_BRANCH_NAME" =~ $branchTrigger ]] || exit 0; then\n      token=\$(gcloud auth print-access-token)\n      curl -H \"Content-Type: application\/json; charset=utf-8\" -X POST --data '{\"substitutions\":{\"_BRANCH_NAME\":\"'\${_BRANCH_NAME}'\",\"_IMAGE_NAME\":\"'\${_IMAGE_NAME}'\"},\"commitSha\":\"'\${COMMIT_SHA}'\"}\' \"https:\/\/cloudbuild.googleapis.com\/v1\/projects\/\${PROJECT_ID}\/triggers\/$pipelineName:run?access_token=\${token}\&alt=json\"\n      fi\n\n&/g" $localDirectory/$pipelinePath/$previousPipelineyaml -i
            ;;
        *)
            echo -e "${green}Previous pipeline defined. Adding trigger inside: ${localDirectory}/${pipelinePath}/${previousPipelineyaml}.${white}."
            sed -e "s/# mark to insert trigger/- name: gcr.io\/cloud-builders\/gsutil\n  entrypoint: bash\n  args:\n  - -c\n  - |\n    if [[ "\$_BRANCH_NAME" =~ $branchTrigger ]] || exit 0; then\n      token=\$(gcloud auth print-access-token)\n      curl -H \"Content-Type: application\/json; charset=utf-8\" -X POST --data '{\"substitutions\":{\"_BRANCH_NAME\":\"'\${_BRANCH_NAME}'\"},\"commitSha\":\"'\${COMMIT_SHA}'\"}\' \"https:\/\/cloudbuild.googleapis.com\/v1\/projects\/\${PROJECT_ID}\/triggers\/$pipelineName:run?access_token=\${token}\&alt=json\"\n      fi\n\n&/g" $localDirectory/$pipelinePath/$previousPipelineyaml -i
            ;;
    esac
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
    # We check if the bucket we needed exists, we create it if not
    if (gcloud storage ls --project="${gCloudProject}" | grep "${gCloudProject}_cloudbuild" >> /dev/null)
    then
      echo -e "${green}Bucket ${gCloudProject}_cloudbuild already exists.${white}"
    else
      echo -e "${green}The bucket ${gCloudProject}_cloudbuild does not exist, creating it...${white}"
      gcloud storage buckets create "gs://${gCloudProject}_cloudbuild" --project="${gCloudProject}"
    fi
    # We create the trigger
    if [ "$previousPipelineyaml" == "" ]; then # Initial trigger, executes when occurs a push to the repo
        gcloud beta builds triggers create cloud-source-repositories --repo="$gCloudRepo" --branch-pattern="$branchTrigger"  --build-config="${pipelinePath}/${yamlFile}" --project="$gCloudProject" --name="$pipelineName" --description="$triggerDescription" --substitutions "${subsitutionVariable}${artifactPathSubStr}"
    else # Chained trigger, executed manually
        gcloud beta builds triggers create cloud-source-repositories --repo="$gCloudRepo" --branch-pattern="_manual_"  --build-config="${pipelinePath}/${yamlFile}" --project="$gCloudProject" --name="$pipelineName" --description="$triggerDescription" --substitutions "${subsitutionVariable}${artifactPathSubStr}"
    fi
}

# Function that checks whether Flutter image exists, if not a new image is created with the specified version
function checkOrUploadFlutterImage {
    # The user must specify an artifact registry region
    if [[ "$registryLocation" == "" ]]
    then
        echo -e "${red}Error: Registry location not provided." >&2
        echo -ne "${white}" >&2
        exit 2
    fi

    # If flutter repository does not exists it will be created
    if [[ $(gcloud artifacts repositories list --project="$gCloudProject" | awk '$1=="flutter" {print $1}') == "" ]]
    then
        gcloud beta artifacts repositories create flutter --repository-format=docker --location="$registryLocation" --project="$gCloudProject"
    fi

    imageTag="${registryLocation}-docker.pkg.dev/${gCloudProject}/flutter/flutter"
    # If no flutter image exists with specified version, it will built and uploaded
    if [[ $(gcloud artifacts docker images list "$imageTag" --include-tags --project="$gCloudProject" 2> /dev/null | awk -v languageVersion="$languageVersion" '$3==languageVersion {print $3}') == "" ]]
    then
        cd "${hangarPath}/${commonPipelineTemplatesPath}"/images/flutter
        gcloud builds submit . --substitutions _FLUTTER_VERSION="${languageVersion}",_REGISTRY_LOCATION="${registryLocation}" --project="$gCloudProject"
        cd "$currentDirectory"
    fi
}

function addSecretVars {

    echo -e "${green}Adding secret vars to secret manager...${white}"
    for i in $secretVars
    do
        secretName=$(echo "$i" | cut -d= -f1)
        secretValue=$(echo "$i" | cut -d= -f2)
        [[ "$secretName" =~ ^[a-zA-Z0-9_]*$ ]] || { echo -e "${red}Error: The secret name ($secretName) is not compliant with the regex ^[a-zA-Z0-9_]\$*. (only letters number and '_' are accepted in the name)" >&2; echo -ne "${white}" >&2; exit 2; }

        # Creating the secret if it does not exist yet
        if [[ $(gcloud secrets list --project "${gCloudProject}" 2> /dev/null | awk -v secretName="$secretName" '$1==secretName {print $1}') == "" ]]
        then
            echo "gcloud secrets create $secretName"
            gcloud secrets create "$secretName" --replication-policy="automatic"
        fi

        # Adding a version to the secret previously created
        echo "gcloud secrets versions add \"$secretName\" --data-file=-"
        echo "${secretValue}" | gcloud secrets versions add "$secretName" --data-file=- --project "${gCloudProject}"
        mkdir -p "${localDirectory}/${configFilePath}"
        [[ -f "${localDirectory}/${configFilePath}/SecretVars.conf" ]] || echo "# secretName #pipelineList" >> "${localDirectory}/${configFilePath}/SecretVars.conf"
        echo "$secretName $pipelineName" >> "${localDirectory}/${configFilePath}/SecretVars.conf"
    done

    # Adding script to get secret and commiting changes
    mkdir -p "${localDirectory}/${scriptFilePath}"
    cp "$hangarPath/${commonTemplatesPath}/secret/get-${provider}-secret-vars.sh" "${localDirectory}/${scriptFilePath}/get-secret-vars.sh"
    # Commiting the conf file
    echo -e "${green}Commiting and pushing into Git remote...${white}"
    git add -f "${localDirectory}/${configFilePath}/SecretVars.conf" "${localDirectory}/${scriptFilePath}/get-secret-vars.sh"
    find "$pipelinePath" -type f -name '*.sh' -exec git update-index --chmod=+x {} \;
    git commit -m "[skip ci] Adding secret vars conf file"
    echo ""
}

function addEnvVars {

    echo -e "${green}Adding environment vars for this trigger...${white}"
    echo $envVars
    for i in $envVars
    do
        variableName=$(echo "$i" | cut -d= -f1)
        variableValue=$(echo "$i" | cut -d= -f2)
        mkdir -p "${localDirectory}/${configFilePath}"
        [[ -f "${localDirectory}/${configFilePath}/${pipelineName}.env" ]] || echo "# Environment variables of the trigger ${pipelineName}" >> "${localDirectory}/${configFilePath}/${pipelineName}.env"
        echo "export $variableName=\"$variableValue\"" >> "${localDirectory}/${configFilePath}/${pipelineName}.env"
    done
    git add "${localDirectory}/${configFilePath}/${pipelineName}.env"
    git commit -m "[skip ci] Adding Environment variables"
    echo ""
}

function addRoles {
  echo -e "${green}Giving the necessary roles for this pipeline to the Cloud Build service account...${white}"
  gCloudProjectNumber="$(gcloud projects list | grep "$gCloudProject" | awk '{ print $NF }')"
  for i in $roles
  do
      echo "$i"
      gcloud projects add-iam-policy-binding "${gCloudProject}" --member="serviceAccount:${gCloudProjectNumber}@cloudbuild.gserviceaccount.com" --role="$i" > /dev/null
  done
}


obtainHangarPath

# Load common functions
. "$hangarPath/scripts/pipelines/common/pipeline_generator.lib"

if [[ "$help" == "true" ]]; then help; fi

languageVersionVerification

ensurePathFormat

checkInstallations

validateRegistryLoginCredentials

[[ "$machineType" != "" ]] && checkMachineType

importConfigFile

getProjectRepo

[[ "$language" == "flutter" ]] && type checkOrUploadFlutterImage &> /dev/null && checkOrUploadFlutterImage

createNewBranch

type addPipelineVariables &> /dev/null && addPipelineVariables

type addCommonPipelineVariables &> /dev/null && addCommonPipelineVariables

copyYAMLFile

[[ "$machineType" != "" ]] && addMachineType

copyCommonScript

type copyScript &> /dev/null && copyScript

addTriggers

commitCommonFiles

type commitFiles &> /dev/null && commitFiles

createTrigger

[[ "$secretVars" != "" ]] && addSecretVars

[[ "$envVars" != "" ]] && addEnvVars

merge_branch

[[ "$roles" == "" ]] || addRoles

type addAdditionalRoles &> /dev/null && addAdditionalRoles

echo -e "${green}\nPipeline generated succesfully${white}"
