######################################################################################################
# Creation: 18/10/2021 Timothé Paty
# Description: 	Script to create a repo on azure, you can choose between three differents way of creation
#
# Arguments:  -action:        Type of action you want to do: import, empty, push
#             -name:          name of the repository you want to create (mandatory in the case you choose empty,
#                             in other case if not set it will be the name of the directory given without the path)
#             -directory:     path to the directory where you want to clone your repository or directory you want to push/import in your azure project
#             -organisation:  url of your azure organisation
#             -project:       name of you azure project
#             -giturl:        URL of the git repository you want to clone (only if you choose the action import)
#
######################################################################################################
# Modification:		Name									date		Description
# ex : 				Timothé Paty							20/09/2021	adding something because of a reason

####################################################################################################
param($action, $name, $directory, ${organisation}, $project, $giturl)
if( $args -contains '-h')
{
  echo "This script is used to create a repository on your azure project."
  echo ""
  echo "You can create it in 3 different ways:"
  echo "  - 1st case: create an empty repository and clone it to your computer"
  echo "  - 2nd case: import a already existing git repository into your project (Note: all modifications made into your azure repository will not apply into your git repository. As modification made into your git repository will not apply in your azure repo), then clone this repo on your computer"
  echo "  - 3rd case: Convert one of your local folder into a git repository, then push this repository to your azure project, works also if your folder is already a git repo (if it has already a remote repository set, it will ask you a confirmation before setting a new one) "
  echo "arguments:"
  echo "  -action :       (mandatory) The value of this will tell in which case the script must be executed, can be 'empty' (1st case), 'import'(2nd case), 'push'(3rd case)"
  echo "  -name :         (mandatory if the value of 'action' is 'empty') Name the azure repository will have"
  echo "                  if not set for action 'import', it will used the name of the git repository you are trying to import (the one written in the url)"
  echo "                  if not set for action 'push', it will used the name of the directory you will convert"
  echo "  -directory :    (mandatory) Name of the directory where your repository will be clone (for the action 'empty' and 'import'), or name of the folder you want to convert into a git repository (for the action 'push')"
  echo "  -organisation : URL of your azure organisation (mandatory if you did not set one by default)"
  echo "  -project :      (mandatory) name of you azure project"
  echo "  -giturl :       (Mandatory if you choose the action import) URL of the git repository you want to clone"
  exit
}
#We save the path from zhere the script is executing to cd there back at the end of the script
$old_path=$(pwd | Select-Object -ExpandProperty Path)
if ($directory -ne $null) {cd $directory}
$directory_name = Split-Path -Leaf -Path $pwd
$folder_of_script = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

function MSG_ERROR {
 param( [string]$step, $return_code)
 if (-not $return_code)
 {
	Write-Host "a problem occured in the step: $step" -ForegroundColor Red
	Write-Host "stopping the script..." -ForegroundColor Red
  cd $old_path
	exit 1
 }
}

#arguments check
if ($action -eq "empty")
{
  if ($name -eq $null -or $directory -eq $null -or ${organisation} -eq $null -or $project -eq $null)
  {
    Write-Host "You choose the action 'empty' but one of these parameters is null but they are mandatory: -name, -directory, -organisation, -project" -ForegroundColor Red
    echo "you can type -h to get more information about the script"
    cd $old_path
    exit 1
  }
}elseif($action -eq "import"){
  if ($directory -eq $null -or ${organisation} -eq $null -or $project -eq $null -or $giturl -eq $null)
  {
    Write-Host "You choose the action 'import' but one of these parameters is null but they are mandatory: -directory, -organisation, -project, -giturl" -ForegroundColor Red
    echo "you can type -h to get more information about the script"
    cd $old_path
    exit 1
  }else{
    if($name -eq $null) {$name_tmp=$($giturl.Split('/')[-1]); $name=$($name_tmp -replace '\.git', '')}
  }
}elseif($action -eq "push"){
  if ($directory -eq $null -or ${organisation} -eq $null -or $project -eq $null)
  {
    Write-Host "You choose the action 'push' but one of these parameters is null but they are mandatory: -directory, -organisation, -project" -ForegroundColor Red
    echo "you can type -h to get more information about the script"
    cd $old_path
    exit 1
  }else{
    if($name -eq $null) {$name = $directory_name}
  }
}else{
  Write-Host "The parameter -action is not set or not set correctly, its value can be 'push', 'import', 'empty'" -ForegroundColor Red
  echo "you can type -h to get more information about the script"
  cd $old_path
  exit 1
}

az repos create --name $name --organization ${organisation} --project $project
if ($action -eq "push")
{
  git rev-parse --git-dir > $null
  if ($?)
  {
    echo "$pwd is already a git repository, skipping git init and first commit"
  }else{
    echo "$pwd is not a git repository, executing git init and commiting all files ..."
    git init .
    git add -A
    git commit -m "creation of the repository"
  }
  git config --get remote.origin.url > $null
  if ($?)
  {
    $git_url=$(git config --get remote.origin.url)
    $user_input = Read-Host -Prompt "There is already a URL set for the remote repository ($git_url), this script will change this URL so that all the next commits you will push will be done on the azure repository but not on the current one, Press Y to confirm and N to cancel:"
    while ($user_input -ne 'Y' -and $user_input -ne 'N')
    {
      $user_input = Read-Host -Prompt 'Your input is not valid, Press Y to confirm and N to cancel:'
    }
    if ($user_input -eq 'Y')
    {
      echo "      git remote set-url --add --push origin ${organisation}/${project}/_git/$name"
      git remote set-url --add --push origin ${organisation}/${project}/_git/$name
    }else{
      cd $old_path
      exit
    }
  }else{
    git remote add origin ${organisation}/${project}/_git/$name
  }
  git push -u origin --all
}elseif ($action -eq "empty"){
  git clone ${organisation}/${project}/_git/$name
  cd $name
  cp $folder_of_script\README.md .
  git add -A
  git commit -m "Adding README"
  git push
}elseif($action -eq "import"){
  az repos import create --git-url $giturl --organization ${organisation} --project $project --repository $name
  git clone ${organisation}/${project}/_git/$name
}

cd $old_path
