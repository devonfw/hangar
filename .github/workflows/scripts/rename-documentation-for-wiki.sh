#!/bin/bash
docBase="."
docType=".asciidoc"

function renameFiles {
  for input in $basePath/*
  do
    echo "reading $input"
    # When folder, call rename again with new base
    if [[ -d "$input" ]]; then
      basePath="$input"
      renameFiles
    # When doctype, do things
    elif [[ "$input" == *"$docType" ]]; then
      name=${input//"./"/}
      base="${name%/*$docType}"
      name=${name//"/"/"-"}
      base=${base//"/"/"-"}
      if [[ "$base" == *"$docType" ]]; then
        base=""
      fi
      ## Change internal links to new base path
      if [[ "$base" != "" ]]; then
        sed -i "s/xref:.\//link:$base-/g" $input
      fi
      ## Move and rename file
      if [[ "$input" != "$docBase/$name" ]]; then
        cp -f $input $docBase/$name
        rm -rf $input
      fi
    fi
  done
}

# 1. Remove src
rm -rf ./src

# 2. call to renameFiles
basePath="$docBase"
renameFiles
