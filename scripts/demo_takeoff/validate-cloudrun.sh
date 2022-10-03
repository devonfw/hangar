#!/bin/bash
while getopts s:p:r:h flag
do
    case "${flag}" in
        p) project=${OPTARG};;
        r) region=${OPTARG};;
    esac
done

if [ "$1" == "-h" ];
then
    echo "Deploys hello-world example on CloudRun"
    echo ""
    echo "Arguments:"
    echo "  -p     [Required] Project ID where the deployment will be performed."
    echo "  -r     [Required] Region"
    exit
fi

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

#Argument check
if [ -z "$project" ] || [ -z "$region" ];
then
    echo -e "${red}Error: Missing parameters, -s, -p and -r are required." >&2
    echo -e "${red}Use -h flag to display help." >&2
    exit 2
fi
gcloud run deploy hello-world --image gcr.io/cloudrun/hello --project $project --region $region --allow-unauthenticated
