while getopts n:l:d:b:p: flag
do
    case "${flag}" in
        n) name=${OPTARG};;
        l) language=${OPTARG};;
        d) directory=${OPTARG};;
        b) branch=${OPTARG};;
        p) openPR=${OPTARG};;
    esac
done

if test "$1" = "-h"
then
    echo ""
    echo "Generates a build pipeline on Azure DevOps from a YAML template according to the project programming language or framework."
    echo ""
    echo "Arguments:"
    echo "  -n    [Required] Name that will be set to the build pipeline."
    echo "  -l    [Required] Language or framework of the project."
    echo "  -d    [Required] Local directory of your project (the path should always be using '/' and not '\')."
    echo "  -b               Name of the branch to which the Pull Request will target. PR is not created if the flag is not provided."
    echo "  -p               Open the Pull Request on the web browser if it cannot be automatically merged. Requires -b flag."
    exit
fi

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

# Argument check.
if test -z "$name" || test -z "$language" || test -z "$directory"
then
    echo -e "${red}Missing parameters, some flags are mandatory."
    echo -e "${red}Use -h flag to display help."
    echo -e ${white}
    exit 2
fi

cd ../../..
pipelinesDirectory="${directory}/.pipelines"
scriptsDirectory="${pipelinesDirectory}/scripts"
hangarPath=$(pwd)

# Create the new branch.
echo -e "${green}Creating the new branch: feature/build-pipeline..."
echo -e ${white}
cd ${directory}
git checkout -b feature/build-pipeline
cd ${hangarPath}

# Copy the corresponding YAML and script into the directory.
echo -e "${green}Copying the corresponding YAML and script into your directory..."
echo -e ${white}
cd ${directory}
mkdir .pipelines
cd ${pipelinesDirectory}
mkdir scripts
cd ${hangarPath}/.pipelines
cp "build-pipeline.yml" "${pipelinesDirectory}/build-pipeline.yml"
cd ${hangarPath}/.scripts
cp "${language}-build.sh" "${scriptsDirectory}/build.sh"

# Move into the project's directory and pushing the template into the Azure DevOps repository.
echo -e "${green}Committing and pushing to Git remote..."
echo -e ${white}
cd ${directory}
git add .pipelines -f
git commit -m "Adding build pipeline source YAML"
git push -u origin feature/build-pipeline

# Creation of the pipeline.
echo -e "${green}Generating the pipeline from the YAML template..."
echo -e ${white}
az pipelines create --name $name --yaml-path ".pipelines/build-pipeline.yml"

# PR creation.
if test -z "$branch"
then
    # No branch specified in the parameters, no Pull Request is created, the code will be stored in the current branch.
    echo -e "${green}No branch specified to do the Pull Request, changes left in the feature/build-pipeline branch."
    echo -e $white
    exit
else
    # Create the Pull Request to merge iinto the specified branch
    echo -e "${green}Creating a Pull Request..."
    echo -e ${white}
    pr=$(az repos pr create --source-branch feature/build-pipeline --target-branch $branch --title "Build Pipeline" --auto-complete true)
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
        # Check if the -p is activated.
        if test -z "$openPR" || test "$openPR" = false
        then
            # -p flag is not activated and the URL to the Pull Request is shown in the console.
            echo -e "${green}Pull Request successfully created."
            echo -e "${green}To review the Pull Request and accept it, click on the following link:"
            echo -e ${white}
            echo ${prURL}
            exit
        else
            # -p flag is activated and a page with the corresponding Pull Request is opened in the web browser.
            echo -e "${green}Pull Request successfully created."
            echo -e "${green}Opening the Pull Request on the web browser..."
            echo -e ${white}
            az repos pr show --id $id --open > /dev/null
            exit
        fi
    fi
fi
