#!/bin/bash

tfvars="./terraform.tfvars"

red='\e[0;31m'

pingpong="pong"
for arg in "${@}"
do
    if [[ "$arg" == "-"* ]]; then
        if [[ "$pingpong" == "ping" ]]; then
            echo -e "${red}ERROR: Missing value for variable $key"
            exit 1
        fi
        pingpong="ping"
	key="${arg//-/}"
	if echo "$key" | grep "=" > /dev/null
	then
	    key_tmp="$key"
	    key=$(echo "$key_tmp" | cut -d'=' -f1)
	    value=$(echo "$key_tmp" | cut -d'=' -f2)
	    pingpong="pong"
	fi
    else
        if [[ "$pingpong" == "pong" ]]; then
            echo -e "${red}ERROR: Received two values for variable $key or variable not properly passed as flag"
            exit 1
        fi
        pingpong="pong"
        value="$arg"
    fi
    if [[ "$pingpong" == "pong" ]]
    then
	if grep -qe "$key *= *" $tfvars
        then
            sed -i "s|\($key *= *\).*|\1\"$value\"|" "$tfvars"
        else
            echo "$key = \"$value\"" >> "$tfvars"
        fi
    fi
done
