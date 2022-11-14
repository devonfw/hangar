#!/bin/bash
set -e
confFile=".pipelines/config/pathsSecretFiles.conf"
[[ -f "$confFile" ]] || exit 0
echo "" >> "$confFile"
while read -r line
do
  if [[ "$line" != "" ]]
  then
    secretName=$(echo "$line" | cut -d= -f1)
    downloadPath=$(echo "$line" | cut -d= -f2)
    echo "gcloud secrets versions access latest --secret=$secretName --out-file=$downloadPath"
    gcloud secrets versions access latest --secret="$secretName" --out-file="$downloadPath"
  fi
done < "$confFile"