#!/bin/bash

while getopts u:p:f:c:a:s:r: flag
do
    case "${flag}" in
        u) username=${OPTARG};;
        p) policies=${OPTARG};;
        f) policies_file=${OPTARG};;
        c) custom_policies_file=${OPTARG};;
        a) access_key=${OPTARG};;
        s) secret_key=${OPTARG};;
        r) region=${OPTARG};;
    esac
done

if [ "$1" == "-h" ];
then
    echo "Checks if an IAM user has the provided policies attached"
    echo ""
    echo "Arguments:"
    echo "  -u     [Required] Username whose policies will be checked."
    echo "  -p     [Optional] Policies to be checked, splitted by comma."
    echo "  -f     [Optional] Path to a file containing the policies to be checked."
    echo "  -c     [Optional] Path to a file containing the custom policies to be checked."  
    echo "  -a     [Optional] AWS administrator access key"
    echo "  -s     [Optional] AWS administrator secret key"
    echo "  -r     [Optional] AWS region"
    exit
fi

#Argument check
if [ -z "$username" ] || { [ -z "$policies" ] && [ -z "$policies_file" ] && [ -z "$custom_policies_file" ]; }
then
    echo "Missing parameters, -u and -p, -f or -c flags are mandatory."
    echo "Use -h flag to display help."
    exit
fi


#AWS credentials setup
if [ -n "$access_key" ]  && [ -n "$secret_key" ];
then
    echo "Setting up your AWS credentials.."
    export AWS_ACCESS_KEY_ID=$access_key
    export AWS_SECRET_ACCESS_KEY=$secret_key
fi

#AWS region
if [ -n "$region" ];
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
    echo "Invalid AWS credentials. Please use -a and -s flags to setup correctly.";
    exit 
fi

#Get user groups
echo "Getting user groups.."
user_groups=($(aws iam list-groups-for-user --user-name $username --query 'Groups[].[GroupName]' --output text))

#Loop user groups and get policies from them
echo "Getting policies attached to user groups.."
groups_policies=()
for group in ${user_groups[@]}
do
    cleangroup=$(echo $group | tr -cd '\11\12\15\40-\176')
    groups_policies+=($(aws iam list-attached-group-policies --group-name $cleangroup --query 'AttachedPolicies[].[PolicyArn]' --output text))
done

#Get user-specific policies
echo "Getting user-specific policies.."
user_policies=($(aws iam list-attached-user-policies --user-name $username --query 'AttachedPolicies[].[PolicyArn]' --output text))
all_policies=( "${groups_policies[@]}" "${user_policies[@]}")

green='\e[1;32m'
red='\e[0;31m'
white='\e[1;37m'

#Inline policies check
if [ -n "$policies" ];
then
    echo "Checking inline provided policies.."
    IFS=',' read -ra policies_array <<< "$policies"
    for policy_to_check in "${policies_array[@]}"; do
        policy_to_check=$(echo $policy_to_check | tr -cd '\11\12\15\40-\176')
        policy_exists=$(printf '%s\n' "${all_policies[@]}" | grep "$policy_to_check")
        if [ -n "$policy_exists" ];
        then
            echo -e "${green}OK        $policy_to_check"
        else
            echo -e "${red}FAILED        $policy_to_check"
            exit 1;
        fi
        echo -e ${white}
    done
fi

#File policies check
if [ -n "$policies_file" ];
then
    echo "Checking file provided policies.."
    IFS=$'\r\n' GLOBIGNORE='*' command eval  'policies_file_array=($(cat ${policies_file}))'
    for policy_to_check in "${policies_file_array[@]}"
    do
        policy_to_check=$(echo $policy_to_check | tr -cd '\11\12\15\40-\176')
        policy_exists=$(printf '%s\n' "${all_policies[@]}" | grep "$policy_to_check")
        if [ -n "$policy_exists" ];
        then
            echo -e "${green}OK        $policy_to_check"
        else
            echo -e "${red}FAILED        $policy_to_check"
            exit 1;
        fi
        echo -e ${white}
    done
fi

#Custom policies check
if [ -n "$custom_policies_file" ];
then
    echo "Checking custom policies.."
    #Group custom policies add to var
    json_custom_policies="["
    for group in ${user_groups[@]} #Loop all groups
    do
        cleangroup=$(echo $group | tr -cd '\11\12\15\40-\176')
        group_custom_policies=($(aws iam list-group-policies --group-name $cleangroup --query 'PolicyNames[]' --output text))
        #Loop all custom policies from the group
        
        for group_custom_policy in ${group_custom_policies[@]} #Loop all groups
        do
            json_custom_policies+=$(aws iam get-group-policy --group-name $cleangroup --policy-name $group_custom_policy)
            json_custom_policies+=","
        done
    done #All group custom policies are included in json_custom_policy var

    #User specific custom policies add to var
    user_custom_policies=($(aws iam list-user-policies --user-name $username --query 'PolicyNames[]' --output text))
        for user_custom_policy in ${user_custom_policies[@]} #Loop all groups
        do
            json_custom_policies+=$(aws iam get-user-policy --user-name $username --policy-name $user_custom_policy)
            json_custom_policies+=","
        done    

    json_custom_policies="${json_custom_policies::-1}"
    json_custom_policies+="]"

    #Check custom policies
    python custom-policies-check.py "${json_custom_policies}" $custom_policies_file

    #Return correct exit code depending on python script execution
    ret=$?
    if [ $ret -ne 0 ]; then
        #Error
        exit 1;
    fi

fi