#!/bin/bash
while getopts g:s:p:r:f:c:i:h: flag
do
    case "${flag}" in
        g) google_account=${OPTARG};;
	    s) service_account=${OPTARG};;
        p) project_id=${OPTARG};;
        r) roles=${OPTARG};;
        f) roles_file=${OPTARG};;
        c) custom_role=${OPTARG};;
	i) custom_role_id=${OPTARG};;
    esac
done

if [ "$1" == "-h" ];
then
    echo "Enrolls a Principal in a project with the provided roles attached."
    echo ""
    echo "Arguments:"
    echo "  -g     [Required] Google Account for the end user. (mutual exclusive with -s)"
    echo "  -s     [Required] Service Account name. (mutual exclusive with -g)"
    echo "  -p     [Required] Project ID where the user will be added"
    echo "  -r     [Optional] Roles (Basic or Predefined) to be attached to the user in the project, splitted by comma."
    echo "  -f     [Optional] Path to a file containing the roles (Basic or predefined) to be attached to the user in the project."   
    echo "  -c     [Optional] Path to a YAML file containing the custom role to be attached to the user in the project."
    echo "  -i     [Optional] Custom Role ID"
    exit
fi

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

#Argument check
#Missing arguments
if [ -z "$google_account" ] && [ -z "$service_account" ] || [ -z "$project_id" ];
then
    echo -e "${red}Error: Missing parameters, -g or -s (mutually exclusive) and -p flags are mandatory." >&2
    echo -e "${red}Use -h flag to display help." >&2
    exit 2
fi

#Only google_account or service_account allowed
if [ -n "$google_account" ] && [ -n "$service_account" ];
then
    echo -e "${red}Error: Parameters -g or -s are mutually exclusive" >&2
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

#Check if the provided project_id exists and in that case set it as working project
output=$(gcloud projects list --format="json" --filter=$project_id)
if [ "$output" == "[]" ]
then
    echo -e "${red}Error: The provided project ID does not exist" >&2
    exit 2
else
    gcloud config set project $project_id
fi

#Check if the service account exists and if not, create it
if [ -n "$service_account" ];
then
    all_service_accounts=$(gcloud iam service-accounts list --format="value(email)")
    all_service_accounts_array=($all_service_accounts)
    service_account_email="$service_account@$project_id.iam.gserviceaccount.com"
    if [[ " ${all_service_accounts_array[*]} " =~ " ${service_account_email} " ]];
    then
        echo "The service account $service_account_email exists already. Proceeding to use it"
    else
	echo "Creating new service account: $service_account_email"
	gcloud iam service-accounts create $service_account --display-name="$service_account"
        gcloud iam service-accounts keys create ./key.json --iam-account=$service_account_email
	
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
    echo "Attaching provided roles to principal in project $project_id..."
    IFS=',' read -ra roles_array <<< "$roles"
    for i in "${roles_array[@]}"; do
	    gcloud projects add-iam-policy-binding $project_id --member=$memberValue --role=$i
	    if ! [ $? -eq 0 ]
	    then
	        echo -e "${red}Error: Attaching role $i to $memberValue for project $project_id.." >&2
            exit 2
	    fi
    done
fi

#Attach roles to principal in project (From file)
if [ -n "$roles_file" ];
then
    echo "Attaching provided roles in file $roles_file to principal in project $project_id..."
    IFS=$'\r\n' GLOBIGNORE='*' command eval  'roles_file_array=($(cat ${roles_file}))'
    for i in "${roles_file_array[@]}"
    do
	    gcloud projects add-iam-policy-binding $project_id --member=$memberValue --role=$i
	    if ! [ $? -eq 0 ]
	    then
	        echo -e "${red}Error: Attaching role $i to $memberValue for project $project_id.." >&2
	        exit 2
        fi
    done
fi

#Create and attach custom role to principal in project (From YAML file)
if [ -n "$custom_role" ];
then	
    echo "Creating and attaching custom role to principal in project..."
    gcloud iam roles create $custom_role_id --project=$project_id --file=$custom_role
    gcloud projects add-iam-policy-binding $project_id --member=$memberValue --role=projects/$project_id/roles/$custom_role_id
    if ! [ $? -eq 0 ]
	then
	    echo -e "${red}Error: Attaching custom role $i to $memberValue for project $project_id.." >&2
	    exit 2
    fi
fi
