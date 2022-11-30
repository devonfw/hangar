#!/bin/bash
set -e
image_name="$1"
# We get the name of the registry from the full image name
firstPartImage=$(echo $image_name | cut -d'/' -f1)
echo $firstPartImage | grep "\." > /dev/null && REGISTRY=$firstPartImage || REGISTRY="docker.io"

#
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
