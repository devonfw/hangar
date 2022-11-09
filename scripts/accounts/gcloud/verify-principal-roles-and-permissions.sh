#!/bin/bash

# exit when any command fails
set -e

helpFunction()
{
    echo "Checks if a Principal (end user or service account) has the specified roles and permissions in a given project."
    echo ""
    echo "Arguments:"
    echo "  -g     [Required] Google Account of an end user. Mutually exclusive with -s."
    echo "  -s     [Required] Service Account name. Mutually exclusive with -g."
    echo "  -p     [Required] Short project name (ID) where the roles and permissions will be checked."
    echo "  -r                Roles to be checked, splitted by comma."
    echo "  -f                Path to a file containing the roles to be checked."
    echo "  -e                Permissions to be checked, splitted by comma."
    echo "  -i                Path to a file containing the permissions to be checked."
    exit
}

while getopts g:s:p:r:f:e:i:h flag
do
    case "${flag}" in
        g) google_account=${OPTARG};;
	s) service_account=${OPTARG};;
        p) project_id=${OPTARG};;
        r) roles=${OPTARG};;
        f) roles_file=${OPTARG};;
        e) permissions=${OPTARG};;
	i) permissions_file=${OPTARG};;
	h) helpFunction ;;
        ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent.
    esac
done

green='\e[1;32m'
red='\e[0;31m'
white='\e[1;37m'

#Argument check
#Missing arguments
if [ -z "$google_account" ] && [ -z "$service_account" ] || [ -z "$project_id" ];
then
    echo -e "${red}Error: Missing parameters, -g or -s (mutually exclusive) and -p flags are mandatory." >&2
    echo -e "${red}Use -h flag to display help." >&2
    echo -ne "${white}"
    exit 2
fi

#Only google_account or service_account allowed
if [ -n "$google_account" ] && [ -n "$service_account" ];
then
    echo -e "${red}Error: Parameters -g or -s are mutually exclusive." >&2
    echo -e "${red}Use -h flag to display help." >&2
    echo -ne "${white}"
    exit 2
fi

#Check if GCP CLI is installed
if ! [ -x "$(command -v gcloud)" ]; then
  echo -e "${red}Error: GCP CLI is not installed." >&2
  echo -ne "${white}"
  exit 127
fi

#Check if the provided project_id exists and in that case set it as working project
echo -e "${white}Checking provided project $project_id..."
if ! gcloud projects describe "$project_id" &> /dev/null;
then
    echo -e "${red}Error: The provided project ID does not exist. Please, create it first." >&2
    echo -ne "${white}"
    exit 2
else
    echo -e "${white}Setting current project to $project_id..."
    if ! gcloud config set project "$project_id" &> /dev/null;
    then
        echo -e "${red}Error: Could not set current project to $project_id." >&2
        echo -ne "${white}"
	exit 2
    else
	echo -e "${green}Current project set to $project_id." >&2
	echo -ne "${white}"
    fi
fi

#Check if the service account exists and if not, create it
if [ -n "$service_account" ];
then
    service_account_email="$service_account@$project_id.iam.gserviceaccount.com"
    echo -e "${white}Checking if service account $service_account_email already exists..."
    if ! gcloud iam service-accounts describe "$service_account_email" &> /dev/null;
    then
        echo -e "${red}Error: Service account $service_account_email does not exist. Please, provide a valid one." >&2
        echo -ne "${white}"
	exit 2
    else
        echo -e "${white}The service account $service_account_email is valid."
    fi
fi

#Set member value depending on the use of a google account of a service account
if [ -n "$google_account" ]
then
    memberValue="$google_account"
elif [ -n "$service_account" ]
then
    memberValue="$service_account_email"
fi

echo -e "${white}Retrieving roles and permissions for $memberValue in project $project_id..."

#Get ALL member-specific roles in project
if [ -n "$roles" ] || [ -n "$roles_file" ] || [ -n "$permissions" ] || [ -n "$permissions_file" ]; then
    all_roles=$(gcloud projects get-iam-policy "$project_id" --flatten="bindings[].members[]" --format="csv[no-heading](bindings.members.split(':').slice(1:),bindings.role)" | grep "$memberValue" | cut -d ',' -f2)
    all_roles_array=($all_roles)
fi

#Get ALL member permissions in project
if [ -n "$permissions" ] || [ -n "$permissions_file" ]; then
    all_permissions_array=() #TODO: Use a set data structure instead of array
    for role_to_check in "${all_roles_array[@]}"; do 
        if [[ "$role_to_check" == *"projects"* ]]; then
            customRoleName=$(echo "$role_to_check" | cut -d "/" -f 4)
	    role_permissions=$(gcloud iam roles describe "$customRoleName" --project="$project_id" --format=json --flatten="includedPermissions[]" | grep "includedPermissions" | cut -d ":" -f 2 | cut -d "\"" -f 2)
        else
            role_permissions=$(gcloud iam roles describe "$role_to_check" --format=json --flatten="includedPermissions[]" | grep "includedPermissions" | cut -d ":" -f 2 | cut -d "\"" -f 2)
        fi
        role_permissions_array=($role_permissions)
        all_permissions_array+=(${role_permissions_array[@]})
    done
fi

exitCode=0

#Inline roles check
if [ -n "$roles" ];
then
    echo -e "${white}Checking inline roles provided ..."
    IFS=',' read -ra roles_array <<< "$roles"
    for role_to_check in "${roles_array[@]}"; do
        
        if [[ " ${all_roles_array[*]} " =~ " ${role_to_check} " ]]; # Searches right literal in left array. More info: https://stackoverflow.com/a/15394738  
	then
	    echo -e "${green}OK        $role_to_check"
        else
            echo -e "${red}FAILED      $role_to_check"
	    exitCode=3
            echo -ne "${white}"
        fi
        echo -ne "${white}"

    done
fi

#Check roles (From file)
if [ -n "$roles_file" ];
then
    echo -e "${white}Checking roles in file..."

    IFS=$'\r\n' GLOBIGNORE='*' command eval  'roles_file_array=($(cat ${roles_file}))'
    for role_to_check in "${roles_file_array[@]}" 
    do
        if [[ " ${all_roles_array[*]} " =~ " ${role_to_check} " ]]; # Searches right literal in left array. More info: https://stackoverflow.com/a/15394738
        then
            echo -e "${green}OK        $role_to_check"
            echo -ne "${white}"
        else
            echo -e "${red}FAILED      $role_to_check"
	    exitCode=3
            echo -ne "${white}"
        fi
     done
fi

#Inline permissions check
if [ -n "$permissions" ];
then
    echo -e "${white}Checking inline permissions provided ..."
    IFS=',' read -ra permissions_array <<< "$permissions"
    for permission_to_check in "${permissions_array[@]}"; do
        if [[ " ${all_permissions_array[*]} " =~ " ${permission_to_check} " ]]; # Searches right literal in left array. More info: https://stackoverflow.com/a/15394738
        then
	    echo -e "${green}OK        $permission_to_check"
	    echo -ne "${white}"
	else
	    echo -e "${red}FAILED      $permission_to_check"
	    exitCode=3
	    echo -ne "${white}"
	fi
    done
fi

#Check permissions (From file)
if [ -n "$permissions_file" ];
then
    echo -e "${white}Checking permissions in file..."
    IFS=$'\r\n' GLOBIGNORE='*' command eval  'permissions_file_array=($(cat ${permissions_file}))'
    for permission_to_check in "${permissions_file_array[@]}"
    do
        if [[ " ${all_permissions_array[*]} " =~ " ${permission_to_check} " ]]; # Searches right literal in left array. More info: https://stackoverflow.com/a/15394738
	then
	    echo -e "${green}OK        $permission_to_check"
	    echo -ne "${white}"
	else
            echo -e "${red}FAILED      $permission_to_check"
	    exitCode=3
            echo -ne "${white}"
	fi
    done
fi

exit $exitCode
