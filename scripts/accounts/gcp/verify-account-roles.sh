#!/bin/bash
while getopts g:p:r:f: flag
do
    case "${flag}" in
        g) google_account=${OPTARG};;
        p) project_id=${OPTARG};;
        r) roles=${OPTARG};;
        f) roles_file=${OPTARG};;
    esac
done

if [ "$1" == "-h" ];
then
    echo "Checks if a Google account (end user) has the roles provided in a given project."
    echo ""
    echo "Arguments:"
    echo "  -g     [Required] Google Account for the end user."
    echo "  -p     [Required] Project ID where the roles will be checked"
    echo "  -r     [Optional] Roles (Basic or Predefined) to be checked to the user in the project, splitted by comma."
    echo "  -f     [Optional] Path to a file containing the roles (Basic, predefined and custom) to be checkd to the user in the project."
    exit
fi

green='\e[1;32m'
red='\e[0;31m'
white='\e[1;37m'

#Argument check
if [ -z "$google_account" ] || [ -z "$project_id" ] || { [ -z "$roles" ] && [ -z "$roles_file" ] && [ -z "$custom_role" ]; }
then
    echo -e "${red}Error: Missing parameters, -g and -p and (-r or -f or -c) flags are mandatory." >&2
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

#Check if the provided project_id exists
output=$(gcloud projects list --format="json" --filter=$project_id)
echo $project_id $output
if [ "$output" == "[]" ]
then
    echo -e "${red}Error: The provided project ID does not exist" >&2
    exit 2
fi

#Get ALL user-specific roles in project
all_roles=$(gcloud projects get-iam-policy $project_id --flatten="bindings[].members[]" --format="csv[no-heading](bindings.members.split(':').slice(1:),bindings.role)" | grep $google_account | cut -d ',' -f2)
all_roles_array=($all_roles)


#Inline roles check
if [ -n "$roles" ];
then
    echo "Checking inline roles provided ..."
    IFS=',' read -ra roles_array <<< "$roles"
    for role_to_check in "${roles_array[@]}"; do
        
        if [[ " ${all_roles_array[*]} " =~ " ${role_to_check} " ]]; 
	then
	    echo -e "${green}OK        $role_to_check"
        else
            echo -e "${red}FAILED      $role_to_check"
            exit 1;
        fi
        echo -e ${white}

    done
fi

#Check roles (From file)
if [ -n "$roles_file" ];
then
    echo "Checking roles in file..."

    IFS=$'\r\n' GLOBIGNORE='*' command eval  'roles_file_array=($(cat ${roles_file}))'
    for role_to_check in "${roles_file_array[@]}"
    do
        if [[ " ${all_roles_array[*]} " =~ " ${role_to_check} " ]];
        then
            echo -e "${green}OK        $role_to_check"
        else
            echo -e "${red}FAILED      $role_to_check"
            exit 1;
        fi
     done
fi
