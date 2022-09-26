#!/bin/bash
while getopts g:p:r:f:c:u: flag
do
    case "${flag}" in
        g) google_account=${OPTARG};;
        p) project_id=${OPTARG};;
        r) roles=${OPTARG};;
        f) roles_file=${OPTARG};;
        c) custom_role=${OPTARG};;
	u) custom_role_id=${OPTARG};;
    esac
done

if [ "$1" == "-h" ];
then
    echo "Enrolls a Google Account (end user) in a project with the provided roles attached."
    echo ""
    echo "Arguments:"
    echo "  -g     [Required] Google Account for the end user."
    echo "  -p     [Required] Project ID where the user will be added"
    echo "  -r     [Optional] Roles (Basic or Predefined) to be attached to the user in the project, splitted by comma."
    echo "  -f     [Optional] Path to a file containing the roles (Basic or predefined) to be attached to the user in the project."   
    echo "  -c     [Optional] Path to a YAML file containing the custom role to be attached to the user in the project."
    echo "  -u     [Optional] Custom Role ID"
    exit
fi

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

#Argument check
if [ -z "$google_account" ] || [ -z "$project_id" ];
then
    echo -e "${red}Error: Missing parameters, -g and -p flags are mandatory." >&2
    echo -e "${red}Use -h flag to display help." >&2
    exit 2
fi

if ([ "$custom_role" ] && [ -z "$custom_role_id" ]) || ([ -z "$custom_role" ] && [ "$custom_role_id" ]);
then
    echo -e "${red}Error: -c and -i parameters must be used together." >&2
    echo -e "${red}Use -h flag to display help." >&2
    exit 2
fi

#Check if GCP CLI is installed
if ! [ -x "$(command -v gcloud)" ]; then
  echo -e "${red}Error: GCP CLI is not installed." >&2
  exit 127
fi

#Check if Python is installed
if ! [ -x "$(command -v python)" ]; then
  echo -e "${red}Error: Python is not installed." >&2
  exit 127
fi

#Authenticate (interactively) with the master user
gcloud auth login
if ! [ $? -eq 0 ]
then
    echo -e "${red}Error: Authentication process failed. Please make sure you are copying the right verification code." >&2
    exit 2
fi

#Check if the provided project_id exists and in that case set it as working project
output=$(gcloud projects list --format="json" --filter=$project_id)
if [ "$output" == "[]" ]
then
    echo -e "${red}Error: The provided project ID does not exist" >&2
    exit 2
else
    gcloud config set project $project_id
fi

#Attach roles to user in project (From command line)
if [ -n "$roles" ];
then
    echo "Attaching provided roles to user in project $project_id..."
    IFS=',' read -ra roles_array <<< "$roles"
    for i in "${roles_array[@]}"; do
        gcloud projects add-iam-policy-binding $project_id --member=user:$google_account --role=$i
	if ! [ $? -eq 0 ]
	then
	    echo -e "${red}Error: Attaching role $i to $google_account for project $project_id.." >&2
            exit 2
	fi
    done
fi

#Attach roles to user in project (From file)
if [ -n "$roles_file" ];
then
    echo "Attaching provided roles in file $roles_file to user $google_account in project $project_id..."
    
    IFS=$'\r\n' GLOBIGNORE='*' command eval  'roles_file_array=($(cat ${roles_file}))'
    for i in "${roles_file_array[@]}"
    do
        gcloud projects add-iam-policy-binding $project_id --member=user:$google_account --role=$i
	if ! [ $? -eq 0 ]
	then
	    echo -e "${red}Error: Attaching role $i to $google_account for project $project_id.." >&2
	    exit 2
        fi
    done
fi

#Create and attach custom role to user in project (From YAML file)
if [ -n "$custom_role" ];
then
    echo "Creating and attaching custom role to user in project..."
    gcloud iam roles create $custom_role_id --project=$project_id --file=$custom_role
    gcloud projects add-iam-policy-binding $project_id --member=user:$google_account --role=projects/$project_id/roles/$custom_role_id
fi
