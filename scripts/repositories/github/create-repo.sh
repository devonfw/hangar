#!/bin/bash
provider="GitHub"
function create_repo_content {
   if [ "$5" == "true" ]
    then
      gh repo create "$1" --public
    else
      gh repo create "$1" --private
    fi
}

function set_default_branch_and_policies_content_1 {
    gh repo edit "$6/$4" --default-branch master > /dev/null
}

function set_default_branch_and_policies_content_2 {
        if [ "$7" = "true" ] # $7=true to ensure is a public repo. (Only works on public or Github Pro repos)
        then
          # Enable branch protection and comment resolution policy all in one. Only avaliable to public (or GH Pro) repositories
          if [ "${ENABLE_APPROVE_COUNT}" == "true" ]
          then
            # Get repoid
            repo_id="$(gh api graphql -f query='{repository(owner:"'$6'",name:"'$4'"){id}}' -q .data.repository.id)"
            echo "For $i:"
            echo -e "${blue}Creating rule to need approval of ${REVIEWER_NBR} people. (enable=${ENABLE_APPROVE_COUNT})"
            echo -e "${white}"
            echo -e "${blue}Adding comment resolution policy.(enable=${ENABLE_APPROVE_COUNT})"
            echo -e "${white}"
            gh api graphql -f query='
              mutation($repositoryId:ID!,$branch:String!,$requiredReviews:Int!,$enableCommentResolution:Boolean!) {
                createBranchProtectionRule(input: {
                  repositoryId: $repositoryId
                  pattern: $branch
                  requiresApprovingReviews: true
                  requiredApprovingReviewCount: $requiredReviews
                  requiresConversationResolution: $enableCommentResolution
                }) { clientMutationId }
              }' -f repositoryId="$repo_id" -f branch="[$i]*" -F requiredReviews="${REVIEWER_NBR}" -F enableCommentResolution="${ENABLE_COMMENT_RESOLUTION}"
          fi
          if [ "$ENABLE_MERGE_LIMITS" == "true" ]  
          then
            echo -e "${blue}Adding merge limits.(enable=${ENABLE_APPROVE_COUNT})"
            echo -e "${white}"
            gh repo edit "$6/$4" --enable-rebase-merge="${ALLOW_REBASE_MERGE}" --enable-squash-merge="${ALLOW_SQUASH}" 
          fi
        fi
}

function import_repo_content {
    git clone --bare "$1"
    source_repo_namegit=${1##*/}
    cd "$source_repo_namegit"
    git push --mirror https://github.com/$6/$4.git
}

function prepare_push_existing_repo_content {
    URL_space_converted="https://github.com/$6/$3.git"
}

function custom_vars_assignment {
    organization=""
    project=""
    ghuser=$(gh auth status 2>&1 | sed -n 2p | awk  '{print $7}')
}

function clone_git_project_import {
    git clone "https://github.com/$ghuser/$name.git" "$name"
}

function clone_git_project_create {
    git clone "https://github.com/$ghuser/$name.git" .
}

source "$(dirname $0)/../common/create-repo.sh"
