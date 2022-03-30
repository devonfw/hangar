######################################################################################################
# Creation: 18/10/2021 Timothé Paty
# Description: 	Script to create a repo on azure, you can choose between three differents way of creation
#
# Arguments:
# -a, --action                  [Required] Use case to fulfil: create, import."
# -d, --directory               [Required] Path to the directory where your repository will be cloned or initialized."
# -o, --org                                Name of the Azure DevOps organization (mandatory)."
# -p, --project                 [Required] Name of the Azure DevOps project."
# -n, --name                    [Required for action=create] Name for the Azure DevOps repository. By default, the source repository or directory name (either new or existing, depending on use case) is used."
# -g, --source-git-url                     Source URL of the Git repository to import."
# -b, --source-branch                      Source branch to be used as a basis to initialize the repository on import, as master branch."
# -r, --remove-other-branches              When combined with -b (and possibly -s), removes any other remaining branch."
# -s, --setup-branch-strategy              Creates branches and policies required for the desired workflow. Requires -b on import. Accepted values: gitflow."
# -f, --force                              Skips any user confirmation."
#
######################################################################################################
# Modification:		Name									date		Description
# ex : 				Timothé Paty							20/09/2021	adding something because of a reason

####################################################################################################
function help {
  echo "Creates or imports a repository on Azure DevOps."
  echo ""
  echo "It allows you to, based action flag, either:"
  echo ""
  echo "  - Create an empty repository with just a README file and clone it to your computer into the directory you set. Useful when starting a project from scratch."
  echo ""
  echo "  - Import an already existing directory or Git repository into your project giving a path or an URL. Useful for taking to Azure DevOps the development of an existing project"
  echo ""
  echo "Flags:"
  echo "  -a, --action                  [Required] Use case to fulfil: create, import."
  echo "  -d, --directory               [Required] Path to the directory where your repository will be cloned or initialized."
  echo "  -o, --org                     [Required] Name of the Azure DevOps organization (mandatory)."
  echo "  -p, --project                 [Required] Name of the Azure DevOps project."
  echo "  -n, --name                    [Required for action=create] Name for the Azure DevOps repository. By default, the source repository or directory name (either new or existing, depending on use case) is used."
  echo "  -g, --source-git-url                     Source URL of the Git repository to import."
  echo "  -b, --source-branch                      Source branch to be used as a basis to initialize the repository on import, as master branch."
  echo "  -r, --remove-other-branches              When combined with -b (and possibly -s), removes any other remaining branch."
  echo "  -s, --setup-branch-strategy              Creates branches and policies required for the desired workflow. Requires -b on import. Accepted values: gitflow."
  echo "  -f, --force                              Skips any user confirmation."
  exit
}
[ "$*" = "" ] && help
ARGS=$*
FLAGS=$(getopt -a --options a:n:d:o:p:g:b:rs:fh --long "action:,name:,directory:,org:,project:,giturl:,branch:,remove-other-branches,setup-branch-strategy:,force,help" -- "$@")
eval set -- "$FLAGS"
#We read every arguments given
force="false"
remove="false"
help= "false"
while true; do
    case "$1" in
        -a | --action)                          action=$2; shift 2;;
        -n | --name)                            name=$2; shift 2;;
        -d | --directory)                       directory_tmp=$2; shift 2;;
        -o | --org)                             organization="https://dev.azure.com/$2"; shift 2;;
        -p | --project)                         project=$2; shift 2;;
        -g | --giturl)                          giturl_argument=$2; shift 2;;
        -b | --branch)                          branch=$2; shift 2;;
        -r | --remove-other-branches)           remove="true"; shift 1;;
        -s | --setup-branch-strategy)           strategy=$2; shift 2;;
        -h | --help)                            help="true"; shift 1;;
        -f | --force)                           force="true"; shift 1;;
        --) shift; break;;
    esac
done

[ "$help" = "true" ] && help



yellow='\e[1;33m'
white='\e[1;37m'
red='\e[0;31m'
green='\e[1;32m'
blue='\e[1;34m'

project_convertido=$(echo $project | sed 's/\ /%20/g')
absoluteScriptPath=$(realpath $0)
absoluteFolderScriptPath=$(echo "${absoluteScriptPath%/*}/")
function MSG_ERROR {
if [ $2 != 0 ]
then
   echo ""
   echo -e "${red}A problem occured in the step: $1."
   echo -e "Stopping the script..."
   echo -e ${white}
   cd $old_path
   exit 1
fi
}

#We save the path from where the script is executing to cd there back at the end of the script
old_path=$(pwd)
[ "$directory_tmp" != "" ] && directory=$(echo $directory_tmp | sed 's/\\/\//g')
if [ "$directory" != "" ]
then
  cd $directory
  MSG_ERROR "Cding into the directory given." $?
fi
directory_name=$(basename $(pwd))


function create_repo {
  # $1 = name (of the repo)
  # $2 = organization
  # $3 = 'project'
  echo "--"
  echo -e "${blue}Creating repo $1. ${white}"
  echo ""
  #We redirect the output to a tmp file to be able to parse the content and get the repository Id we will need later
  echo "az repos create --name $1 --organization $2 --project "$3""
  az repos create --name $1 --organization ${2} --project "$3" > ./tmp_json_repo
  MSG_ERROR "Creating repo $1" $?
  repo_id=$(cat  ./tmp_json_repo | grep '"id"' -m1 | cut -d: -f2 | cut -d, -f1 | tr -d \")
  echo ""
  cat ./tmp_json_repo
  rm -f ./tmp_json_repo
  echo -e "--${white}"
}

function set_default_branch_and_policies {
  # $1 = organization
  # $2 = project
  # $3 = repository_id
  # $4 = name (of repository)
  # $5 = strategy
  echo "--"
  echo -e "Loading the properties for the strategy you chose."

  load_conf ${absoluteFolderScriptPath}/config/strategy.cfg $5
  echo "Creating the branches needed."
  for i in ${STR_BRANCHES}
  do
    git checkout master
    git checkout -b $i
    git push --set-upstream origin $i
  done
  az repos update --organization ${1} --project "$2" --repository "$4" --default-branch master > /dev/null
  MSG_ERROR "Setting 'master' branch as default branch" $?
  echo ""
  echo -e "${blue}Setting policies for the repository. ${white}"
  STR_BRANCHES_WITH_MASTER="master $STR_BRANCHES"
  for i in $STR_BRANCHES_WITH_MASTER
  do
      echo "For $i:"
      echo -e "${blue}Creating rule to need approval of ${REVIEWER_NBR} people. (enable=${ENABLE_APPROVE_COUNT})"
      echo -e "${white}"
      az repos policy approver-count create --blocking true --branch $i --enabled ${ENABLE_APPROVE_COUNT} --repository-id ${repo_id} --minimum-approver-count ${REVIEWER_NBR} --creator-vote-counts ${CREATOR_VOTE_COUNTS} --allow-downvotes ${ALLOW_DOWNVOTES} --reset-on-source-push ${RESET_ON_PUSH} --project "${2}" --organization "${1}"
      echo ""
      echo -e "${blue}Adding comment resolution policy.(enable=${ENABLE_APPROVE_COUNT})"
      echo -e "${white}"
      az repos policy comment-required create --blocking true --branch ${i} --enabled ${ENABLE_COMMENT_RESOLUTION} --repository-id ${repo_id} --project "${2}" --organization "${1}"
      echo ""
      echo -e "${blue}Adding merge limits.(enable=${ENABLE_APPROVE_COUNT})"
      echo -e "${white}"
      az repos policy merge-strategy create --blocking true --branch $i --enabled ${ENABLE_MERGE_LIMITS} --repository-id ${repo_id} --allow-no-fast-forward ${ALLOW_NO_FAST_FORWARD} --allow-rebase ${ALLOW_REBASE} --allow-rebase-merge ${ALLOW_REBASE_MERGE} --allow-squash ${ALLOW_SQASH} --branch-match-type exact --project "${2}" --organization "${1}"
  done
  echo -e "${blue}According to -s flag we set the branch policies corresponding to $5."

  echo -e "${white}"
  echo "--"
}

function import_repo {
  # $1 = git_url
  # $2 = organization
  # $3 = project
  # $4 = name (of repository)
  echo "--"
  echo -e "${blue}Importing the repo located at $1. ${white}"
  az repos import create --git-url $1 --organization ${2} --project "$3" --repository $4 > /dev/null
  MSG_ERROR  "Importing repository: $1"  $?
  echo "--"
}

function replace_branch_with_reference {
  # will delete a branch and recreate it from a reference, if the branch does not exists it will just create it from reference, if the reference branch is the same as the branch we want to replace it will just skip it
  # $1 = branch we want to replace
  # $2 = reference branch
  echo "--"
  echo -e "${blue}Replacing the branch $1 with the branch $2. ${white}"
  echo ""
  if [ "$1" != "$2" ]
  then
    git checkout $2
    MSG_ERROR  "Checking out to reference branch"  $?
    git branch | grep "${1}$" > /dev/null && echo "The branch $1 already exists, deleting it." && git branch -D $1
    git branch | grep "${1}$" > /dev/null && MSG_ERROR  "Deleting branch $1"  $?
    git checkout -b $1
    git add -A
    git commit -m "Creating $1 from $2"
  fi
  echo "--"
}

function delete_branches_not_in {
  # delete every branches not given in argument
  # no limit of arguments, you just need to give a reference branch as first argument,
  # because we cannot delete the branch we are currently in, so wee need to checkout to a branch we want to keep
  echo "--"
  echo -e "${blue}Deleting every local branches except: $@ ${white}"
  git checkout $1
  branch_list=$(git branch |  sed 's/\*//g')
  for i in $branch_list
  do
    if [[ "$@" == *"$i"* ]]
    then
      echo "Branch $i given in argument of the function, skipping delete."
    else
      echo "Deleting Branch $i"
      git branch -D $i > /dev/null
    fi
  done
}

function push_existing_directory {
  # $1 = organization
  # $2 = project
  # $3 = name (of the repo)
  # $4 = repo_id
  # $5 = project with spaces converted
  # (optional) $6 = branch of reference
  #We check if the directory is already a git repository or not
  echo "--"
  echo -e "${blue}Start of the function to import a directory/repository.${white}"
  echo ""
  git rev-parse --git-dir &> /dev/null
  isGitRepo=$?
  if [ $isGitRepo -eq 0 ]
  then
    echo "$(pwd) is already a git repository, skipping git init and first commit"
    echo ""
    if [ "$6" != "" ]
    then
      echo "You gave a branch with -b flag, that means we are going to take this branch as reference and create master from this one, if it already exists it will be deleted to be created again."
      if [ $force = "false" ]
      then
        echo "Type 'Y' to validate or 'N' to exit the script. (You can use -f flag to skip user confirmation on next executions)"
        read user_input_branch
      else
        user_input_branch='Y'
      fi
      while [ "$user_input_branch" != 'Y' ] && [ "$user_input_branch" != 'N' ]
      do
        echo 'Your input is not valid, Press Y to confirm or N to cancel:'
        read user_input_branch
      done

      if [ "$user_input_branch" = 'Y' ]
      then
        replace_branch_with_reference master $6
      else
        exit
      fi
    fi
  else
    echo "$(pwd) is not a git repository, executing git init and commiting all files ..."
    check_emptyness=$(ls)
    [ "$check_emptyness" = "" ] && echo "Empty folder, adding README.md file" && cp $absoluteFolderScriptPath/README.md .
    git init .
# When using git init, the branch created will be the one you defined with this command 'git config --global init.defaultBranch <branch>', we checkout to master in case the default one of the user is different

    git checkout -b master
    git add -A
    git commit -m "creation of the repository"
  fi
# We check if the repo already have an url set
  git config --get remote.origin.url > /dev/null
  if [ $? -eq "0" ]
  then
    giturl_azure_repo=$(git config --get remote.origin.url)
    echo "There is already a remote origin configured for this repository: ($giturl_azure_repo). This will be changed to the new Azure DevOps repository. Press Y to confirm or N to cancel:"

    if [ "$force" = "false" ]
    then
      read user_input_remote_url
    else
      user_input_remote_url="Y"
    fi
    while [ "$user_input_remote_url" != 'Y' ] && [ "$user_input_remote_url" != 'N' ]
    do
      echo 'Your input is not valid, Press Y to confirm and N to cancel:'
      read user_input_remote_url
    done
    if [ "$user_input_remote_url" = 'Y' ]
    then
      echo "      git remote set-url --add --push origin ${1}/${5}/_git/$3"
      git remote set-url --add --push origin ${1}/${5}/_git/$3
    else
      cd $old_path
      exit
    fi
  else
    echo ""
    echo "Adding remote URL as no URL was previously set."
    git remote add origin ${1}/${5}/_git/$3
    echo ""
  fi
  [ "$remove" = "true" ] && [ $isGitRepo -eq 0 ] && [ "$6" != "" ] && delete_branches_not_in master
  echo "Pushing Every modification on the remote URL we just set."
  echo ""
  git push -u origin --all
  echo ""
  if [ "$strategy" != "" ]
  then
    if [ $isGitRepo -eq 0 ] && [ "$6" = "" ]
    then
      echo -e "${yellow}You gave the '-s' flag but without a branch ('-b' flag) and your directory was already a git repository, we skipped the setting of branch policies.${white}"
    else
      echo "set_default_branch_and_policies ${1} \"$2\" $4 $3 $strategy"
      set_default_branch_and_policies ${1} "$2" $4 $3 $strategy
    fi
  fi
  echo "--"
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
            if echo $line  | grep $SECTION > /dev/null ; then
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



# arguments check
if [ "$action" = "create" ]
then
  if [ "$name" = "" ] || [ "$directory" = "" ] || [ "${organization}" = "" ] || [ "$project" = "" ]
  then
    echo -e "${red}You chose the action 'create' but one of these mandatory flags is missing: -n, -d, -o, -p."

    echo "Use -h or --help flag to display help."

    cd $old_path
    exit 1
  fi
elif [ "$action" = "import" ]
then
  if [ "$directory" = "" ] ||  [ "${organization}" = "" ] || [ "$project" = "" ]
  then
    echo -e "${red}You chose the action 'import' but one of these mandatory flags is missing: -d, -o, -p, -g"

    echo -e "${white}Use -h or --help flag to display help."
    cd $old_path
    exit 1
  else
    if [ "$giturl_argument" = "" ]
    then
      echo -e "${yellow}No Giturl has been given, the directory $directory will be imported then ${white}"
      [ "$name" = "" ] && name=$directory_name && echo -e "${yellow}No name has been given, the repository name will be: ${name} ${white}"
    else
      [ "$name" = "" ]  && name_tmp=${giturl_argument##*/} && name=$(basename $name_tmp ".git") && echo -e "${yellow}No name has been given, the repository name will be: ${name} ${white}"
    fi
  fi
else
  echo -e "${red}The flag -a is not set or invalid. Accepted values are 'import' and 'create'."

  echo -e "${white}Use -h or --help flag to display help."

  cd $old_path
  exit 1
fi

create_repo $name $organization "$project"

if [ "$action" = "import" ]
then
  ls -l
  if [ "$giturl_argument" = "" ]
  then
    push_existing_directory $organization "$project" $name $repo_id $project_convertido $branch
  else
    if [ "$branch" = "" ]
    then
      echo "You have not given a branch name so the repository will be imported as it is"
      import_repo $giturl_argument $organization "$project" $name
      git clone ${organization}/${project_convertido}/_git/$name
    else
      echo -e "${yellow}You have given a branch name so a master branch will be created from this one.${white}"
      if [ "$remove" = "true" ]
      then
        echo "The flag '-r' is detected, cloning only the reference branch: $5."
        ls -l
        git clone --branch $branch $giturl_argument $name
        MSG_ERROR "Cloning the repository using only the branch $branch" $?
      else
        echo "The flag '-r' has not been set, cloning the whole repository."
        ls -l
        git clone $giturl_argument $name
        MSG_ERROR "Cloning the repository" $?
      fi
      cd $name
      MSG_ERROR "Cd into the directory cloned before pushing it, the folder '$name' does not exist in the current directory '$pwd'" $?
      # echo "Deleting the .git folder so that we can initialize this repository with our branches"
      # rm -rf .git
      # MSG_ERROR "Deleting the .git folder so that we can initialize this repository with our branches" $?
      push_existing_directory $organization "$project" $name $repo_id $project_convertido $branch
    fi
  fi
elif [ "$action" = "create" ]
then
  git clone ${organization}/${project_convertido}/_git/$name
  cd $name
  git checkout -b master
  cp $absoluteFolderScriptPath/README.md .
  git add -A
  git commit -m "Adding README"
  git push -u origin --all
  if [ "$strategy" != "" ]
  then
    set_default_branch_and_policies ${organization} "$project" $repo_id $name "$strategy"
  fi
fi

cd $old_path