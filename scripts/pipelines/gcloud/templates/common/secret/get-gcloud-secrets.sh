#!/bin/bash

echo "Getting secrets from Secret Manager..."
triggerName=$1
confFile=".pipelines/config/pathsSecretFiles.conf"
[[ -f "$confFile" ]] || { echo "No conf file found. Nothing to do."; exit 0; }
grep "$triggerName" "$confFile" >> tmpConfFile
grep "AllPipelines" "$confFile" >> tmpConfFile
echo ""
set -e
while read -r line
do
  if [[ "$line" != "" ]]
  then
    secretName=$(echo "$line" | cut -d= -f1)
    downloadPath=$(echo "$line" | cut -d= -f2 | cut -d' ' -f1)
    echo "gcloud secrets versions access latest --secret=$secretName --out-file=$downloadPath"
    gcloud secrets versions access latest --secret="$secretName" --out-file="$downloadPath"
  fi
done < tmpConfFile
