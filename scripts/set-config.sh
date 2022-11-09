#!/bin/bash

# Description
tfvars="./terraform.tfvars"

white='\e[1;37m'
red='\e[0;31m'

pingpong="pong"
for arg in "${@}"
do
    ## Read Key
    if [[ "$arg" == "--"* ]]; then
        if [[ "$pingpong" == "ping" ]]; then
            echo -e "${red}ERROR: Missing value for variable $key ${white}"
            exit 1
        fi
        pingpong="ping"
        key="${arg//--/}"
        # Key contain value -> key=value, separate them in key and value
        if echo "$key" | grep "=" > /dev/null
        then
            key_tmp="$key"
            key=$(echo "$key_tmp" | cut -d'=' -f1)
            value=$(echo "$key_tmp" | cut -d'=' -f2)
            pingpong="pong"
        fi
    # Read Value
    else
        if [[ "$pingpong" == "pong" ]]; then
            echo -e "${red}ERROR: Received two values for variable $key or variable not properly passed as flag ${white}"
            exit 1
        fi
        pingpong="pong"
        value="$arg"
    fi
    # When we have readed key and value do
    if [[ "$pingpong" == "pong" ]]
    then
        # Check if key is to set the file where vars are stored
        if [[ "$key" == "file_set_vars" ]]
        then
            file_set_vars=$value
            echo "File is: $file_set_vars"
        # Write key and value in the file
        else
            # check if file where the vars are stored was set
            if [[ -n "$file_set_vars" ]]
            then
                # Check if key is already in file to replace it
                if grep -qe "$key *= *" $file_set_vars
                then
                    sed -i "s|\($key *= *\).*|\1\"$value\"|" "$file_set_vars"
                # Write new line with the new key=value
                else
                    echo "$key=\"$value\"" >> "$file_set_vars"
                fi
            else
                echo -e "${red}ERROR: Missing file where vars are stored. It must be the first arg (key and value) and the key to set it is: --file_set_vars ${white}"
                exit 1
            fi
        fi
    fi
done
