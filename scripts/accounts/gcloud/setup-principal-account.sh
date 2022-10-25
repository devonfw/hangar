#!/bin/bash

# exit when any command fails
set -e

helpFunction()
{
    echo "Enrolls a Principal (end user or service account) in a project with the provided roles attached."
    echo ""
    echo "Arguments:"
    echo "  -g     [Required] Google Account of an end user. Mutually exclusive with -s."
    echo "  -s     [Required] Service Account name. Mutually exclusive with -g."
    echo "  -p     [Required] Short project name (ID) to which the principal will be enrolled."
    echo "  -r                Roles (basic or predefined) to be attached to the principal in the project, splitted by comma."
    echo "  -f                Path to a file containing the roles (basic or predefined) to be attached to the principal in the project."
    echo "  -c                Path to a YAML file containing the custom role to be attached to the principal in the project. Requires -i."
    echo "  -i                ID to be set to the custom role provided in -c."
    exit
}

while getopts g:s:p:r:f:c:i:h flag
do
    case "${flag}" in
        g) google_account=${OPTARG};;
	s) service_account=${OPTARG};;
        p) project_id=${OPTARG};;
        r) roles=${OPTARG};;
        f) roles_file=${OPTARG};;
        c) custom_role_file=${OPTARG};;
	i) custom_role_id=${OPTARG};;
	h) helpFunction ;;
        ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent.
    esac
done

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

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

if { [ "$custom_role_file" ] && [ -z "$custom_role_id" ]; } || { [ -z "$custom_role_file" ] && [ "$custom_role_id" ]; };
then
    echo -e "${red}Error: -c and -i parameters must be used together." >&2
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
	echo -e "${white}Creating new service account: $service_account_email..."
	if ! gcloud iam service-accounts create "$service_account" --display-name="$service_account" &> /dev/null;
	then
	     echo -e "${red}Error: Cannot create service account with display name $service_account." >&2
	     echo -ne "${white}"
	     exit 2
	else
	     echo -e "${green}Service account $service_account created successfully."
	     echo -ne "${white}"
	fi
    else
        echo -e "${white}The service account $service_account_email exists already. Proceeding to use it."
    fi
    echo -e "${white}Creating service-account keys for service account $service_account_email..."
    if ! gcloud iam service-accounts keys create ./key.json --iam-account="$service_account_email" &> /dev/null;
    then      
        echo -e "${red}Error: Service account key could not be created." >&2
        echo -ne "${white}"
	exit 2
    else
        echo -e "${green}Service account key creation ended successfully."
	echo -ne "${white}"
    fi
fi


#Set member value depending on the use of a google account of a service account
if [ -n "$google_account" ]
then
    memberValue="user:$google_account"
elif [ -n "$service_account" ]
then
    memberValue="serviceAccount:$service_account_email"
fi

#Attach roles to principal in project (From command line)
if [ -n "$roles" ];
then
    echo -e "${white}Attaching provided roles to principal in project $project_id..."
    IFS=',' read -ra roles_array <<< "$roles"
    for role_to_check in "${roles_array[@]}"; do
        if ! gcloud projects add-iam-policy-binding "$project_id" --member="$memberValue" --role="$role_to_check" &> /dev/null;
	then
	    echo -e "${red}Error: Attaching role $role_to_check to $memberValue for project $project_id." >&2
	    echo -ne "${white}"
            exit 2
	else
	    echo -e "${green}Attached role $role_to_check to $memberValue in project $project_id."
	    echo -ne "${white}"
	fi
    done
fi

#Attach roles to principal in project (From file)
if [ -n "$roles_file" ];
then
    echo "Attaching provided roles in file $roles_file to principal in project $project_id..."
    IFS=$'\r\n' GLOBIGNORE='*' command eval  'roles_file_array=($(cat ${roles_file}))'
    for role_to_check in "${roles_file_array[@]}"
    do
        if ! gcloud projects add-iam-policy-binding "$project_id" --member="$memberValue" --role="$role_to_check" &> /dev/null;
	then
	    echo -e "${red}Error: Attaching role $role_to_check to $memberValue in project $project_id." >&2
	    echo -ne "${white}"
	    exit 2
	else
            echo -e "${green}Attached role $role_to_check to $memberValue in project $project_id."
            echo -ne "${white}"
        fi
    done
fi

#Create and attach custom role to principal in project (From YAML file)
if [ -n "$custom_role_file" ];
then	
    echo -e "${white}Creating role $custom_role_id defined in $custom_role_file for project $project_id..."
    if ! gcloud iam roles create "$custom_role_id" --project="$project_id" --file="$custom_role_file" &> /dev/null;
    then
        echo -e "${red}Error: Creating custom role $custom_role_id for project $project_id." >&2
        echo -ne "${white}"
	exit 2
    else
	echo -e "${green}Created custom role $custom_role_id for project $project_id successfully."
	echo -ne "${white}"
    fi
    echo -e "${white}Binding role $custom_role_id to principal $memberValue in project $project_id..."
    if ! gcloud projects add-iam-policy-binding "$project_id" --member="$memberValue" --role=projects/"$project_id"/roles/"$custom_role_id" &> /dev/null;
    then
        echo -e "${red}Error: Attaching custom role $custom_role_id to $memberValue in project $project_id." >&2
        echo -ne "${white}"
	exit 2
    else
        echo -e "${green}Attached custom role $custom_role_id to $memberValue in project $project_id successfully."
        echo -ne "${white}"
    fi
fi
