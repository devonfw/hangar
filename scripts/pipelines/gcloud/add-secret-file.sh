#!/bin/bash
set -e
FLAGS=$(getopt -a --options n:f:p:d:p:h --long "secret-name:,local-file-path:,remote-file-path,:local-directory:,pipelines:,help" -- "$@")

eval set -- "$FLAGS"
while true; do
    case "$1" in
        -n | --secret-name)       secretNname=$2; shift 2;;
        -d | --local-directory)   localDirectory=$2; shift 2;;
        -p | --pipelines)         pipelinesList=$2; shift 2;;
        -f | --local-file-path)   localFilePath=$2; shift 2;;
        -p | --remote-file-path)  remoteFilePath=$2; shift 2;;
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
commonPipelineTemplatesPath="scripts/pipelines/common/templates/" # Path for common files of the pipelines
pipelinePath=".pipelines" # Path to the pipelines.
scriptFilePath=".pipelines/scripts" # Path to the scripts.
configFilePath=".pipelines/config" # Path to the scripts.
provider="gcloud"

function obtainHangarPath {

    # This line goes to the script directory independent of wherever the user is and then jumps 3 directories back to get the path
    hangarPath=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd ../../.. && pwd )
}

function addSecretFiles {
  # This function is used to store files as secret
  echo -e "${green}Uploading secret files...${white}"
  if [ "$secretName" == "" ]
  then
    echo "No secret name given with the '-n' flag, using the file name to determine it."
    fileName=$(basename "$localFilePath")
    # Here we changed all the non alphanumeric+_ charachter to _ (Because Google does not accept those character as name of secret)
    secretName=$(echo "${fileName}" | sed 's/\W/_/g')
    echo "Secret name: '$secretName'"
  fi

  # Creating the secret if it does not exist yet
  if ! gcloud secrets versions access latest --secret="$secretName" &>/dev/null; then
      echo "gcloud secrets create $secretName"
      gcloud secrets create "$secretName" --replication-policy="automatic"
  fi

  # Adding a version to the secret previously created
  echo "gcloud secrets versions add \"$secretName\" --data-file=\"${currentDirectory}/${localFilePath}\""
  gcloud secrets versions add "$secretName" --data-file="${currentDirectory}/${localFilePath}"
  mkdir -p "${localDirectory}/${configFilePath}"
  [[ -f "${localDirectory}/${configFilePath}/pathsSecretFiles.conf" ]] || echo "secretName=PathToDowload #pipelinesList" >> [[ -f "${localDirectory}/${configFilePath}/pathsSecretFiles.conf" ]]
  echo "$secretName=$remoteFilePath #$pipelinesList" >> "${localDirectory}/${configFilePath}/pathsSecretFiles.conf"
  echo -e "${green}${fileName}: Done.${white}"
  cp "$hangarPath/scripts/pipelines/common/secret/get-${provider}-secret.sh" "${localDirectory}/${scriptFilePath}/get-secret.sh"
  echo ""
}

obtainHangarPath

# Load common functions
. "$hangarPath/scripts/pipelines/common/pipeline_generator.lib"

if [[ "$help" == "true" ]]; then help_secret; fi

ensurePathFormat

checkInstallations

getProjectRepo

createNewBranch

addSecretFiles

commitCommonFiles

merge_branch

