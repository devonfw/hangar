#! /bin/bash
set -e
FLAGS=$(getopt -a --options u:p:s:t:h --long "user:,password:,sonar-url:,token-name:,help,tf-output-sq-token:" -- "$@")

function helpFunction() {
    echo ""
    echo "Create a token in Sonarqube."
    echo "By default the name of the token is hangarToken and is created in the admin account using the default admin password."
    echo ""
    echo "Common flags:"
    echo "  -s, --sonar-url    [Required] The url of your sonarqube, including protocol and port. Example: http://mysonar.com:9000."
    echo "  -u, --user                    The user that is going to generate the token. By default admin."
    echo "  -p, --password                The password of the user that is going to generate the token. By default admin."
    echo "  -t, --token-name              The name under which the secret is stored. By default hangarToken."
    echo "  -h, --help                    Get help for commands."
}

# If terraform output has the token created, read the token from the output instead of creating it.
# This is needed in terraform because if you try to change or destroy something in the environment, the token cannot be created again and then is going to be lost.
# To use it add the flag --tf-output-sq-token $outputName when invoking the script.
function terraformGetSQToken {
    FILE="terraforma.tfstate"
    if [[ -f "$FILE" ]]; then
        if cp -f $FILE temp.tfstate; then
           sq_token_output=$(terraform output -state=temp.tfstate | grep "$terraformSQToken" | cut -d' ' -f 3)
           rm -f temp.tfstate
        fi
    fi
    if [[ -n "$sq_token_output" ]]; then
        echo "{\"token\":$sq_token_output}"
        exit
    fi
}

eval set -- "$FLAGS"
while true; do
    case "$1" in
        -s | --sonar-url)      sonarUrl=$2; shift 2;;
        -u | --user)           user=$2; shift 2;;
        -p | --password)       password=$2; shift 2;;
        -t | --token-name)     tokenName=$2; shift 2;;
        -h | --help)           helpFunction; exit ;;
        --tf-output-sq-token)  terraformSQToken=$2; terraformGetSQToken; shift 2;;
        --) shift; break;;
    esac
done

white='\e[1;37m'
green='\e[1;32m'

# Check url provided
if [[ -z "$sonarUrl" ]]; then
    echo -e "${red}Error: Missing paramenters, -s or --sonar-url is mandatory." >&2
    echo -e "${red}Use -h or --help flag to display help." >&2
    echo -e "${white}"
    exit 2
fi

# Set default values
if [[ -z "$user" ]]; then
    user="admin"
fi
if [[ -z "$password" ]]; then
    password="admin"
fi
if [[ -z "$tokenName" ]]; then
    tokenName="hangarToken"
fi

# Check sonar status
sonar_ready=false
attempt=0
while ! $sonar_ready && [[ $attempt -lt 30 ]]; do
    health=$(curl -sS --retry 30 --max-time 10 --retry-connrefused -u "$user":"$password" "$sonarUrl"/api/system/health)
    health_green="\"health\":\"GREEN\""
    if [[ "$health" == *"$health_green"* ]]; then
        sonar_ready=true
    else
        ((attempt+=1))
        sleep 10
    fi
done

# Generate token if sonarqube is ready
if $sonar_ready; then
    setToken=$(curl -sS -H "Content-Type: application/x-www-form-urlencoded" -d "name=$tokenName" -u "$user":"$password" "$sonarUrl"/api/user_tokens/generate)
    tokenJson=$(echo "$setToken" | cut -d ',' -f3)
    if [[ "$tokenJson" == "\"token\":\""* ]]; then
        echo "{$tokenJson}"
    elif [[ "$setToken" == *"already exists"* ]]; then
        echo "{\"token\":\"Generated before and the value cannot be readed. Use create_token.sh script or go to sonarqube and generate a new one manually if you need it.\"}"
    else
        echo -e "${red}ERROR: Token cannot be created."
        echo -e "${red}  Sonarqube response: $setToken."
        echo -e "${white}"
        exit 3
    fi
else
    echo -e "${red}ERROR: Token cannot be created."
    echo -e "${red}  Sonarqube is not ready, the health check status is: $health."
    echo -e "${white}"
    exit 4
fi
