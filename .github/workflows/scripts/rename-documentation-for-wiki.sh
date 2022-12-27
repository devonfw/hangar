#!/bin/bash
docBase="."
docType=".asciidoc"
res="test-wiki"
oldPath=()

function renameFiles {
  for input in $basePath/*
  do
    echo "reading... $input"
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
      sed -i "s/xref:/xref:$base-/g" $input
      ## Remove .asciidoc for links
      # sed -i "s/.asciidoc//g" $input
      ## Move and rename file
      cp -f $input $docBase/$name
      rm -rf $input
    fi
  done
}

# 1. Remove src
rm -rf ./src

# 2. call to renameFiles
basePath="$docBase"
renameFiles
