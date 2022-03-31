#!/bin/bash
################################ Description ############################################
# This script is used to get the runId and the result of specific execution of a pipeline
# using the name of the pipeline and the commit on which the pipeline should be executed
################################# Arguments #############################################
# $1 = Name of the pipeline
# $2 = Commit on which the execution you are looking for has been played
# $3 = Branch on which the execution you are looking for has been played
# Using branch while we already use commit can seem like an overkill, but in some particular cases,
# two branches are at the same commit and if pipelines are executed at the same time on those branches,
# it can cause a problem because for one of the branch, when getting the list of execution it will get the first one with the same commit but it can be another branch
################################# Output ################################################
# runId : The Id of the run, you can use it in your pipeline into any task (for example to dowload an artifact from a build pipeline using this Id)
# result : The result of the execution you found, it can be 'canceled', 'failed' or 'succeeded'
################################# Additional infos ######################################
# There is a var called "pipelineRunsListLimit", it limits the size of the list of execution,
# feel free to change this value depending on your project
#########################################################################################
set -e
# Init var
pipelineToFind="$1"
sourceVersion="$2"
sourceBranch="$3"
i=0
pipelineRunsListLimit=100

# Getting the id of the pipeline using the name
pipelineInfo=$(az pipelines show --name "$pipelineToFind")
id=$(echo "$pipelineInfo" | python -c "import sys, json; print(json.load(sys.stdin)['id'])")
# Getting the list of the last execution (the length of the list is defined by the value of $pipelineRunsListLimit)
pipelineList=$(az pipelines runs list --pipeline-ids "$id" --top "$pipelineRunsListLimit" --branch "$sourceBranch")
pipelineListLen=$(echo "$pipelineList" | python -c "import sys,json; print(len(json.load(sys.stdin)))")
# While loop to look at every pipeline execution json one by one
while [[ (("$i" -lt "$pipelineListLen")) ]]
do
  # Getting the commit on which the pipeline has been executed to compare it with the one given as argument
  listSourceVersion=$(echo "$pipelineList" | python -c "import sys, json; print(json.load(sys.stdin)[$i]['sourceVersion'])")
  if test "$listSourceVersion" = "$sourceVersion"
  then
    # If the commit is the one we are looking for, we get the Id of this execution and the result of it (then stop the while loop)
    result=$(echo "$pipelineList" | python -c "import sys, json; print(json.load(sys.stdin)[$i]['result'])")
    runId=$(echo "$pipelineList" | python -c "import sys, json; print(json.load(sys.stdin)[$i]['id'])")
		break
  fi
  ((i+=1))
done

echo "runId=$runId  ;  result=$result"
# Those commands are for exporting the value so they can be used in the rest of the pipeline
echo "##vso[task.setvariable variable=runId;]$runId"
echo "##vso[task.setvariable variable=result;]$result"