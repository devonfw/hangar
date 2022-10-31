#!/bin/bash
# Description: 	Script to create a repo, you can choose between three differents way of creation
# exit when any command fails
set -e
function help {
  echo "Creates or imports a repository on $provider."
  echo ""
  echo "It allows you to, based on action flag, either:"
  echo ""
  echo "  - Create an empty repository with just a README file and clone it to your computer into the directory you set. Useful when starting a project from scratch."
  echo ""
  echo "  - Import an already existing directory or Git repository into your project giving a path or an URL. Useful for taking to $provider the development of an existing project."
  echo ""
  echo "Flags:"
  case $provider in

    "Azure")
      echo "  -p, --project                 [Required] Name of the project."
      echo "  -o, --org                     [Required] Name of the organization."
      ;;

    "Github")
      ;;

    "Google Cloud")
      echo "  -p, --project                 [Required] Short name (ID) of the project."
      ;;

    *)
      ;;
  esac

  echo "  -a, --action                  [Required] Use case to fulfil: create, import."
  echo "  -d, --directory               [Required] Path to the directory where your repository will be cloned or initialized."
  echo "  -n, --name                               Name for the $provider repository. By default, the source repository or directory name (either new or existing, depending on use case) is used."
  echo "  -g, --source-git-url                     Source URL of the Git repository to import."
  echo "  -b, --source-branch                      Source branch to be used as a basis to initialize the repository on import, as master branch."
  echo "  -r, --remove-other-branches              Removes branches other than the (possibly new) default one."
  echo "  -s, --setup-branch-strategy              Creates branches and policies required for the desired workflow. Requires -b on import. Accepted values: gitflow."
  echo "  -f, --force                              Skips any user confirmation."
  echo "      --subpath                            When combined with -g and -r, imports only the specified subpath of the source Git repository."
  case $provider in

    azure)
      ;;

    github)
      echo "  -u, --public                             Sets repository scope to public. Private otherwise."
      ;;

    gcloud)
      ;;

    *)
      ;;
  esac

  exit
}
[ "$*" = "" ] && help
FLAGS=$(getopt -a --options a:n:d:o:p:g:b:rs:fhu --long "action:,name:,directory:,org:,project:,giturl:,branch:,remove-other-branches,setup-branch-strategy:,force,help,subpath:,public" -- "$@")
eval set -- "$FLAGS"
#We read every arguments given
force="false"
remove="false"
help="false"
public="false"
while true; do
    case "$1" in
        -a | --action)                          action="$2"; shift 2;;
        -n | --name)                            name="$2"; shift 2;;
        -d | --directory)                       directory_tmp="$2"; shift 2;;
        -o | --org)                             organization="https://dev.azure.com/$2"; shift 2;;
        -p | --project)                         project="$2"; shift 2;;
        -g | --giturl)                          giturl_argument="$2"; shift 2;;
        -b | --branch)                          branch="$2"; shift 2;;
        -r | --remove-other-branches)           remove="true"; shift 1;;
        -s | --setup-branch-strategy)           strategy="$2"; shift 2;;
        -h | --help)                            help="true"; shift 1;;
        -f | --force)                           force="true"; shift 1;;
        --subpath)                              subpath="$2"; shift 2;;
        -u | --public)                          public="true"; shift 1;;
        --) shift; break;;
    esac
done

[ "$help" = "true" ] && help

yellow='\e[1;33m'
white='\e[1;37m'
red='\e[0;31m'
green='\e[1;32m'
blue='\e[1;34m'

project_convertido="${project// /%20}"
absoluteScriptPath=$(realpath "$0")
absoluteFolderScriptPath="${absoluteScriptPath%/*}"
absoluteFolderScriptPath="${absoluteFolderScriptPath}/../common/" # Fixed folder script path to aim to the common path and not to the specific provider path

function MSG_ERROR {
if [ "$2" != 0 ]
then
   echo ""
   echo -e "${red}A problem occured in the step: $1."
   echo -e "Stopping the script..."
   echo -ne "${white}"
   exit 1
fi
}

[ "$directory_tmp" != "" ] && directory=$(echo "$directory_tmp" | sed 's/\\/\//g')
if [ "$directory" != "" ]
then
  [ "$action" == "create" ] && mkdir -p "$directory"
  cd "$directory"
  MSG_ERROR "Cding into the directory given." $?
fi
directory_name=$(basename "$(pwd)")



function create_repo {
  # $1 = name (of the repo)
  # $2 = organization
  # $3 = 'project'
  # $4 = public
  echo "--"
  echo -e "${blue}Creating repo $1. ${white}"
  echo ""
  create_repo_content "$1" "$2" "$3" "$4"
  echo ""
  echo -e "--${white}"
}

function set_default_branch_and_policies {
  # $1 = organization
  # $2 = project
  # $3 = repository_id
  # $4 = name (of repository)
  # $5 = strategy
  # $6 = ghuser
  # $7 = public

  echo "--"
  echo -e "Loading the properties for the strategy you chose."

  load_conf "${absoluteFolderScriptPath}/config/strategy.cfg" "$5"
  echo "Creating the branches needed."
  for i in ${STR_BRANCHES}
  do
    git checkout master
    git checkout -b "$i"
    git push --set-upstream origin "$i"
  done
  type set_default_branch_and_policies_content_1 &> /dev/null && set_default_branch_and_policies_content_1 "$1" "$2" "$3" "$4" "$5" "$6" "$7"
  MSG_ERROR "Setting 'master' branch as default branch." $?
  echo ""
  echo -e "${blue}Setting policies for the repository."
  echo -ne "${white}"
  STR_BRANCHES_WITH_MASTER="master $STR_BRANCHES"
  for i in $STR_BRANCHES_WITH_MASTER
  do
    type set_default_branch_and_policies_content_2 &> /dev/null && set_default_branch_and_policies_content_2 "$1" "$2" "$3" "$4" "$5" "$6" "$7"
  done
  echo -e "${blue}According to -s flag we set the branch policies corresponding to $5."

  echo -ne "${white}"
}

function import_repo {
  # $1 = git_url
  # $2 = organization
  # $3 = project
  # $4 = name (of repository)
  # $5 = public
  # $6 = ghuser
  echo "--"
  echo -e "${blue}Importing the repo located at $1. ${white}"
  import_repo_content "$1" "$2" "$3" "$4" "$5" "$6"
  MSG_ERROR  "Importing repository: $1"  "$?"
  echo "--"
}

function replace_branch_with_reference {
  # will delete a branch and recreate it from a reference, if the branch does not exists it will just create it from reference, if the reference branch is the same as the branch we want to replace it will just skip it
  # $1 = branch we want to replace
  # $2 = reference branch
  echo "--"
  echo -e " ${blue}Replacing the branch $1 with the branch $2. ${white}"
  echo ""
  if [ "$1" != "$2" ]
  then
    git checkout "$2"
    MSG_ERROR  "Checking out to reference branch."  "$?"
    git branch | grep "${1}$" > /dev/null && echo "The branch $1 already exists, deleting it." && git branch -D "$1"
    git branch | grep "${1}$" > /dev/null && MSG_ERROR  "Deleting branch $1."  "$?"
    git checkout -b "$1"
    git add -A
    git commit -m "Creating $1 from $2"
  fi
}

function delete_branches_not_in {
  # delete every branches not given in argument
  # Arguments:
  #             $1 = reference branch
  echo "--"
  echo -e " ${blue}Deleting every local branch except: $1 ${white}"
  git checkout "$1"
  branch_list=$(git branch |  sed 's/\*//g')
  for i in $branch_list
  do
    if [[ "$i" == "$1" ]]
    then
      echo "Skipping $1."
    else
      echo "Deleting Branch $i."
      git branch -D "$i" > /dev/null
    fi
  done
}

function prepare_push_existing_repo {
  # Depending on the flags, will initialize your repo (if not already one), change push URL, remove branches and then push
  # $1 = organization
  # $2 = project
  # $3 = name (of the repo)
  # $4 = repo_id
  # $5 = project with spaces converted
  # $6 = ghuser
  # $7 = public
  # (optional) $8 = branch of reference
  #We check if the directory is already a git repository or not
  echo "--"
  echo -e "${blue}Start of the function to import a directory/repository.${white}"
  echo ""
  git rev-parse --git-dir &> /dev/null
  isGitRepo="$?"
  if [ $isGitRepo -eq 0 ]
  then
    echo "$(pwd) is already a git repository, skipping git init and first commit."
    echo ""
  else
    echo "$(pwd) is not a git repository, executing git init and commiting all files ..."
    check_emptyness=$(ls)
    [ "$check_emptyness" = "" ] && echo "Empty folder, adding README.md file." && cp "$absoluteFolderScriptPath/README.md" .
    git init .
# When using git init, the branch created will be the one you defined with this command 'git config --global init.defaultBranch <branch>', we checkout to master in case the default one of the user is different
    [ "$init_with_default_branch" != "true" ] && echo "Creating master branch." && git checkout -b master
    # We create those two cases because in case we used -r and --subpath we want the default branch to be created and not master
    [ "$init_with_default_branch" = "true" ] && echo "Creating $default_branch branch again." && git checkout -b "$default_branch"
    git add -A
    git commit -m "Creation of the repository."
  fi

# We check if the repo already have an url set
  if git config --get remote.origin.url > /dev/null
  then
    giturl_azure_repo=$(git config --get remote.origin.url)
    echo "There is already a remote origin configured for this repository: ($giturl_azure_repo). This will be changed to the new repository. Press Y to confirm or N to cancel:"

    if [ "$force" = "false" ]
    then
      read -r user_input_remote_url
    else
      user_input_remote_url="Y"
    fi
    while [ "$user_input_remote_url" != 'Y' ] && [ "$user_input_remote_url" != 'N' ]
    do
      echo 'Your input is not valid, Press Y to confirm and N to cancel:'
      read -r user_input_remote_url
    done

    if [ "$user_input_remote_url" = 'Y' ]
    then
      prepare_push_existing_repo_content "$1" "$2" "$3" "$4" "$5" "$6" "$7"
      git remote set-url origin "$URL_space_converted"
    else
      exit
    fi
  else
    echo ""
    echo "Adding remote URL as no URL was previously set."

    prepare_push_existing_repo_content "$1" "$2" "$3" "$4" "$5" "$6" "$7"
    git remote add origin "$URL_space_converted"
    echo ""
  fi

  # Creating master from the reference
  if [ $isGitRepo -eq 0 ]
  then
    if [ "$8" != "" ]
    then
      echo "You gave a branch with -b flag, that means we are going to take this branch as reference and create master from this one, if it already exists it will be deleted to be created again."
      if [ $force = "false" ]
      then
        echo "Type 'Y' to validate or 'N' to exit the script. (You can use -f flag to skip user confirmation on next executions)"
        read -r user_input_branch
      else
        user_input_branch='Y'
      fi
      while [ "$user_input_branch" != 'Y' ] && [ "$user_input_branch" != 'N' ]
      do
        echo 'Your input is not valid, Press Y to confirm or N to cancel:'
        read -r user_input_branch
      done
      if [ "$user_input_branch" = 'Y' ]
      then
        replace_branch_with_reference master "$8"
      else
        exit
      fi
    fi

 # Remove branches (other that master if -b flag, and other than the default one of the repo if no -b flag)
    if [ "$remove" = "true" ]
    then
      [ "$branch" = "" ] && default_branch=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p') && delete_branches_not_in "$default_branch"
      [ "$branch" != "" ] && delete_branches_not_in "master"
    fi
  fi

  # Pushing after setting push URL (and eventually preparing repo with -b -r flags)
  echo "Pushing every modification on the remote URL we just set."
  echo ""
  git push -u origin --all

  # Setting up strategy
  if [ "$strategy" != "" ]
  then
    if [ "$isGitRepo" -eq 0 ] && [ "$8" = "" ]
    then
      echo -e "${yellow}You gave the '-s' flag but without a branch ('-b' flag) and your directory was already a git repository, we skipped the setting of branch policies.${white}"
    else
      set_default_branch_and_policies "${1}" "$2" "$4" "$3" "$strategy" "$6" "$7"
    fi
  fi
}

function load_conf {
# load only the configuration of a specific block from a conf file (only conf under [<section>])
# $1 = configuration file
# $2 = section
    read_line=1
    block_found=0
    SECTION="$2"
    CMDS=""

    while read -r line ; do
        # loop on all the lines of the file

        if [[ "$line" =~ \[*\] ]] ; then
            if (( block_found )) ; then
                break
            fi
            read_line=0
            if echo "$line"  | grep "$SECTION" > /dev/null ; then
                block_found=1
                read_line=1
            fi
        elif (( read_line )) ; then
            CMDS="$CMDS
            $line"
        fi
    done < "$1"

    eval "$CMDS"
}



# Arguments check start
type arguments_check_content &> /dev/null && arguments_check_content
if [ "$action" = "create" ]
then
  if [ "$directory" = "" ]
  then
    echo -e "${red}You chose the action 'create' but one of these mandatory flags is missing: -n, -d."

    echo "Use -h or --help flag to display help."
    exit 1
  else
    [ "$name" = "" ] && name="$directory_name" && echo -e "${yellow}No name has been given, the repository name will be: ${name} ${white}"
  fi
elif [ "$action" = "import" ]
then
  if [ "$directory" = "" ]
  then
    echo -e "${red}You chose the action 'import' but one of these mandatory flags is missing: -d, -g."

    echo -e "${white}Use -h or --help flag to display help."
    exit 1
  else
    if [ "$giturl_argument" = "" ]
    then
      echo -e "${yellow}No Giturl has been given, the directory $directory will be imported then. ${white}"
      [ "$name" = "" ] && name="$directory_name" && echo -e "${yellow}No name has been given, the repository name will be: ${name} ${white}"
    else
      [ "$name" = "" ]  && name_tmp="${giturl_argument##*/}" && name=$(basename "$name_tmp" ".git") && echo -e "${yellow}No name has been given, the repository name will be: ${name} ${white}"
    fi
  fi
else
  echo -e "${red}The flag -a is not set or invalid. Accepted values are 'import' and 'create'."

  echo -e "${white}Use -h or --help flag to display help."
  exit 1
fi

#Arguments check finish

custom_vars_assignment

create_repo "$name" "$organization" "$project" "$public"

if [ "$action" = "import" ]
then
  if [ "$giturl_argument" = "" ]
  then
    prepare_push_existing_repo "$organization" "$project" "$name" "$repo_id" "$project_convertido" "$ghuser" "$public" "$branch"
  else
    if [ "$branch" = "" ] && [ "$remove" = "false" ]
    then
      echo "You have not given a branch name or used the '-r' flag so the repository will be imported as it is."
      import_repo "$giturl_argument" "$organization" "$project" "$name" "$public" "$ghuser"
      clone_git_project_import
    elif [ "$remove" = "true" ] && [ "$subpath" != "" ]
    then
      if ! (echo "The combination of the flags '-r' and '--subpath' has been detected, then we clone only the subpath: $subpath from the branch given or the default one."
      mkdir "$name.tmp"
      MSG_ERROR "Creating folder '$name.tmp'." "$?"
      mkdir "$name"
      MSG_ERROR "Creating folder '$name'." "$?"
      cd "$name.tmp"
      MSG_ERROR "cding into '$name.tmp'." "$?"
      echo "We do a git init an empty directory so we can configure the git sparse-checkout to clone only the wanted subpath."
      git init
      MSG_ERROR "git init" "$?"
      git remote add -f origin "$giturl_argument"
      MSG_ERROR "setting the fetch url with: $giturl_argument" "$?"
      git config core.sparseCheckout true
      MSG_ERROR "Configuring sparseCheckout." "$?"
      echo "$subpath" >> .git/info/sparse-checkout
      MSG_ERROR "Adding subpath to sparse-checkout" "$?"
      [ "$branch" != "" ] || { init_with_default_branch="true" && default_branch=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p' && git pull origin "$default_branch") ; MSG_ERROR "Pulling default branch" "$?"; }
      [ "$branch" = "" ] || { git pull origin "$branch"; MSG_ERROR "Pulling branch: $branch" "$?" ;}
      mv "$subpath" "../$name"
      MSG_ERROR "moving folder to $name." "$?"
      cd "../$name"
      prepare_push_existing_repo "$organization" "$project" "$name" "$repo_id" "$project_convertido" "$ghuser" "$public" "$branch")
      then
        exit 1
      fi
      rm -rf "$name.tmp"
    else
      if [ "$branch" = "" ] && [ "$remove" = "true" ] && [ "$subpath" = "" ]
      then
        echo "'-r' flag detected without '-b' nor '--subpath' flags, cloning repo with default branch."
        git clone "$giturl_argument" "$name"
        MSG_ERROR "Cloning the repository with default branch." "$?"
      else # -b || -b -r || -b --subpath
        echo "'-b' flag detected without the combination of '-r' and '--subpath', cloning repo with reference branch: $branch."
        git clone --branch "$branch" "$giturl_argument" "$name"; MSG_ERROR "Cloning the repository using only the branch $branch." "$?"
        MSG_ERROR "Cloning the repository with reference branch: $branch." "$?"
      fi
      cd "$name"
      MSG_ERROR "Cd into the directory cloned before pushing it, the folder '$name' does not exist in the current directory '$(pwd)'." "$?"
      prepare_push_existing_repo "$organization" "$project" "$name" "$repo_id" "$project_convertido" "$ghuser" "$public" "$branch"
    fi
  fi
elif [ "$action" = "create" ]
then
  cd "$directory"
  MSG_ERROR "Cding into the directory given." "$?"
  clone_git_project_create
  MSG_ERROR "Cloning empty repo." $?
  cd "$directory/$name"
  git checkout -b master
  cp "$absoluteFolderScriptPath/README.md" .
  git add -A
  git commit -m "Adding README"
  git push -u origin --all
  if [ "$strategy" != "" ]
  then
    set_default_branch_and_policies "${organization}" "$project" "$repo_id" "$name" "$strategy" "$ghuser" "$public"
  fi
fi
