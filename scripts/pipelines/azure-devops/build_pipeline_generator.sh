while getopts n:r:b:y: flag
do
    case "${flag}" in
        n) name=${OPTARG};;
        r) repository=${OPTARG};;
        b) branch=${OPTARG};;
        y) yamlPath=${OPTARG};;
    esac
done

if test "$1" = "-h"
then
    echo "Generates a build pipeline on Azure DevOps"
    echo ""
    echo "Arguments:"
    echo "  -n    [Required] Name that will be set to the build pipeline."
    echo "  -r    [Required] URL of the repository where the code is located."
    echo "  -b    [Required] Name of the branch for which the pipelinewill be configured."
    echo "  -y               Path to the yaml file (inside of the repository)"
    exit
fi

if test -z "$name" || test -z "$repository" || test -z "$branch"
then
    echo "Missing parameters, the flgas -n -r and -b are mandatory."
    echo "Use -h flag to display help."
    exit
fi

if test -z "$yamlPath"
then
    echo "Generating build pipeline from scratch..."
    az pipelines create --name $name --repository $repository --branch $branch
else
    echo "Generating build pipelie from the given yaml file..."
    az pipelines create --name $name --repository $repository --branch $branch --yaml-path $yamlPath
fi