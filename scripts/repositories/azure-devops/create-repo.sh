#!/bin/bash
provider="Azure"
function create_repo_content {
    #We redirect the output to a tmp file to be able to parse the content and get the repository Id we will need later
    json_repo=$(az repos create --name "$1" --organization "${2}" --project "$3")
    MSG_ERROR "Creating repo $1" "$?"
    echo "$json_repo"
    repo_id=$(echo "$json_repo" | python -c "import sys, json; print(json.load(sys.stdin)['id'])")
}

function set_default_branch_and_policies_content_1 {
    az repos update --organization "$1" --project "$2" --repository "$4" --default-branch master > /dev/null
}

function set_default_branch_and_policies_content_2 {
        echo "For $i:"
        echo -e "${blue}Creating rule to need approval of ${REVIEWER_NBR} people. (enable=${ENABLE_APPROVE_COUNT})"
        echo -e "${white}"
        az repos policy approver-count create --blocking true --branch "$i" --enabled "${ENABLE_APPROVE_COUNT}" --repository-id "${repo_id}" --minimum-approver-count "${REVIEWER_NBR}" --creator-vote-counts "${CREATOR_VOTE_COUNTS}" --allow-downvotes "${ALLOW_DOWNVOTES}" --reset-on-source-push "${RESET_ON_PUSH}" --project "${2}" --organization "${1}"
        echo -e "${blue}Adding comment resolution policy.(enable=${ENABLE_APPROVE_COUNT})"
        echo -e "${white}"
        az repos policy comment-required create --blocking true --branch "${i}" --enabled "${ENABLE_COMMENT_RESOLUTION}" --repository-id "${repo_id}" --project "${2}" --organization "${1}"
        echo -e "${blue}Adding merge limits.(enable=${ENABLE_APPROVE_COUNT})"
        echo -e "${white}"
        az repos policy merge-strategy create --blocking true --branch "$i" --enabled "${ENABLE_MERGE_LIMITS}" --repository-id "${repo_id}" --allow-no-fast-forward "${ALLOW_NO_FAST_FORWARD}" --allow-rebase "${ALLOW_REBASE}" --allow-rebase-merge "${ALLOW_REBASE_MERGE}" --allow-squash "${ALLOW_SQUASH}" --branch-match-type exact --project "${2}" --organization "${1}"

}

function import_repo_content {
    az repos import create --git-url "$1" --organization "${2}" --project "$3" --repository "$4" > /dev/null
}

function prepare_push_existing_repo_content {
    URL_space_converted=$(echo "${1}/${5}/_git/$3" | sed 's/\ /%20/g')
}

function arguments_check_content {
    if [ "${organization}" = "" ] || [ "$project" = "" ]
    then
    echo -e "${red}You chose an Azure repository as target but one of these mandatory flags is missing: -o, -p."
    echo "Use -h or --help flag to display help."
    exit 1
    fi
}

function custom_vars_assignment {
    #Initialising variables used in common script by other providers to prevent errors
    ghuser=""
}

function clone_git_project_import {
    git clone "${organization}/${project_convertido}/_git/${name// /%20}" "$name"
}

function clone_git_project_create {
    git clone "${organization}/${project_convertido}/_git/${name// /%20}" .
}

source "$(dirname $0)/../common/create-repo.sh"
