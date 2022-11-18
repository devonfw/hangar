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
    echo "  output        Show output values from your terraform"
    echo ""
    echo "Common flags:"
    echo ""
    echo "  -s, --state-folder    The folder where you are going to save/import your terraform configuration."
    echo "  -k, --output-key      [ONLY FOR output] The key of the terraform output variable that you want to recover."
    echo "  -h, --help            Get help for commands."
}

vars=""
for arg in "${@}"; do
    case "$arg" in
        'apply' | 'destroy')             command="$arg --auto-approve"; shift;;
        'output')                        command="$arg"; shift;;
        '-s' | '--state-folder')         state="$2"; shift 2;;
        '-k' | '--output-key')           key="$2"; shift 2;;
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

# Check command provided
if [[ -z "$command" ]]; then
    echo -e "${red}Error: Missing command, need one of the main commands is mandatory." >&2
    echo -e "${red}Use -h or --help flag to display help." >&2
    echo -e "${white}"
    exit 2
fi

# Import config state
if [[ -n "$state" ]]; then
    echo -e "\n${blue}Importing previous state...${white}"
    if cp -f "$state/$stateFile" "./$stateFile"; then
        echo "Previous state successfully imported."
    else
        echo "Not previous state found."
    fi
    if cp -f "$state/$varsFile" "./$varsFile"; then
        echo "Previous vars successfully imported."
    else
        echo "Not previous vars file found."
    fi
    if cp -f "$state/$outputFile" "./$outputFile"; then
        echo "Previous output successfully imported."
    else
        echo "Not previous output file found."
    fi
fi

# Modify terraform vars
if [[ -n "$vars" && "$command" != "output" ]]; then
    echo -e "\n${blue}Modifying terraform variables...${white}"
    execute="./set-terraform-variables.sh ${vars}"
    eval "${execute}"
fi

# if command is output, clean state var to not export nothing and if key if exist add it to the command.
if [[ "$command" == "output" ]]; then
    if [[ -n "$key" ]]; then
        command="$command $key"
    fi
fi

# Execute terraform command
echo -e "\n${blue}Initializing terraform...${white}"
terraform init

echo -e "\n${blue}Executing terraform $command...${white}"
execute="terraform $command"
eval "${execute}"

# Export config state
if [[ -n "$state" ]]; then
    echo -e "\n${blue}Exporting terraform state...${white}"
    mkdir -p "$state"
    terraform output > "$state/$outputFile"
    if cp -f "./$stateFile" "$state/$stateFile"; then
        if cp -f "./$varsFile" "$state/$varsFile"; then
            echo -e "${green}Terraform state successfully exported.${white}"
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
