#!/bin/bash
set -e
registry="$1"

#
if ! ([[ "$registry" =~ .*docker.pkg.dev.* ]] || [[ "$registry" =~ .*gcr.io.* ]])
then
  apt-get update && apt-get install docker.io -y
  if [[ "$registry" =~ .*amazonaws.com.* ]]
  then
	  apt-get install unzip
	  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	  unzip awscliv2.zip
	  ./aws/install
  fi
fi
