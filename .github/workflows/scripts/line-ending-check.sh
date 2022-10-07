#!/bin/bash
output=$(find ${1:-.} -not -type d -print0 | xargs -0 dos2unix -ic | cut -c 3-)
if [ "$output" == "" ] ; then
    exit 0
else
    echo "The following files have Windows line ending:"
    echo ""
    echo "$output"
    echo ""
    echo "No changes were made on the repository. Please change line endings to Unix style for passing this check."
    
    exit 1
fi
