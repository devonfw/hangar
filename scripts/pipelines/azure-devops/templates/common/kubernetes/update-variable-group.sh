#!/bin/bash
set -e
# Create new variable group.
az pipelines variable-group list --organization "$1" --project "$2" --group-name "$3" --query '[0].name' -o  table | grep -q "^$3" || az pipelines variable-group create --organization "$1" --project "$2" --name "$3" --variables "$4"="$5"
groupid=$(az pipelines variable-group list --organization "$1" --project "$2" --group-name "$3" --query '[0].id' -o  json)
# Update variable value, If already exists or Create new variable.
az pipelines variable-group variable update --organization "$1" --project "$2" --group-id $groupid --name "$4" --value "$5" || az pipelines variable-group variable create --organization "$1" --project "$2" --group-id $groupid --name "$4" --value "$5"
