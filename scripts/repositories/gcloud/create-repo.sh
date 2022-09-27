#!/bin/bash
function create_repo_content {
    #We redirect the output to a tmp file to be able to parse the content and get the repository Id we will need later
    gcloud source repos create "$1" --project "$3"
    MSG_ERROR "Creating repo $1" "$?"
}

function set_default_branch_and_policies_content_1 {
    #Is not possible to change the default branch (master) to another in Cloud Source Repos, so we do nothing 
    nothing=""
}

function set_default_branch_and_policies_content_2 {
    #It is not possible to create PR in Cloud Source Repos, so we do nothing here
    nothing=""
}

function import_repo_content {
    git clone --bare "$1"
    source_repo_namegit=${1##*/}
    cd "$source_repo_namegit"
    git config credential.helper gcloud.cmd
    git remote add google https://source.developers.google.com/p/$3/r/$4
    git push --all google
}

function prepare_push_existing_repo_content {
    git config credential.helper gcloud.cmd
    URL_space_converted="https://source.developers.google.com/p/$2/r/$3"
}

function arguments_check_content {
    nothing=""
}

function custom_vars_assignment {
    organization=""
    ghuser=""
}

function clone_git_project_import {
    nothing=""
}

function clone_git_project_create {
    gcloud source repos clone "$name" --project="$project"
}

source "$(dirname $0)/../common/create-repo.sh"


