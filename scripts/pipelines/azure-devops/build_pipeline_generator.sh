while getopts n:r:l:d: flag
do
    case "${flag}" in
        n) name=${OPTARG};;
        r) repository=${OPTARG};;
        l) language=${OPTARG};;
        d) directory=${OPTARG};;
    esac
done

if test "$1" = "-h"
then
    echo "Generates a build pipeline on Azure DevOps from a yml template according to your programming language"
    echo ""
    echo "Arguments:"
    echo "  -n    [Required] Name that will be set to the build pipeline."
    echo "  -r    [Required] URL of the repository where the code is located."
    echo "  -l    [Required] Language in which your project is programmed."
    echo "  -d    [Required] Local directory of your project (the path should be using '/' and not '\')."
    exit
fi

# Argument check
if test -z "$name" || test -z "$repository" || test -z "$language" || test -z "$directory"
then
    echo "Missing parameters, all the flags are mandatory."
    echo "Use -h flag to display help."
    exit
fi

yamlFile="${language}-build-pipeline.yml"

# Copy the yml template into the local repository
echo "Adding the yml template into the repository..."
cd ../../../templates
cp ${yamlFile} ${directory}

# Move into the project's directory and pushing the template into the Azure DevOps repository.
echo "Adding the yml template into your Azure DevOps repository..."
cd ${directory}
git add ${yamlFile}
git commit -m "Added yml file into Azure DevOps repository"
git push -u origin --all

# Creation of the pipeline
echo "Generating the pipeline from the yml template..."
az pipelines create --name $name --repository $repository --yaml-path $yamlFile