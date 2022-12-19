#!/bin/bash
set -e

image_name="$1"
trigger_name="$2"
confFile=".pipelines/config/SecretVars.conf"
envFile=".pipelines/config/${trigger_name}.env"
# We get the name of the registry from the full image name
firstPartImage=$(echo $image_name | cut -d'/' -f1)
echo $firstPartImage | grep "\." > /dev/null && REGISTRY=$firstPartImage || REGISTRY="docker.io"

# Installing tools that we need depending on the registry
if ! { [[ "$REGISTRY" =~ .*docker.pkg.dev.* ]] || [[ "$REGISTRY" =~ .*gcr.io.* ]] ; }
then
  apt-get update && apt-get install docker.io -y
  if [[ "$REGISTRY" =~ .*amazonaws.com.* ]]
  then
	  apt-get install unzip
	  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	  unzip awscliv2.zip
	  ./aws/install
  fi
fi

# Preparing environment variables
if [[ -f ${envFile} ]]
then
  echo "Getting env vars from env file..."
  sed -i 's/export //g' ${envFile}
  sed -i 's/"//g' ${envFile}
  sed -i 's/^#.*$//g' ${envFile}
  echo "" >> ${envFile}
  env_vars=""
  while read -r line
  do
    if [[ "$line" != "" ]]
    then
	  if [[ "${env_vars}" == "" ]]
	  then
		env_vars="${line}"
	  else
        env_vars="${env_vars},${line}"
	  fi
    fi
  done < ${envFile}
  export env_vars
fi

# Preparing secret variables
if [[ -f "$confFile" ]]
then
  set +e
  echo "Getting secret vars from Secret Manager..."
  grep "$trigger_name" "$confFile" >> tmpConfFileSecretVar
  grep "AllPipelines" "$confFile" >> tmpConfFileSecretVar
  echo "" >> tmpConfFileSecretVar
  secret_vars=""
  set -e
  while read -r line
  do
    if [[ "$line" != "" ]]
    then
      secretName=$(echo "$line" | cut -d' ' -f1)
	  if [[ "${secret_vars}" == "" ]]
	  then
		secret_vars="$secretName=$secretName:latest"
	  else
		secret_vars="${secret_vars},$secretName=$secretName:latest"
	  fi
    fi
  done < tmpConfFileSecretVar
  export secret_vars
fi