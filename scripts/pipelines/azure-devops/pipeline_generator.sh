#!/bin/bash
while getopts c:n:d:b:w:l:p:u:t:i:u:s:r:a:f: flag
do
    case "${flag}" in
        c) configFile=${OPTARG};;
        n) pipelineName=${OPTARG};;
        d) localDirectory=${OPTARG};;
        b) targetBranch=${OPTARG};;
        w) webBrowser=${OPTARG};;
        l) language=${OPTARG};;
        p) buildPipelineName=${OPTARG};;
        u) sonarUrl=${OPTARG};;
        t) sonarToken=${OPTARG};;
        i) imageName=${OPTARG};;
		a) dockerUser=${OPTARG};;
        s) dockerPassword=${OPTARG};;
    esac
done

if test "$1" = "-h"
then
    echo "Generates a pipeline on Azure DevOps based on the parameters set in the configuration file."
    echo ""
    echo "Global arguments:"
    echo "  -c    [Required] Configuration file containing parameters and variables."
    echo "  -n    [Required] Name that will be set to the pipeline."
    echo "  -d    [Required] Local directory of your project (the path should always be using '/' and not '\')."
    echo "  -b               Name of the branch to which the Pull Request will target. PR is not created if the flag is not provided."
    echo "  -w               Open the Pull Request on the web browser if it cannot be automatically merged. Requires -b flag."
    echo ""
    echo "Build arguments:"
    echo "  -l    [Required] Language or framework of the project."
    echo ""
    echo "Test arguments:"
    echo "  -l    [Required] Language or framework of the project."
    echo ""
    echo "Quality arguments:"
    echo "  -l    [Required] Language or framework of the project."
    echo "  -p    [Required] Build pipeline name."
    echo "  -u    [Required] Sonarqube URL."
    echo "  -t    [Required] Sonarqube token."
    echo ""
    echo "Package arguments:"
    echo "  -i    [Required] Name that will be given to the Docker image. It must contain the name of the registry and the name or path of the repository inside the registry."
	echo "	Ex: docker.io/user/application_name"
	echo "	-a	  [Required] User to connect to your docker registry."
	echo "	-s	  [Required] Password of the user to connect to your docker registry."
	echo "	-p	  [Required] Name of the pipeline that build the artifact."
	echo "  -l    [Required] Language or framework of the project."
    exit
fi

function addPipelineVar {
	#	function to add var to a pipeline
	#	$1 = name of the var (required)
	#	$2 = value of the var	(required)
	#	$3 = 'true' if the var must be secret, false if not (required)
	#	$4 = name of the pipeline (required)
	az pipelines variable create --name $1 --value $2 --secret $3 --pipeline-name $4
}

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

source $configFile
IFS=, read -ra flags <<< "$mandatoryFlags"
# Check if a config file was supplied.
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
        echo -e "${red}Use -h flag to display help." >&2
        exit 2
    fi
done

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
# if ! [ -x "$(command -v python)" ]; then
  # echo -e "${red}Error: Python is not installed." >&2
  # exit 127
# fi

cd ../../..
hangarPath=$(pwd)

# Create the new branch.
echo -e "${green}Creating the new branch: ${sourceBranch}..."
echo -ne ${white}
cd ${localDirectory}
git checkout -b ${sourceBranch}

# Copy the corresponding YAML and script into the directory.
echo -e "${green}Copying the corresponding files into your directory..."
echo -ne ${white}
# Check if the folders .pipelines and .scripts exist.
if [ ! -d "${localDirectory}/${pipelinePath}" ]
then
    # The folder does not exists.
    # Create the .pipelines folder.
    cd ${localDirectory}
    mkdir .pipelines
    cd ${localDirectory}/${pipelinePath}
    mkdir scripts
fi
cp "${hangarPath}/${templatesPath}/${yamlFile}" "${localDirectory}/${pipelinePath}/${yamlFile}"
# Check if the pipeline is a Package pipeline.
echo $configFile | grep "package-config.cfg" > /dev/null
if [ $? = 0 ]
then
    # It is a Package pipeline, copy the script.
    cp "${hangarPath}/${templatesPath}/${scriptFile}" "${localDirectory}/${scriptFilePath}/${scriptFile}"
else
    # It is a Build, Test or Quality pipeline, copy the script according to its language.
    cp "${hangarPath}/${templatesPath}/${language}-${scriptFile}" "${localDirectory}/${scriptFilePath}/${scriptFile}"
    # Check if the -a flag activated.
    if ! test -z "$artifactPath"
    then
        # Add the extra step to the YAML.
        cat "${hangarPath}/${templatesPath}/store-extra-path.yml" >> "${localDirectory}/${pipelinePath}/${yamlFile}"
    fi
    # Check if the pipeline is a Quality pipeline.
    if test ! -z "$buildPipelineName" && test ! -z "$sonarUrl" && test ! -z "$sonarToken"
    then
        sed -i "s/<build-pipeline-name>/$buildPipelineName/g" "${localDirectory}/${pipelinePath}/${yamlFile}"
        sed -i "s,<sonarqube-url>,$sonarUrl,g" "${localDirectory}/${scriptFilePath}/${scriptFile}"
        sed -i "s/<sonarqube-token>/$sonarToken/g" "${localDirectory}/${scriptFilePath}/${scriptFile}"
    fi
fi

# Move into the project's directory and pushing the template into the Azure DevOps repository.
echo -e "${green}Commiting and pushing into Git remote..."
echo -ne ${white}
cd ${localDirectory}
git add .pipelines -f
git commit -m "Adding the source YAML"
git push -u origin ${sourceBranch}

# Create Azure Pipeline
echo -e "${green}Generating the pipeline from the YAML template..."
echo -ne ${white}
az pipelines create --name $pipelineName --yml-path "${pipelinePath}/${yamlFile}" --skip-first-run true

# Check if the -a flag is activated.
if ! test -z "$artifactPath"
then
    # Create the variable in the pipeline.
    az pipelines variable create --name "artifactPath" --pipeline-name $pipelineName --value ${artifactPath}
fi

echo $configFile | grep "package-config.cfg" > /dev/null
if [ $? = 0 ]
then
# Define the variable we need for the package pipeline
	for i in $dockerfilePaths
	do
		echo $i | grep $language && dockerfile=$(echo $i | cut -d':' -f2)
		break
	done
	registry=$(echo $imageName | cut -d'/' -f1)
	addPipelineVar BuildPipeline $buildPipelineName false $pipelineName
	addPipelineVar relativeDockerfilePath $dockerfile false $pipelineName
	az pipelines variable-group create --name registry_info --variable registry="$registry" imagename="$imageName" > ./tmp_group_var
	group_id=$(cat  ./tmp_group_var | grep '"id"' | cut -d: -f2 | cut -d, -f1 | tr -d \")
	pwd
	#rm ./tmp_group_var
	az pipelines variable-group variable create --group-id $group_id --name docker_username --value "$dockerUser" --secret true
	az pipelines variable-group variable create --group-id $group_id --name docker_password --value "$dockerPassword" --secret true
fi

# PR creation
if test -z "$targetBranch"
then
    # No branch specified in the parameters, no Pull Request is created, the code will be stored in the current branch.
    echo -e "${green}No branch specified to do the Pull Request, changes left in the ${sourceBranch} branch."
    exit
else
    # Create teh Pull Request to merge into the specified branch.
    echo -e "${green}Creating a Pull Request..."
    echo -ne ${white}
    pr=$(az repos  pr create --source-branch ${sourceBranch} --target-branch $targetBranch --title "Pipeline" --auto-complete true)
    # Obtain the PR id.
    id=$(echo "$pr" | python -c "import sys, json; print(json.load(sys.stdin)['pullRequestId'])")
    # Obtain the PR status.
    showOutput=$(az repos pr show --id $id)
    status=$(echo "$showOutput" | python -c "import sys, json; print(json.load(sys.stdin)['status'])")
    # Check if the Pull  Request merge has succeeded.
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
        flags=$*
        if [[ "$flags" == *" -w"* ]]
        then
            # -w flag is activated and a page with the corresponding Pull Request is opened in the web browser.
            echo -e "${green}Pull Request successfully created."
            echo -e "${green}Opening the Pull Request on the web browser..."
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
