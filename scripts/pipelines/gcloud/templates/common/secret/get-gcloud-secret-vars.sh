#!/bin/bash

echo "Getting secret vars from Secret Manager..."
triggerName=$1
confFile=".pipelines/config/secret-vars.conf"
envSecretFile=".pipelines/config/${triggerName}.env"
[[ -f "$confFile" ]] || { echo "No conf file found. Nothing to do."; exit 0; }
grep "$triggerName" "$confFile" >> tmpConfFileSecretVar
grep "AllPipelines" "$confFile" >> tmpConfFileSecretVar
echo "" >> tmpConfFileSecretVar
echo ""
set -e
while read -r line
do
  if [[ "$line" != "" ]]
  then
    secretName=$(echo "$line" | cut -d' ' -f1)
    echo "gcloud secrets versions access latest --secret=$secretName"
    secretValue=$(gcloud secrets versions access latest --secret="$secretName")
    echo "export $secretName=\"$secretValue\"" >> "$envSecretFile"
  fi
done < tmpConfFileSecretVar
