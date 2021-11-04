param($name, $repository, $branch, $yamlPath)

if($args -contains '-h')
{
  echo "Generates a build pipeline on Azure DevOps."
  echo ""
  echo "Arguments:"
  echo "  -name          [Required] Name that will be set to the build pipeline."
  echo "  -repository    [Required] URL of the repository where the code is located."
  echo "  -branch        [Required] Name of the branch for which the pipeline will be configured."
  echo "  -yamlPath                 Path to the yaml file (inside of the repository)."
  exit
}

# Arguments check
if ($name -eq $null -or $repository -eq $null -or $branch -eq $null)
{
    Write-Host "Missing parameters: name, repository and branch parameters are mandatory." -ForegroundColor Red
    echo "Use -h flag to display help."
    exit 1
}

if($args -contains '-yamlPath')
{
    # Create the remote pipeline with an existing yaml file
    az pipelines create --name $name --repository $repository --branch $branch --yaml-path $yamlPath
}
else
{
    # Create the remote pipeline
    az pipelines create --name $name --repository $repository --branch $branch
}