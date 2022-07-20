groupid=$(az pipelines variable-group list --group-name "$1" --query '[0].id' -o  json)
if test -z $groupid
then
    az pipelines variable-group create --name "$1" --variables "$2"="$3"
else 
    az pipelines variable-group variable create --group-id "$groupid" --name "$2" --value "$3"
fi