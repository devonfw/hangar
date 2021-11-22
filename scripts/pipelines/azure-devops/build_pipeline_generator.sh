while getopts n:l:d: flag
do
    case "${flag}" in
        n) name=${OPTARG};;
        l) language=${OPTARG};;
        d) directory=${OPTARG};;
    esac
done

if test "$1" = "-h"
then
    echo "Generates a build pipeline on Azure DevOps from a YAML template according to the project programming language or framework."
    echo ""
    echo "Arguments:"
    echo "  -n    [Required] Name that will be set to the build pipeline."
    echo "  -l    [Required] Language or framework of the project."
    echo "  -d    [Required] Local directory of your project (the path should always be using '/' and not '\')."
    exit
fi

# Argument check
if test -z "$name" || test -z "$directory"
then
    echo "Missing parameters, all flags are mandatory."
    echo "Use -h flag to display help."
    exit
fi

yamlFile="${language}-build-pipeline.yml"
pipelinesDirectory="${directory}/.pipelines"
oldPath=$(pwd)

cd ${directory}
# Check if there is a .pipelines directory in the projects's directory. 
if test ! -d "$pipelinesDirectory"
then
    # Creates a folder called .pipelines to store the pipelines.
    mkdir pipelines
    mv pipelines .pipelines
fi

# Copy the yml template into the local repository
echo "Copying the YAML template into the repository..."
cd ${oldPath}
cd ../../../templates

cp ${yamlFile} ${pipelinesDirectory}

# Move into the project's directory and pushing the template into the Azure DevOps repository.
echo "Committing and pushing to Git remote..."
cd ${directory}
git add ${pipelinesDirectory}
git commit -m "Adding build pipeline source YAML"
git push -u origin --all

# Creation of the pipeline
echo "Generating the pipeline from the YAML template..."
az pipelines create --name $name --yaml-path ".pipelines/$yamlFile"