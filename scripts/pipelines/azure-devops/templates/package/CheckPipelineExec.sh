# Init var
Pipeline_to_find="$1"
sourceVersion="$2"
i=0
number_lst=100
encontrado="false"


pipelineInfo=$(az pipelines show --name "$Pipeline_to_find")
id=$(echo "$pipelineInfo" | python -c "import sys, json; print(json.load(sys.stdin)['id'])")
pipelineList=$(az pipelines runs list --pipeline-ids $id --top $number_lst)

while [[ (("$i" -lt "$number_lst")) ]]
do
    listSourceVersion=$(echo "$pipelineList" | python -c "import sys, json; print(json.load(sys.stdin)[$i]['sourceVersion'])")
	echo "$listSourceVersion = $sourceVersion"
    if test "$listSourceVersion" = "$sourceVersion"
    then
        encontrado="true"
        result=$(echo "$pipelineList" | python -c "import sys, json; print(json.load(sys.stdin)[$i]['result'])")
        runId=$(echo "$pipelineList" | python -c "import sys, json; print(json.load(sys.stdin)[$i]['id'])")
		break
    fi
    ((i++))
done
echo "##vso[task.setvariable variable=runId;]$runId"
echo "##vso[task.setvariable variable=result;]$result"