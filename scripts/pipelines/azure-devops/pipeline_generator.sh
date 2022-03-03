#!/bin/bash
ARGS=$*
FLAGS=$(getopt -a --options c:n:d:a:b:l:i:u:p: --long "config-file:,pipeline-name:,local-directory:,artifact-path:,target-branch:,language:,build-pipeline-name:,sonar-url:,sonar-token:,image-name:,user:,password:,resource-group:,storage-account:,storage-container:,cluster-name:,s3-bucket:,s3-key-path:,deploy-files:,k8s-service-connection:,Container-Reg-Connection:,k8s-namespace:" -- "$@")
eval set -- "$FLAGS"
while true; do
    case "$1" in
        -c | --config-file)          configFile=$2; shift 2;;
        -n | --pipeline-name)        pipelineName=$2; shift 2;;
        -d | --local-directory)      localDirectory=$2; shift 2;;
        -a | --artifact-path)        artifactPath=$2; shift 2;;
        -b | --target-branch)        targetBranch=$2; shift 2;;
        -l | --language)             language=$2; shift 2;;
        --build-pipeline-name)       buildPipelineName=$2; shift 2;;
        --sonar-url)                 sonarUrl=$2; shift 2;;
        --sonar-token)               sonarToken=$2; shift 2;;
        -i | --image-name)           imageName=$2; shift 2;;
        -u | --user)                 user=$2; shift 2;;
        -p | --password)             password=$2; shift 2;;
        --resource-group)            resourceGroupName=$2; shift 2;;
        --storage-account)           storageAccountName=$2; shift 2;;
        --storage-container)         storageContainerName=$2; shift 2;;
        --cluster-name)              clusterName=$2; shift 2;;
        --s3-bucket)                 s3Bucket=$2; shift 2;;
        --s3-key-path)               s3KeyPath=$2; shift 2;;
        --deploy-files)              deployFiles=$2; shift 2;;
        --k8s-service-connection)    k8s_service_connection=$2; shift 2;; 
        --Container-Reg-Connection)  Container-Reg-Connection=$2; shift 2;;
        --k8s-namespace)             k8sNamespace=$2; shift 2;; 
        --) shift; break;;
    esac
done

# Colours for the messages.
white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

function help {
    echo ""
    echo "Generates a pipeline on Azure DevOps based on the given definition."
    echo ""
    echo "Common flags:"
    echo "  -c, --config-file               [Required] Configuration file containing pipeline definition."
    echo "  -n, --pipeline-name             [Required] Name that will be set to the pipeline."
    echo "  -d, --local-directory           [Required] Local directory of your project (the path should always be using '/' and not '\')."
    echo "  -a, --artifact-path                        Path to be persisted as an artifact after pipeline execution, e.g. where the application stores logs or any other blob on runtime."
    echo "  -b, --target-branch                        Name of the branch to which the Pull Request will target. PR is not created if the flag is not provided."
    echo "  -w                                         Open the Pull Request on the web browser if it cannot be automatically merged. Requires -b flag."
    echo ""
    echo "Build pipeline flags:"
    echo "  -l, --language                  [Required] Language or framework of the project."
    echo ""
    echo "Test pipeline flags:"
    echo "  -l, --language                  [Required] Language or framework of the project."
    echo ""
    echo "Quality pipeline flags:"
    echo "  -l, --language                  [Required] Language or framework of the project."
    echo "      --build-pipeline-name       [Required] Build pipeline name."
    echo "      --sonar-url                 [Required] Sonarqube URL."
    echo "      --sonar-token               [Required] Sonarqube token."
    echo ""
    echo "Package pipeline flags:"
    echo "  -l, --language                  [Required] Language or framework of the project."
    echo "  -i, --image-name                [Required] Name that will be given to the Docker image (It must contain the name of the registry and the name or path of the repository inside the registry)."
    echo "  -u, --user                      [Required] User to connect to your container registry."
    echo "  -p, --password                  [Required] Password of the user to connect to your container registry."
    echo "      --build-pipeline-name       [Required] Build pipeline name."
    echo ""
    echo "Deploy pipeline flags:"
    echo "      --deploy-files              [Required] Path inside the remote repository where the deployment YAML files are located."
    echo "      --k8s-service-connection    [Required] Name of the service connection to connect kubernetes cluster."
    echo "      --Container-Reg-Connection  [Required] Name of the service connection to container registry."
    echo "      --k8s-namespace                        Name of the kubernetes Namespace."
    echo ""
    echo "Library deploy pipeline flags:"
    echo "  -l, --language                  [Required] Language or framework of the project."
    echo ""
    echo "AKS pipeline flags:"
    echo "      --resource-group            [Required] Name of the resource group for the cluster."
    echo "      --storage-account           [Required] Name of the storage account for the cluster."
    echo "      --storage-container         [Required] Name of the storage container where the tfstate file of the cluster will be stored."
    echo ""
    echo "EKS pipeline flags:"
    echo "      --cluster-name              [Required] AWS EKS cluster name."
    echo "      --s3-bucket                 [Required] Name of the S3 bucket where the tfstate file of the cluster will be stored."
    echo "      --s3-key-path               [Required] Path of the S3 bucket where the tfstate file of the cluster will be stored."
    echo ""
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
    cd ${localDirectory}
    git checkout -b ${sourceBranch}
}

function copyYAMLFile {
    echo -e "${green}Copying the corresponding files into your directory..."
    echo -ne ${white}

    # Check if the folders .pipelines and scripts exist.
    if [ ! -d "${localDirectory}/${pipelinePath}" ]
    then
        # The folder does not exist.
        # Create .pipelines folder.
        cd ${localDirectory}
        mkdir .pipelines

        # Create scripts folder.
        cd ${localDirectory}/${pipelinePath}
        mkdir scripts
    fi

    # Copy the YAML Template into the repository.
    cp "${hangarPath}/${templatesPath}/${yamlFile}" "${localDirectory}/${pipelinePath}/${yamlFile}"
}

function commitFiles {
    echo -e "${green}Commiting and pushing into Git remote..."
    echo -ne ${white}

    # Move into the project's directory and pushing the template into the Azure DevOps repository.
    cd ${localDirectory}

    # Add the YAML files.
    git add .pipelines -f

    # Check if it is a provisioning pipeline.
    if test ! -z $resourceGroupName || test ! -z $clusterName
    then
        # Add the terraform files.
        git add .terraform -f
    fi

    # Git commit and push it into the repository.
    git commit -m "Adding the source YAML"
    git push -u origin ${sourceBranch}
}

function createPipeline {
    echo -e "${green}Generating the pipeline from the YAML template..."
    echo -ne ${white}

    # Create Azure Pipeline
    az pipelines create --name $pipelineName --yml-path "${pipelinePath}/${yamlFile}" --skip-first-run true
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
            if [[ "$ARGS" == *" -w"* ]]
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

if [[ "$ARGS" == "-h"  || "$ARGS" == "--help" ]]; then help; fi

importConfigFile

checkInstallations

obtainHangarPath

createNewBranch

copyYAMLFile

copyScript

commitFiles

createPipeline

addPipelineVariables

createPR
