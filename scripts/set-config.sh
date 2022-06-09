#!/bin/bash

tfvars="./terraform.tfvars"

red='\e[0;31m'
    
list_of_args=( "${@//=/ }" )
pingpong="pong"
for arg in ${list_of_args[@]}
do
    if [[ "$arg" == "-"* ]]; then
        if [[ "$pingpong" == "ping" ]]; then
           echo -e "${red}ERROR: Missing value for variable $key"
           exit 1
        fi
        pingpong="ping"
        key=${arg//-/}
    else
        if [[ "$pingpong" == "pong" ]]; then
           echo -e "${red}ERROR: Received two values for variable $key or variable not properly passed as flag"
           exit 1
        fi
        pingpong="pong"
        value=$arg
        if grep -qe "$key *= *" $tfvars
        then
            sed -i "s|\($key *= *\).*|\1\"$value\"|" "$tfvars"
        else
            echo "$key = \"$value\"" >> "$tfvars"
        fi
    fi
done
