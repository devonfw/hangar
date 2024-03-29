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
    echo "Deploy, delete or get info about Terraform managed infrastructure."
    echo "The script must be called from the folder where the main terraform files are located."
    echo "This is a helper to make Terraform easier to use for non-experienced users, or for those who need only one command to be executed (i.e. avoiding the need of terraform init)."
    echo ""
    echo "Usage:"
    echo ""
    echo "terraform.sh <command> [flags...] [terraform variables...]"
    echo ""
    echo "Commands:"
    echo ""
    echo "  COMMAND       DESCRIPTION"
    echo "  apply         Creates or updates infrastructure."
    echo "  destroy       Destroys previously created infrastructure."
    echo "  output        Shows output values from Terraform state. Ignores flags other than '--output-key' or '-k'."
    echo "                To print only one output value use flag '--output-key <key>' where key is the name of the output variable."
    echo ""
    echo "Flags:"
    echo ""
    echo "  -s, --state-folder    Folder for saving/importing Terraform configuration."
    echo "  -k, --output-key      [ONLY FOR output] Key of a single Terraform output variable to print."
    echo "  -q, --quiet           Suppress output other than the generated by Terraform command."
    echo "  -h, --help            Displays help message."
    echo ""
    echo "Terraform variables:"
    echo ""
    echo "These variables will be used to update 'terraform.tfvars' (using set-terraform-variables.sh script). They are ignored in output command."
    echo "Syntax: '--key value' or '--key=value'"
    echo ""
}

vars=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        'apply' | 'destroy')             command="$1 --auto-approve"; shift ;;
        'output')                        command="$1"; silent="true"; shift ;;
        '-s' | '--state-folder')         state="$2"; shift 2 ;;
        '-k' | '--output-key')           key_out="$2"; shift 2 ;;
        '-q' | '--quiet' )               silent="true"; shift ;;
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
    if [[ "$silent" == "true" ]]; then
        "$@" > /dev/null
    else
        "$@"
    fi
}

# Check command provided
if [[ -z "$command" ]]; then
    echo -e "${red}Error: Missing mandatory command." >&2
    echo -e "${red}Use -h or --help flag to display help." >&2
    echo -ne "${white}" >&2
    exit 2
fi

# Import config state
if [[ -n "$state" ]]; then
    silent_cmd echo -e "\n${blue}Importing previous state...${white}" 
    if cp -f "$state/$stateFile" "./$stateFile"; then
        silent_cmd echo "Previous state successfully imported."
    else
        silent_cmd echo "No previous state found."
    fi
    if cp -f "$state/$varsFile" "./$varsFile"; then
        silent_cmd echo "Previous vars successfully imported."
    else
        silent_cmd echo "No previous vars file found."
    fi
    if cp -f "$state/$outputFile" "./$outputFile"; then
        silent_cmd echo "Previous output successfully imported."
    else
        silent_cmd echo "No previous output file found."
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
            echo -e "${red}Error: Could not copy $varsFile file." >&2
            echo -ne "${white}" >&2
            exit 3
        fi
    else
        echo -e "${red}Error: Could not copy $varsFile file." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
fi
