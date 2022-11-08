#!/bin/bash

# exit when any command fails
set -e
provider="Google Cloud"

white='\e[1;37m'
red='\e[0;31m'

function create_repo_content {
    gcloud source repos create "$1" --project "$3"
    MSG_ERROR "Creating repo $1" "$?"
}

function import_repo_content {
    git clone --bare "$1"
    source_repo_namegit=${1##*/}
    cd "$source_repo_namegit" || exit

    #Check if is a windows or linux installation (GCloud CLI)
    if [ -e "$(command -v gcloud.cmd)" ]; then
        git config credential.helper gcloud.cmd
    elif [ -e "$(command -v gcloud)" ]; then
        git config credential.helper gcloud.sh
    fi

    git remote add google https://source.developers.google.com/p/"$3"/r/"$4"
    git push --all google
    cd .. 
    #Remove git clone --bare created dir
    rm -rf "$source_repo_namegit"
}

function prepare_push_existing_repo_content {

    #Check if is a windows or linux installation (GCloud CLI)
    if [ -e "$(command -v gcloud.cmd)" ]; then
        git config credential.helper gcloud.cmd
    elif [ -e "$(command -v gcloud)" ]; then
        git config credential.helper gcloud.sh
    fi

    URL_space_converted="https://source.developers.google.com/p/$2/r/$3"
}

function arguments_check_content {
    if [ "$project" = "" ]
    then
        echo -e "${red}You chose a Google Cloud repository as target but -p flag is missing."
        echo -e "${white}Use -h or --help flag to display help."
    exit 1
    fi
}

function custom_vars_assignment {
    #Initialising variables used in common script by other providers to prevent errors
    organization=""
    ghuser=""
}

function clone_git_project_import {
    gcloud source repos clone "$name" --project="$project"
}

function clone_git_project_create {
    gcloud source repos clone "$name" --project="$project"
}

source "$(dirname $0)/../common/create-repo.sh"


