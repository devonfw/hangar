#! /bin/bash

# Colors for echo
white='\e[1;37m'
red='\e[0;31m'
green='\e[1;32m'
blue='\e[1;34m'

# Terraform state files
stateFile="terraform.tfstate"
varsFile="terraform.tfvars"
outputFile="terraform.tfoutput"

function helpFunction() {
    echo ""
    echo "Deploy, delete or get info about terraform."
    echo "By default the name of the token is hangarToken and is created in the admin account using the default admin password."
    echo ""
    echo "Main commands:"
    echo ""
    echo "  apply         Create or update infrastructure"
    echo "  destroy       Destroy previously-created infrastructure"
    echo "  output        Show output values from your terraform."
    echo ""
    echo "Common flags:"
    echo ""
    echo "  -s, --state-folder    The folder where you are going to save/import your terraform configuration."
    echo "  -k, --output-key      [ONLY FOR output] The key of the terraform output variable that you want to recover."
    echo "  -q, --quiet           To not print any command of the script, only the execution of terraform \$command."
    echo "  -h, --help            Get help for commands."
}

vars=""
while [[ -n "${@}" ]]; do
    case "$1" in
        'apply' | 'destroy')             command="$1 --auto-approve"; shift ;;
        'output')                        command="$1"; silent="true"; shift ;;
        '-s' | '--state-folder')         state="$2"; shift 2 ;;
        '-k' | '--output-key')           key_out="$2"; shift 2 ;;
        '-q' | '--quiet' )                silent="true"; shift ;;
        'help' | '-h' | '--help')        helpFunction; exit ;;
        *)
            if [[ "$1" == *"="* ]]; then
                vars="${vars} \"$1\""
                shift
            elif [[ -n "$2" ]]; then
                vars="${vars} $1 \"$2\""
                shift 2
            fi
            ;;
    esac
done

# Function to silent
silent_cmd() {
    if $silent; then
        "$@" > /dev/null
    else
        "$@"
    fi
}

# Check command provided
if [[ -z "$command" ]]; then
    echo -e "${red}Error: Missing command, need one of the main commands is mandatory." >&2
    echo -e "${red}Use -h or --help flag to display help." >&2
    echo -e "${white}"
    exit 2
fi

# Import config state
if [[ -n "$state" ]]; then
    silent_cmd echo -e "\n${blue}Importing previous state...${white}" 
    if cp -f "$state/$stateFile" "./$stateFile"; then
        silent_cmd echo "Previous state successfully imported."
    else
        silent_cmd echo "Not previous state found."
    fi
    if cp -f "$state/$varsFile" "./$varsFile"; then
        silent_cmd echo "Previous vars successfully imported."
    else
        silent_cmd echo "Not previous vars file found."
    fi
    if cp -f "$state/$outputFile" "./$outputFile"; then
        silent_cmd echo "Previous output successfully imported."
    else
        silent_cmd echo "Not previous output file found."
    fi
fi

# Modify terraform vars
if [[ -n "$vars" && "$command" != "output" ]]; then
    silent_cmd echo -e "\n${blue}Modifying terraform variables...${white}"
    execute="./set-terraform-variables.sh ${vars}"
    silent_cmd eval "${execute}"
fi

# if command is output, clean state var to not export nothing and if key if exist add it to the command.
if [[ "$command" == "output" ]]; then
    state=""
    echo "comand output key: $key_out"
    if [[ -n "$key_out" ]]; then
        command="$command $key_out"
    fi
fi

# Execute terraform command
silent_cmd echo -e "\n${blue}Initializing terraform...${white}"
silent_cmd terraform init

silent_cmd echo -e "\n${blue}Executing terraform $command...${white}"
execute="terraform $command"
eval "${execute}"

# Export config state
if [[ -n "$state" ]]; then
    silent_cmd echo -e "\n${blue}Exporting terraform state...${white}"
    mkdir -p "$state"
    terraform output > "$state/$outputFile"
    terraform output -json > "$state/${outputFile}.json"
    if cp -f "./$stateFile" "$state/$stateFile"; then
        if cp -f "./$varsFile" "$state/$varsFile"; then
            silent_cmd echo -e "${green}Terraform state successfully exported.${white}"
        else
            echo -e "${red}Error: Imposible to copy $varsFile file."
            echo -e "${white}"
            exit 3
        fi
    else
        echo -e "${red}Error: Imposible to copy $varsFile file."
        echo -e "${white}"
        exit 2
    fi
fi
