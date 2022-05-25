#!/bin/bash
set -e
FLAGS=$(getopt -a --options c:n:d:a:b:l:i:u:p:hw --long "config-file:,pipeline-name:,local-directory:,artifact-path:,target-branch:,language:,build-pipeline-name:,sonar-url:,sonar-token:,image-name:,registry-user:,registry-password:,resource-group:,storage-account:,storage-container:,cluster-name:,s3-bucket:,s3-key-path:,quality-pipeline-name:,dockerfile:,test-pipeline-name:,aws-access-key:,aws-secret-access-key:,aws-region:,package-pipeline-name:,provision-pipeline-name:,deploy-cluster:,k8s-namespace:,deploy-files:,secrets-name:,help" -- "$@")
eval set -- "$FLAGS"
while true; do
    case "$1" in
        -c | --config-file)             configFile=$2; shift 2;;
        -n | --pipeline-name)           pipelineName=$2; shift 2;;
        -d | --local-directory)         localDirectory=$2; shift 2;;
        -a | --artifact-path)           artifactPath=$2; shift 2;;
        -b | --target-branch)           targetBranch=$2; shift 2;;
        -l | --language)                language=$2; shift 2;;
        --build-pipeline-name)          export buildPipelineName=$2; shift 2;;
        --sonar-url)                    sonarUrl=$2; shift 2;;
        --sonar-token)                  sonarToken=$2; shift 2;;
        -i | --image-name)              imageName=$2; shift 2;;
        -u | --registry-user)           dockerUser=$2; shift 2;;
        -p | --registry-password)       dockerPassword=$2; shift 2;;
        --resource-group)               resourceGroupName=$2; shift 2;;
        --storage-account)              storageAccountName=$2; shift 2;;
        --storage-container)            storageContainerName=$2; shift 2;;
        --cluster-name)                 clusterName=$2; shift 2;;
        --s3-bucket)                    s3Bucket=$2; shift 2;;
        --s3-key-path)                  s3KeyPath=$2; shift 2;;
        --quality-pipeline-name)        export qualityPipelineName=$2; shift 2;;
        --test-pipeline-name)           export testPipelineName=$2; shift 2;;
        --dockerfile)                   dockerFile=$2; shift 2;;
        --aws-access-key)               awsAccessKey="$2"; shift 2;;
        --aws-secret-access-key)        awsSecretAccessKey="$2"; shift 2;;
        --aws-region)                   awsRegion="$2"; shift 2;;
        --provision-pipeline-name)      ProvisionPipelineName="$2"; shift 2;;
        --k8s-namespace)                k8sNamespace="$2"; shift 2;;
    	--deploy-files)                 deployFiles=$2; shift 2;; 
	    --deploy-cluster)               deployCluster=$2; shift 2;; 
        --secrets-name)                 secretsName=$2; shift 2;; 
	    --package-pipeline-name)        export packagePipelineName=$2; shift 2;;
        -h | --help)                    help="true"; shift 1;;
        -w)                             webBrowser="true"; shift 1;;
        --) shift; break;;
    esac
done

# Colours for the messages.
white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

# Common var
commonTemplatesPath="scripts/pipelines/azure-devops/templates/common"

function help {
    echo ""
    echo "Generates a pipeline on Azure DevOps based on the given definition."
    echo ""
    echo "Common flags:"
    echo "  -c, --config-file                   [Required] Configuration file containing pipeline definition."
    echo "  -n, --pipeline-name                 [Required] Name that will be set to the pipeline."
    echo "  -d, --local-directory               [Required] Local directory of your project (the path should always be using '/' and not '\')."
    echo "  -a, --artifact-path                            Path to be persisted as an artifact after pipeline execution, e.g. where the application stores logs or any other blob on runtime."
    echo "  -b, --target-branch                            Name of the branch to which the Pull Request will target. PR is not created if the flag is not provided."
    echo "  -w                                             Open the Pull Request on the web browser if it cannot be automatically merged. Requires -b flag."
    echo ""
    echo "Build pipeline flags:"
    echo "  -l, --language                      [Required] Language or framework of the project."
    echo ""
    echo "Test pipeline flags:"
    echo "  -l, --language                      [Required] Language or framework of the project."
    echo "      --build-pipeline-name           [Required] Build pipeline name."
    echo ""
    echo "Quality pipeline flags:"
    echo "  -l, --language                      [Required] Language or framework of the project."
    echo "      --sonar-url                     [Required] Sonarqube URL."
    echo "      --sonar-token                   [Required] Sonarqube token."
    echo "      --build-pipeline-name           [Required] Build pipeline name."
    echo "      --test-pipeline-name            [Required] Test pipeline name."
    echo ""
    echo "Package pipeline flags:"
    echo "  -l, --language                      [Required, if dockerfile not set] Language or framework of the project."
    echo "      --dockerfile                    [Required, if language not set] Path from the root of the project to its Dockerfile. Takes precedence over the language/framework default one."
    echo "      --build-pipeline-name           [Required] Build pipeline name."
    echo "      --quality-pipeline-name         [Required] Quality pipeline name."
    echo "  -i, --image-name                    [Required] Name (excluding tag) for the generated container image."
    echo "  -u, --registry-user                 [Required, unless AWS] Container registry login user."
    echo "  -p, --registry-password             [Required, unless AWS] Container registry login password."
    echo "      --aws-access-key                [Required, if AWS] AWS account access key ID. Takes precedence over registry credentials."
    echo "      --aws-secret-access-key         [Required, if AWS] AWS account secret access key."
    echo "      --aws-region                    [Required, if AWS] AWS region for ECR."
    echo ""
    echo "Library package pipeline flags:"
    echo "  -l, --language                      [Required] Language or framework of the project."
    echo ""
    echo "Deploy pipeline flags:"
    echo "      --package-pipeline-name         [Required] Name of the Package pipeline."
    echo "      --provision-pipeline-name       [Required] The provision pipeline name (If the deployment in AWS or Azure)."
    echo "      --deploy-cluster                [Required] Deployment environment, AKS or EKS."
    echo "      --k8s-namespace                 [Required] kubernetes namespace."
    echo "      --deploy-files                  [Required] Path inside the remote repository where the manifest YAML files are located."
    echo "      --secrets-name                  [Required, if private registry] Name of the secrets." 
    echo ""
    echo "Azure AKS provisioning pipeline flags:"
    echo "      --resource-group                [Required] Name of the resource group for the cluster."
    echo "      --storage-account               [Required] Name of the storage account for the cluster."
    echo "      --storage-container             [Required] Name of the storage container where the Terraform state of the cluster will be stored."
    echo ""
    echo "AWS EKS provisioning pipeline flags:"
    echo "      --cluster-name                  [Required] Name for the cluster."
    echo "      --s3-bucket                     [Required] Name of the S3 bucket where the Terraform state of the cluster will be stored."
    echo "      --s3-key-path                   [Required] Path within the S3 bucket where the Terraform state of the cluster will be stored."

    exit
}

function importConfigFile {
    # Import config file.
    source $configFile
    IFS=, read -ra flags <<< "$mandatoryFlags"

    # Check if the config file was supplied.
    if test -z "$configFile"
    then
        echo -e "${red}Error: Pipeline definition configuration file not specified." >&2
        exit 2
    fi

    # Check if the required flags in the config file have been activated.
    for flag in "${flags[@]}"
    do
        if test -z $flag
        then
            echo -e "${red}Error: Missing parameters, some flags are mandatory." >&2
            echo -e "${red}Use -h or --help flag to display help." >&2
            exit 2
        fi
    done
}

function checkInstallations {
    # Check if Git is installed
    if ! [ -x "$(command -v git)" ]; then
        echo -e "${red}Error: Git is not installed." >&2
        exit 127
    fi

    # Check if Azure CLI is installed
    if ! [ -x "$(command -v az)" ]; then
        echo -e "${red}Error: Azure CLI is not installed." >&2
        exit 127
    fi

    # Check if Python is installed
    if ! [ -x "$(command -v python)" ]; then
        echo -e "${red}Error: Python is not installed." >&2
        exit 127
    fi
}

function obtainHangarPath {
    cd ../../..
    hangarPath=$(pwd)
}

function createNewBranch {
    echo -e "${green}Creating the new branch: ${sourceBranch}..."
    echo -ne ${white}

    # Create the new branch.
    cd "${localDirectory}"
    [ $? != "0" ] && echo -e "${red}The local directory: '${localDirectory}' cannot be found, please check the path." && exit 1

    git checkout -b ${sourceBranch}
}

function copyYAMLFile {
    echo -e "${green}Copying the corresponding files into your directory..."
    echo -ne ${white}

    # Create .pipelines and scripts if they do not exist.
    mkdir -p "${localDirectory}/.pipelines/scripts"

    # Generate pipeline YAML from template and put it in the repository.
    # We cannot use a variable in the definition of resource in the pipeline so we have to use a placeholder to replace it with the value we need
    envsubst '${buildPipelineName} ${testPipelineName} ${qualityPipelineName} ${packagePipelineName}' < "${hangarPath}/${templatesPath}/${yamlFile}.template" > "${localDirectory}/${pipelinePath}/${yamlFile}"

    # Check if an extra artifact to store is supplied.
    if test ! -z "$artifactPath"
    then
        # Add the extra step to the YAML.
        cat "${hangarPath}/${commonTemplatesPath}/store-extra-path.yml" >> "${localDirectory}/${pipelinePath}/${yamlFile}"
    fi
}

function copyCommonScript {
    echo -e "${green}Copying the script(s) common to any pipeline files into your directory..."
    echo -ne ${white}
    cp "${hangarPath}/${commonTemplatesPath}"/*.sh "${localDirectory}/${scriptFilePath}"
}

function commitCommonFiles {
    echo -e "${green}Commiting and pushing into Git remote..."
    echo -ne ${white}

    # Move into the project's directory and pushing the template into the Azure DevOps repository.
    cd ${localDirectory}

    # Add the YAML files.
    git add .pipelines -f

    # Git commit and push it into the repository.
    # changing all files to be executable
    find .pipelines -type f -name '*.sh' -exec git update-index --chmod=+x {} \;

    git commit -m "Adding the source YAML"
    git push -u origin ${sourceBranch}
}

function createPipeline {
    echo -e "${green}Generating the pipeline from the YAML template..."
    echo -ne ${white}

    # Create Azure Pipeline
    az pipelines create --name $pipelineName --yml-path "${pipelinePath}/${yamlFile}" --skip-first-run true
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

if [[ "$help" == "true" ]]; then help; fi

importConfigFile

checkInstallations

obtainHangarPath

createNewBranch

copyYAMLFile

copyCommonScript

type copyScript &> /dev/null && copyScript

commitCommonFiles

type commitFiles &> /dev/null && commitFiles

createPipeline

type addPipelineVariables &> /dev/null && addPipelineVariables

addCommonPipelineVariables

createPR
