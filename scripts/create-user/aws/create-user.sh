#!/bin/bash
while getopts u:g: flag
do
    case "${flag}" in
        u) username=${OPTARG};;
        g) groupname=${OPTARG};;
    esac
done

if [ "$1" == "-h" ];
then
    echo "Creates an IAM user, also enrolling it in a newly created group with the provided policies attached."
    echo ""
    echo "Arguments:"
    echo "  -u     [Required] Username for the new user."
    echo "  -g     [Required] Group name for the group to be created or used."
    exit
fi

#Argument check
if [ -z "$username" ] || [ -z "$groupname" ];
then
    echo "Missing parameters, -u and -g flags are mandatory."
    echo "Use -h flag to display help."
    exit
fi

#AWS credentials configure
echo "Introduce your AWS credentials"
aws configure

#Create user
echo "Creating new user "$username" .."
aws iam create-user --user-name $username > /dev/null

#Create access key data and store to variables
echo "Creating access key.."
output=$(aws iam create-access-key --user-name $username)
accessKeyId=$(echo "$output" | python -c  "import sys, json; print(json.load(sys.stdin)['AccessKey']['AccessKeyId'])")
secretAccessKey=$(echo "$output" | python -c  "import sys, json; print(json.load(sys.stdin)['AccessKey']['SecretAccessKey'])")

#Create group
echo "Creating new group "$groupname" .."
aws iam create-group --group-name $groupname > /dev/null

#Attach policies to group
echo "Attaching necessary policies to group.."
aws iam attach-group-policy --group-name $groupname --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam attach-group-policy --group-name $groupname --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam attach-group-policy --group-name $groupname --policy-arn arn:aws:iam::aws:policy/AmazonEKSServicePolicy
aws iam attach-group-policy --group-name $groupname --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
aws iam attach-group-policy --group-name $groupname --policy-arn arn:aws:iam::aws:policy/AmazonEKSVPCResourceController

#Add user to group
echo "Adding user "$username" to group "$groupname" .."
aws iam add-user-to-group --group-name $groupname --user-name $username

echo "User $username is ready. Please store the following access data securely:"
echo "Access key ID: "$accessKeyId
echo "Secret access key: "$secretAccessKey

