#!/bin/bash
set -e
FLAGS=$(getopt -a --options n:f:r:p:d:b:hv: --long "secret-name:,local-file-path:,remote-file-path,:local-directory:,pipelines:,branch:,help,value:" -- "$@")

eval set -- "$FLAGS"
while true; do
    case "$1" in
        -n | --secret-name)       secretName=$2; shift 2;;
        -d | --local-directory)   localDirectory=$2; shift 2;;
        -p | --pipelines)         pipelinesList=$2; shift 2;;
        -f | --local-file-path)   localFilePath=$2; shift 2;;
        -v | --value)             secretValue="$2"; shift 2;;
        -r | --remote-file-path)  remoteFilePath=$2; shift 2;;
        -b | --branch)            targetBranch=$2; shift 2;;
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
configFilePath=".pipelines/config" # Path to the config files.
provider="gcloud"
sourceBranch="feature/add-secret"

! [[ "$pipelinesList" = "" ]] || pipelinesList="AllPipelines"

if [[ "$localFilePath" != "" ]]
then
  mandatoryFlags="$localDirectory,${localFilePath},${remoteFilePath},$targetBranch,"
else
  mandatoryFlags="$localDirectory,${secretName},${secretValue},$targetBranch,"
fi

function help_secret {
  echo ""
  echo "Uploads a file or a variable as a secret in Google Cloud Secret Manager to make it available in chosen pipelines."
  echo ""
  echo "  -d, --local-directory       [Required] Local directory of your project."
  echo "  -f, --local-file-path       [Required, unless -v] Local path of the file to be uploaded. Takes precedence over -v."
  echo "  -r, --remote-file-path      [Required, if -f] File path (in pipeline context) where the secret will be downloaded."
  echo "  -n, --secret-name           [Required, if -v] Name for the secret in Secret Manager. If not specified (when optional), file name is used as default. The name must comply with the regex [a-zA-Z0-9_]."
  echo "  -v, --value                 [Required, unless -f] Value of the secret."
  echo "  -b, --target-branch         [Required] Name of the branch to which the merge will target."
  echo "  -p, --pipelines                        List of pipelines where the secret will be made available. By default, all pipelines."


  exit
}

function obtainHangarPath {

    # This line goes to the script directory independent of wherever the user is and then jumps 3 directories back to get the path
    hangarPath=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd ../../.. && pwd )
}

function checkArgs {
  # We check if all the args required has been given
  IFS=, read -ra flags <<< "$mandatoryFlags"
  for flag in "${flags[@]}"
  do
      if test -z "$flag"
      then
          echo -e "${red}Error: Missing parameters, some flags are mandatory." >&2
          echo -e "${red}Use -h or --help flag to display help." >&2
          echo -ne "${white}" >&2
          exit 2
      fi
  done

  # If secret name given we check that is compliant with the regex \w
  [[ "$secretName" =~ ^[a-zA-Z0-9_]*$ ]] || { echo -e "${red}Error: The secret name is not compliant with the regex ^[a-zA-Z0-9_]\$*. (only letters, number and '_' are accepted)" >&2; echo -ne "${white}" >&2; exit 2; }

  # Checking if the file given with the -f exists
  cd "$currentDirectory"

  # Ensuring the UNIX format path
  if [[ "$localFilePath" != "" ]]
  then
      localFilePath=${localFilePath//'\'/"/"}
      localFilePath=${localFilePath//'C:'/"/c"}
      cd "$(dirname "${localFilePath}")" && [ -f "$(basename "${localFilePath}")" ] && localFilePath="$(pwd)/$(basename "${localFilePath}")"  || { echo -e "${red}Error: The file specified in '-f' flag does not exist." >&2; echo -ne "${white}" >&2; exit 2; }
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

function addSecretFiles {
  # This function is used to store files as secret
  echo -e "${green}Uploading secret files...${white}"
  if [ "$secretName" == "" ]
  then
    echo "No secret name provided, using the file name as a basis."
    fileName=$(basename "$localFilePath")
    # Here we changed all the non alphanumeric+_ character to _ (to comply with regex)
    secretName=$(echo "${fileName}" | sed 's/\W/_/g')
    echo "Secret name: '$secretName'"
  fi

  # Creating the secret if it does not exist yet
  if [[ $(gcloud secrets list --project "${gCloudProject}" 2> /dev/null | awk -v secretName="$secretName" '$1==secretName {print $1}') == "" ]]
  then
      echo "gcloud secrets create $secretName --project \"${gCloudProject}\""
      gcloud secrets create "$secretName" --replication-policy="automatic" --project "${gCloudProject}"
  fi

  # Adding a version to the secret previously created
  echo "gcloud secrets versions add \"$secretName\" --data-file=\"${localFilePath}\" --project "${gCloudProject}""
  gcloud secrets versions add "$secretName" --data-file="${localFilePath}" --project "${gCloudProject}"
  mkdir -p "${localDirectory}/${configFilePath}"
  mkdir -p "${localDirectory}/${scriptFilePath}"
  [[ -f "${localDirectory}/${configFilePath}/pathsSecretFiles.conf" ]] || echo "# secretName=PathToDownload #pipelinesList" >> "${localDirectory}/${configFilePath}/pathsSecretFiles.conf"
  echo "$secretName=$remoteFilePath #$pipelinesList" >> "${localDirectory}/${configFilePath}/pathsSecretFiles.conf"
  cp "$hangarPath/${commonTemplatesPath}/secret/get-${provider}-secrets.sh" "${localDirectory}/${scriptFilePath}/get-secrets.sh"
  # Commiting the conf file
  echo -e "${green}Commiting and pushing into Git remote...${white}"
  git add -f "${localDirectory}/${configFilePath}/pathsSecretFiles.conf" "${localDirectory}/${scriptFilePath}/get-secrets.sh"
  find "$pipelinePath" -type f -name '*.sh' -exec git update-index --chmod=+x {} \;
  git commit -m "[skip ci] Adding secret conf file"
  git push -u origin "$sourceBranch"
  echo ""
}

function addSecretVars {

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
    [[ -f "${localDirectory}/${configFilePath}/secret-vars.conf" ]] || echo "# secretName #pipelinesList" >> "${localDirectory}/${configFilePath}/secret-vars.conf"
    echo "$secretName $pipelinesList" >> "${localDirectory}/${configFilePath}/secret-vars.conf"

    # Adding script to get secret and commiting changes
    mkdir -p "${localDirectory}/${scriptFilePath}"
    cp "$hangarPath/${commonTemplatesPath}/secret/get-${provider}-secret-vars.sh" "${localDirectory}/${scriptFilePath}/get-secret-vars.sh"
    # Commiting the conf file
    echo -e "${green}Commiting and pushing into Git remote...${white}"
    git add -f "${localDirectory}/${configFilePath}/secret-vars.conf" "${localDirectory}/${scriptFilePath}/get-secret-vars.sh"
    find "$pipelinePath" -type f -name '*.sh' -exec git update-index --chmod=+x {} \;
    git commit -m "[skip ci] Adding secret vars conf file"
    git push -u origin "$sourceBranch"
    echo ""
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

obtainHangarPath

# Load common functions
# shellcheck source=/dev/null
. "$hangarPath/scripts/pipelines/common/pipeline_generator.lib"

if [[ "$help" == "true" ]]; then help_secret; fi

ensurePathFormat

checkArgs

checkInstallations

getProjectRepo

createNewBranch

if [[ "$localFilePath" != "" ]]
then
    addSecretFiles
else
    addSecretVars
fi

merge_branch

