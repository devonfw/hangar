#!/bin/bash
while getopts u:g:p:f:c:a:s:r: flag
do
    case "${flag}" in
        u) username=${OPTARG};;
        g) groupname=${OPTARG};;
        p) policies=${OPTARG};;
        f) policies_file=${OPTARG};;
        c) custom_policies=${OPTARG};;
        a) access_key=${OPTARG};;
        s) secret_key=${OPTARG};;
        r) region=${OPTARG};;
    esac
done

if [ "$1" == "-h" ];
then
    echo "Creates an IAM user, also enrolling it in a group with the provided policies attached."
    echo ""
    echo "Arguments:"
    echo "  -u     [Required] Username for the new user."
    echo "  -g     [Required] Group name for the group to be created or used."
    echo "  -p     [Optional] Policies to be attached to the group, splitted by comma."
    echo "  -f     [Optional] Path to a file containing the policies to be attached to the group."   
    echo "  -c     [Optional] Path to a json file containing the custom policies to be attached to the group."
    echo "  -a     [Optional] AWS administrator access key"
    echo "  -s     [Optional] AWS administrator secret key"
    echo "  -r     [Optional] AWS region"
    exit
fi

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

#Argument check
if [ -z "$username" ] || [ -z "$groupname" ];
then
    echo -e "${red}Error: Missing parameters, -u and -g flags are mandatory." >&2
    echo -e "${red}Use -h flag to display help." >&2
    exit 2
fi

#AWS credentials setup
if [ -n "$access_key" ]  && [ -n "$secret_key" ];
then
    echo "Setting up your AWS credentials..."
    export AWS_ACCESS_KEY_ID=$access_key
    export AWS_SECRET_ACCESS_KEY=$secret_key
fi

#AWS region
if [ -n "$region" ];
then
    echo "Setting up your AWS region..."
    export AWS_DEFAULT_REGION=$region
fi

#AWS default output
export AWS_DEFAULT_OUTPUT=json

#Check if AWS CLI is installed
if ! [ -x "$(command -v aws)" ]; then
  echo -e "${red}Error: AWS CLI is not installed." >&2
  exit 127
fi

#Check if Python is installed
if ! [ -x "$(command -v python)" ]; then
  echo -e "${red}Error: Python is not installed." >&2
  exit 127
fi

#Check if AWS credentials are valid
aws sts get-caller-identity &> /dev/null
if ! [ $? -eq 0 ]
then
    echo -e "${red}Error: Invalid AWS credentials. Please use -a and -s flags to set them correctly." >&2
    exit 2
fi

#Create user
echo "Creating new user "$username"..."
aws iam create-user --user-name $username &> /dev/null

#Create access key data and store to variables
echo "Creating access key..."
output=$(aws iam create-access-key --user-name $username)
accessKeyId=$(echo "$output" | python -c  "import sys, json; print(json.load(sys.stdin)['AccessKey']['AccessKeyId'])")
secretAccessKey=$(echo "$output" | python -c  "import sys, json; print(json.load(sys.stdin)['AccessKey']['SecretAccessKey'])")

#Create group in case it does not exists
echo "Checking if "$groupname" group exists. If not, it will be created..."
aws iam create-group --group-name $groupname &> /dev/null

#Attach policies to group (From command line)
if [ -n "$policies" ];
then
    echo "Attaching provided policies to group..."
    IFS=',' read -ra policies_array <<< "$policies"
    for i in "${policies_array[@]}"; do
        aws iam attach-group-policy --group-name $groupname --policy-arn $i
    done
fi

#Attach policies to group (From file)
if [ -n "$policies_file" ];
then
    echo "Attaching provided policies in file to group..."

    IFS=$'\r\n' GLOBIGNORE='*' command eval  'policies_file_array=($(cat ${policies_file}))'
    for i in "${policies_file_array[@]}"
    do
        aws iam attach-group-policy --group-name $groupname --policy-arn "${i}"
    done
fi

#Create and attach custom policies to group (From json file)
if [ -n "$custom_policies" ];
then
    echo "Creating and attaching custom policies to group..."
    custom_policies_basename="$(basename -- $custom_policies)"
    aws iam put-group-policy --group-name $groupname --policy-name "${custom_policies_basename%.*}" --policy-document "file://${custom_policies}" &> /dev/null
fi

#Add user to group
echo "Adding user "$username" to group "$groupname"..."
aws iam add-user-to-group --group-name $groupname --user-name $username

echo "User $username is ready. Please store the following access data securely:"
echo "Access key ID: "$accessKeyId
echo "Secret access key: "$secretAccessKey