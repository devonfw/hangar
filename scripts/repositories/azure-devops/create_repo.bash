######################################################################################################
# Creation: 18/10/2021 Timothé Paty
# Description: 	Script to create a repo on azure, you can choose between three differents way of creation
#
# Arguments:  -a:        Type of action you want to do: import, create, push
#             -n:        name of the repository you want to create (mandatory in the case you choose create,
#                             in other case if not set it will be the name of the directory given without the path)
#             -d:        path to the directory where you want to clone your repository or directory you want to push/import in your azure project
#             -o:        url of your azure organization
#             -p:        name of you azure project
#             -g:        URL of the git repository you want to clone (only if you choose the action import)
#             -s:        (default false, and is only used with action 'create') can take true or false, if true a repository of a sample application will be created
#
######################################################################################################
# Modification:		Name									date		Description
# ex : 				Timothé Paty							20/09/2021	adding something because of a reason

####################################################################################################

# We check if the '-h' flag is set
echo $* | grep "\-h" >> /dev/null
RET_GREP=$?
if [ $RET_GREP -eq 0 ] || [ "$*" = "" ]
then
  echo "This script is used to create a repository on your azure project."
  echo ""
  echo "You can create it in 3 different ways:"
  echo "  - 1st case: create an empty repository (or use the example one) and clone it to your computer"
  echo "  - 2nd case: import a already existing git repository into your project (Note: all modifications made into your azure repository will not apply into your git repository. As modification made into your git repository will not apply in your azure repo), then clone this repo on your computer"
  echo "  - 3rd case: Convert one of your local folder into a git repository, then push this repository to your azure project, works also if your folder is already a git repo (if it has already a remote repository set, it will ask you a confirmation before setting a new one) "
  echo "arguments:"
  echo "  -a (for action) :       (mandatory) The value of this will tell in which case the script must be executed, can be 'create' (1st case), 'import'(2nd case), 'push'(3rd case)"
  echo "  -n (for name) :         (mandatory if the value of 'action' is 'create') Name the azure repository will have"
  echo "                          if not set for action 'import', it will used the name of the git repository you are trying to import (the one written in the url)"
  echo "                          if not set for action 'push', it will used the name of the directory you will convert"
  echo "  -d (for directory) :    (mandatory) Name of the directory where your repository will be clone (for the action 'create' and 'import'), or name of the folder you want to convert into a git repository (for the action 'push')"
  echo "  -o (for organization) : URL of your azure organization (mandatory if you did not set one by default)"
  echo "  -p (for project) :      (mandatory) name of you azure project"
  echo "  -g (for giturl) :       (Mandatory if you choose the action import) URL of the git repository you want to clone"
  echo "  -s (for sample) :       (default false, and is only used with action 'create') can take true or false, if true a repository of a sample application will be created"
  exit
fi
sample="false"
yellow='\e[1;33m'
white='\e[1;37m'
red='\e[0;31m'
green='\e[1;32m'
blue='\e[1;34m'
#We read every arguments given
while getopts a:n:d:o:p:g:s: flag
do
  case "${flag}" in
    a) action=${OPTARG};;
    n) name=${OPTARG};;
    d) directory_tmp=${OPTARG};;
    o) organization=${OPTARG};;
    p) project=${OPTARG};;
    g) giturl=${OPTARG};;
    s) sample="true"
esac
done

#We save the path from where the script is executing to cd there back at the end of the script
old_path=$(pwd)
[ "$directory_tmp" != "" ] && directory=$(echo $directory_tmp | sed 's/\\/\//g')
[ "$directory" != "" ] && cd $directory
directory_name=$(basename $(pwd))
folder_of_script=$(dirname $0)

function MSG_ERROR {
 if [ $2 != 0 ]
 then
	echo -e "${red}a problem occured in the step: $1"
	echo -e "stopping the script..."
  echo -e ${white}
  cd $old_path
	exit 1
fi
}

function branch_policy {
  echo ""
  policyMaster=$(az repos policy merge-strategy create --blocking true --branch master --enabled true --repository-id $1 --allow-no-fast-forward false --allow-rebase false --allow-rebase-merge false --allow-squash true --branch-match-type exact --project ${project} --organization ${organization})
  policydevelop=$(az repos policy merge-strategy create --blocking true --branch develop --enabled true --repository-id $1 --allow-no-fast-forward true --allow-rebase false --allow-rebase-merge true  --allow-squash true --branch-match-type exact --project ${project} --organization ${organization})
  echo -e "${blue}As your repository is brand new (it is an empty repository, the sample repository or you just push a regular directory):"
  echo -e "${white}We created a master branch: which is supposed to contain only finished and validated developpement ready to be in production."
  echo -e "We created a develop branch: which is supposed to contain finished development ready to be validate, every feature branch should be created from this branch"
  echo -e "We created a feature branch, this branch is only for the template we use for the name of feature branches"
  echo -e "We also created branch policy for master and develop."
  echo -e "master: We desactivated 'Basic merge (no fast-forward)', 'Rebase and fast-forward', 'Rebase with merge commit' and activated 'Squash merge'"
  echo -e "develop: We desactivated 'Rebase and fast-forward' and activated 'Basic merge (no fast-forward)', 'Rebase with merge commit', 'Squash merge'"
  echo -e "Of course you can still change these policies, this a template we advice you to use."
  echo -e "For more information about branches policies: https://docs.microsoft.com/en-us/azure/devops/repos/git/branch-policies?view=azure-devops&tabs=browser"
}

#arguments check
if [ "$action" = "create" ]
then
  if [ "$name" = "" ] || [ "$directory" = "" ] || [ "${organization}" = "" ] || [ "$project" = "" ]
  then
    echo -e "${red}You chose the action 'create' but one of these parameters is null but they are mandatory: -n, -d, -o, -p"
    echo "you can type -h to get more information about the script"
    cd $old_path
    exit 1
  fi
elif [ "$action" = "import" ]
then
  if [ "$directory" = "" ] ||  [ "${organization}" = "" ] || [ "$project" = "" ] || [ "$giturl" = "" ]
  then
    echo -e "${red}You chose the action 'import' but one of these parameters is null but they are mandatory: -d, -o, -p, -g"
    echo -e "${white}you can type -h to get more information about the script"
    cd $old_path
    exit 1
  else
    echo $name
    [ "$name" = "" ] && echo "ok" && name_tmp=${giturl##*/} && name=$(basename $name_tmp ".git")
  fi
elif [ "$action" = "push" ]
then
  if [ "$directory" = "" ] || [ "${organization}" = "" ] || [ "$project" = "" ]
  then
    echo -e "${red}You chose the action 'push' but one of these parameters is null but they are mandatory: -d, -o, -p"
    echo -e "${white}you can type -h to get more information about the script"
    cd $old_path
    exit 1
  else
    [ "$name" = "" ] && name=$directory_name
  fi
else
  echo -e "${red}The parameter -a is not set or not set correctly, its value can be 'push', 'import', 'create'"
  echo -e "${white}you can type -h to get more information about the script"
  cd $old_path
  exit 1
fi

echo "Creating repo $name"
#We redirect the output to a tmp file to be able to parse the content and get the repository Id we will need later
echo "az repos create --name $name --organization ${organization} --project $project"
az repos create --name $name --organization ${organization} --project $project > ./tmp_json_repo
MSG_ERROR "Creating repo $name" $?
repo_id=$(cat  ./tmp_json_repo | grep '"id"' -m1 | cut -d: -f2 | cut -d, -f1 | tr -d \")
echo ""
echo -e "${blue}Here are all the information about the repository you just created, you can save it in a json file if you feel the need"
cat ./tmp_json_repo
rm -f ./tmp_json_repo
echo -e "--${white}"

if [ "$action" = "push" ]
then
  #We check if the directory is already a git repository or not
  git rev-parse --git-dir > /dev/null
  isGitRepo=$?
  if [ $isGitRepo -eq 0 ]
  then
    echo "$(pwd) is already a git repository, skipping git init and first commit"
  else
    echo "$(pwd) is not a git repository, executing git init and commiting all files ..."
    git init .
# When using git init, the branch created will be the one you definie with this command 'git config --global init.defaultBranch <branch>', we checkout to master in case the default one of the user is different
    git checkout -b master
    git add -A
    git commit -m "creation of the repository"
  fi
# We check if the repo already have an url set
  git config --get remote.origin.url > /dev/null
  if [ $? -eq "0" ]
  then
    git_url=$(git config --get remote.origin.url)
    echo "There is already a URL set for the remote repository ($git_url), this script will change this URL so that all the next commits you will push will be done on the azure repository but not on the current one, Press Y to confirm and N to cancel:"
    read user_input
    while [ "$user_input" != 'Y' ] && [ "$user_input" != 'N' ]
    do
      echo 'Your input is not valid, Press Y to confirm and N to cancel:'
      read user_input
    done
    if [ "$user_input" = 'Y' ]
    then
      echo "      git remote set-url --add --push origin ${organization}/${project}/_git/$name"
      git remote set-url --add --push origin ${organization}/${project}/_git/$name
    else
      cd $old_path
      exit
    fi
  else
    git remote add origin ${organization}/${project}/_git/$name
  fi
  git push -u origin --all
  if [ $isGitRepo -ne 0 ]
  then
    echo "Creating branches and policies because the directory was not a Git repository"
    git checkout -b develop
    git checkout -b feature/TEAM/featureName
    git push -u origin --all
    echo "Setting 'develop' as default branch"
    az repos update --organization ${organization} --project $project --repository "$name" --default-branch develop > /dev/null
    branch_policy $repo_id
    MSG_ERROR "Setting 'develop' branch as default branch" $?
  fi
elif [ "$action" = "create" ]
then
  if [ $sample = "true" ]
  then
    echo "Importing sample repository..."
    az repos import create --git-url "https://github.com/ultymatom/application_sample.git" --organization ${organization} --project $project --repository $name > /dev/null
    MSG_ERROR  "Importing sample repository"  $?
    echo ""
    git clone ${organization}/${project}/_git/$name
    echo ""
  else
    git clone ${organization}/${project}/_git/$name
    cd $name
    git checkout -b master
    cp $folder_of_script/README.md .
    git add -A
    git commit -m "Adding README"
    git checkout -b develop
    git checkout -b feature/TEAM/featureName
    git push -u origin --all

  fi
  echo "Setting 'develop' branch as default branch"
  az repos update --organization ${organization} --project $project --repository "$name" --default-branch develop #> /dev/null
  MSG_ERROR "Setting 'develop' branch as default branch" $?
  branch_policy $repo_id

elif [ "$action" = "import" ]
then
  echo "Importing git repository: $git_url"
  az repos import create --git-url $giturl --organization ${organization} --project $project --repository $name
  MSG_ERROR  "Importing git repository: $git_url" $?
  git clone ${organization}/${project}/_git/$name
fi

cd $old_path
