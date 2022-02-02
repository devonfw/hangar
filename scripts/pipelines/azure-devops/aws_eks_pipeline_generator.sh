#!/bin/bash
while getopts n:d:c:b:w:r:e:s:k: flag
do
    case "${flag}" in
        n) name=${OPTARG};;      
        d) directory=${OPTARG};;
        c) configuration_file=${OPTARG};;        
        b) branch=${OPTARG};;
        w) webBrowser=${OPTARG};;
        e) cluster_name=${OPTARG};;
        s) awsS3BucketName=${OPTARG};;
        k) awsS3KeyPath=${OPTARG};;
    esac
done

if test "$1" = "-h"
then
    echo ""
    echo "Generates a pipeline on Azure DevOps from a YAML to provision AWS EKS cluster using Terraform scripts."
    echo ""
    echo "Arguments:"
    echo "  -c    [Required] Configuration file containing parameters and variables."
    echo "  -n    [Required] Name that will be set to the pipeline."
    echo "  -d    [Required] Local directory of your project (the path should always be using '/' and not '\')."
    echo "  -b    [Required] Name of the branch to which the pull request will target. PR is not created if the flag is not provided."
    echo "  -e    [Required] AWS EKS Cluster name"
    echo "  -s    [Required] AWS S3 Bucket Name(used by Terraform to store remote state)."
    echo "  -k    [Required] AWS S3 Bucket path(used by Terraform to store remote state file)"
    echo "  -w               Open the pull request on the web browser if it can not be automatically merged. Requires -b flag."
    exit
fi

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

if test -z $configuration_file 
then
    echo -e "${red}Missing configuration file parameter, use -c."
    echo -e "${red}Use -h flag to display help."
    echo -e ${white}
    exit 2
fi
source $configuration_file
IFS=, read -ra flags <<< "$mandatoryFlags"
# Check if the required flags in the config file have been activated.
for flag in "${flags[@]}"
do
    if test -z $flag
    then
        echo -e "${red}Missing parameters, some flags are mandatory."
        echo -e "${red}Use -h flag to display help."
        echo -e ${white}
        exit 2
    fi
done

source $configuration_file
cd ../../../..
pipelinesDirectory="${directory}/.pipelines"
scriptsDirectory="${pipelinesDirectory}/scripts"
hangarPath=$(pwd)

# Create the new branch.
echo -e "${green}Creating the new branch: ${sourcebranch}..."
echo -e ${white}
cd "${directory}"
git checkout -b ${sourcebranch}
cd "${hangarPath}"

# Copy the corresponding YAML and script into the directory.
echo -e "${green}Copying the corresponding YAML and script into project directory..."
echo -e ${white}
cd "${directory}"
mkdir .pipelines
cd "${pipelinesDirectory}"
mkdir scripts
cd "${hangarPath}/scripts/pipelines/azure-devops/templates/provision-aws-eks-pipeline"
cp "provision-aws-eks-pipeline.yml" "${pipelinesDirectory}/provision-aws-eks-pipeline.yml"

# Copy the terraform files required to provision AWS EKS
cd "${scriptsDirectory}"
mkdir -p terraform/aws/eks
cd "${hangarPath}/scripts/accounts/aws/terraform/eks"
cp * "${scriptsDirectory}/terraform/aws/eks"

# Move into the project's directory and pushing the template into the Azure DevOps repository.
echo -e "${green}Committing and pushing to git remote..."
echo -e ${white}
cd "${directory}"
ls -lrta
git add .pipelines -f
git status
git commit -m "Adding provision-aws-eks pipeline source YAML"
git push -u origin ${sourcebranch}

# Creation of the pipeline.
echo -e "${green}Generating the pipeline from the YAML template..."
echo -e ${white}
az pipelines create --name $name --yaml-path ".pipelines/provision-aws-eks-pipeline.yml" --skip-first-run

# Create pipeline variables from the user provided configuration.
echo -e "${green}Creating pipeline variables from user configuration..."
echo -e ${white}
az pipelines variable create --name "awsServiceConnection" --pipeline-name $name --value ${awsServiceConnection}
az pipelines variable create --name "awsS3BucketName" --pipeline-name $name --value $awsS3BucketName
az pipelines variable create --name "awsS3KeyPath" --pipeline-name $name --value $awsS3KeyPath
az pipelines variable create --name "cluster_name" --pipeline-name $name --value $cluster_name

# Run the pipeline  
echo -e "${green}Running the pipeline $name"
echo -e ${white}
az pipelines run --name $name

# PR creation.
if test -z "$branch"
then
    # No branch specified in the parameters, no Pull Request is created, the code will be stored in the current branch.
    echo -e "${green}No branch specified to do the pull request, changes left in the ${sourcebranch} branch."
    echo -e $white
    exit
else
    # Create the Pull Request to merge iinto the specified branch
    echo -e "${green}Creating a pull request..."
    echo -e ${white}
    pr=$(az repos pr create --source-branch ${sourcebranch} --target-branch $branch --title "Provision AWS EKS Pipeline" --auto-complete true)
    # Obtain the PR id.
    id=$(echo "$pr" | python -c "import sys, json; print(json.load(sys.stdin)['pullRequestId'])")
    # Obtain the PR status.
    showOutput=$(az repos pr show --id $id)
    status=$(echo "$showOutput" | python -c "import sys, json; print(json.load(sys.stdin)['status'])")
    # Check if the Pull Request merge has succeeded.
    if test "$status" = "completed"
    then
        # Pull Request merged successfully.
        echo -e "${green}Pull Request merged into $branch branch successfully."
        echo -e ${white}
        exit
    else
        # Obtain the PR URL.
        url=$(echo "$showOutput" | python -c "import sys, json; print(json.load(sys.stdin)['repository']['webUrl'])")
        prURL="$url/pullrequest/$id"
        # Check if the -w is activated.
        flags=$*
        if [[ "$flags" == *" -w"* ]]
        then
            # -w flag is activated and a page with the corresponding Pull Request is opened in the web browser.
            echo -e "${green}Pull Request successfully created."
            echo -e "${green}Opening the Pull Request on the web browser..."
            echo -e ${white}
            az repos pr show --id $id --open > /dev/null
            exit
        else
            # -w flag is not activated and the URL to the Pull Request is shown in the console.
            echo -e "${green}Pull Request successfully created."
            echo -e "${green}To review the Pull Request and accept it, click on the following link:"
            echo -e ${white}
            echo ${prURL}
            exit
        fi
    fi
fi
