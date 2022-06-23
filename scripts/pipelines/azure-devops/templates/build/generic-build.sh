#!/bin/bash

# We take the first 2 elements of the array because the vso command has a space and is therefore split up by bash.
vsoCommand=$(task build | { read -a array ; echo ${array[@]:0:2} ; })

echo $vsoCommand