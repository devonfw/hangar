#!/bin/bash
while getopts u:g:p:a:s:r: flag
do
    case "${flag}" in
        u) username=${OPTARG};;
        g) groupname=${OPTARG};;
        p) policies=${OPTARG};;
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
    echo "  -a     [Optional] AWS administrator access key"
    echo "  -s     [Optional] AWS administrator secret key"
    echo "  -r     [Optional] AWS region"
    exit
fi

#Argument check
if [ -z "$username" ] || [ -z "$groupname" ];
then
    echo "Missing parameters, -u and -g flags are mandatory."
    echo "Use -h flag to display help."
    exit
fi

#AWS credentials setup
if ! [ -z "$access_key" ]  && ! [ -z "$secret_key" ];
then
    echo "Setting up your AWS credentials.."
    export AWS_ACCESS_KEY_ID=$access_key
    export AWS_SECRET_ACCESS_KEY=$secret_key
fi

#AWS region
if ! [ -z "$region" ];
then
    echo "Setting up your AWS region.."
    export AWS_DEFAULT_REGION=$region

fi

#AWS default output
export AWS_DEFAULT_OUTPUT=json

#Check if AWS credentials are valid
aws sts get-caller-identity &> /dev/null
if ! [ $? -eq 0 ]
then
    echo "Invalid AWS credentials. Please use -a -s flags to setup correctly.";
    exit 
fi

#Create user
echo "Creating new user "$username" .."
aws iam create-user --user-name $username &> /dev/null

#Create access key data and store to variables
echo "Creating access key.."
output=$(aws iam create-access-key --user-name $username)
accessKeyId=$(echo "$output" | python -c  "import sys, json; print(json.load(sys.stdin)['AccessKey']['AccessKeyId'])")
secretAccessKey=$(echo "$output" | python -c  "import sys, json; print(json.load(sys.stdin)['AccessKey']['SecretAccessKey'])")

#Create group in case it does not exists
echo "Checking if "$groupname" group exists. If not, it will be created.."
aws iam create-group --group-name $groupname &> /dev/null

#Attach policies to group
if ! [ -z "$policies" ];
then
    echo "Attaching provided policies to group.."
    IFS=',' read -ra policies_array <<< "$policies"
    for i in "${policies_array[@]}"; do
        aws iam attach-group-policy --group-name $groupname --policy-arn $i

    done
fi

#Add user to group
echo "Adding user "$username" to group "$groupname" .."
aws iam add-user-to-group --group-name $groupname --user-name $username

echo "User $username is ready. Please store the following access data securely:"
echo "Access key ID: "$accessKeyId
echo "Secret access key: "$secretAccessKey