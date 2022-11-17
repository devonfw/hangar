#!/bin/bash

set -e
FLAGS=$(getopt -a --options n:r:o:h --long "enable-maps:,create-ios:,create-android:,create-web:" -- "$@")

eval set -- "$FLAGS"

while true; do
    case "$1" in
        -n )                      projectName=$2; shift 2;;
        -r )                      firestoreRegion=$2; shift 2;;
        -h | --help )             help="true"; shift 1;;
        --enable-maps )           enableMaps="true"; shift 1;;
        --create-ios )            createIOS="true"; shift 1;;
        --create-android )        createAndroid="true"; shift 1;;
        --create-web )            createWeb="true"; shift 1;;
        --) shift; break;;
    esac
done

helpFunction()
{
   echo "Enables Firebase on a project and required APIs"
   echo ""
   echo "Arguments:"
   echo -e "\t-n [Required] Name of the project."
   echo -e "\t-r            Region to create Firestore Database"
   echo -e "\t-o            Output Path to store credentials"
   echo -e "\t--enable-maps Enables APIs related to Maps Services"
   echo -e "\t--create-ios  Creates IOS App"
   echo -e "\t--create-android  Creates Android App"
   echo -e "\t--create-web  Creates Web App"
}

if [[ "$help" == "true" ]]; then helpFunction; fi

white='\e[1;37m'
red='\e[0;31m'

# Mandatory argument check
if [ -z "$projectName" ];
then
   echo -e "${red}Error: Missing paramenters, -n is mandatory." >&2
   echo -e "${red}Use -h flag to display help." >&2
   echo -ne "${white}"
   exit 2
fi

# Check if GCloud CLI is installed
if ! [ -x "$(command -v gcloud)" ]; then
  echo -e "${red}Error: GCloud CLI is not installed." >&2
  echo -ne "${white}"
  exit 127
fi

# Check if Firebase CLI is installed
if ! [ -x "$(command -v firebase)" ]; then
  echo -e "${red}Error: Firebase CLI is not installed." >&2
  echo -ne "${white}"
  exit 128
fi

# Check if exists a Google Cloud project with that project ID. 
if ! gcloud projects describe "$projectName" &>/dev/null ; then
    echo -e "${red}Error: Project $projectName does not exist."
    echo -ne "${white}"
    exit 200
fi

echo "Enabling Firebase..."
if ! gcloud services enable firebase.googleapis.com --project "$projectName"; then
    echo -e "${red}Error: Cannot enable Firebase API"
    echo -ne "${white}"
    exit 220
fi

echo "Enabling Firestore..."
if ! gcloud services enable firestore.googleapis.com --project "$projectName"; then
    echo -e "${red}Error: Cannot enable Firestore API"
    echo -ne "${white}"
    exit 221
fi

enableMapsAPIs()
{
    echo "Enabling Maps APIs:"
    echo "Enabling Geocoding Backend..."
    if ! gcloud services enable geocoding-backend.googleapis.com --project "$projectName"; then
        echo -e "${red}Error: Cannot enable Geocoding Backend API"
        echo -ne "${white}"
        exit 224
    fi

    if [[ "$createAndroid" == "true" ]]
    then
        echo "Enabling Maps Android Backend..."
        if ! gcloud services enable maps-android-backend.googleapis.com --project "$projectName"; then
            echo -e "${red}Error: Cannot enable Maps Android Backend API"
            echo -ne "${white}"
            exit 222
        fi
    fi

    if [[ "$createIOS" == "true" ]]
    then
        echo "Enabling Maps IOS Backend..."
        if ! gcloud services enable maps-ios-backend.googleapis.com --project "$projectName"; then
            echo -e "${red}Error: Cannot enable Maps IOS Backend API"
            echo -ne "${white}"
            exit 223
        fi
    fi

    if [[ "$createWeb" == "true" ]]
    then
        echo "Enabling Static Maps Backend..."
        if ! gcloud services enable static-maps-backend.googleapis.com --project "$projectName"; then
            echo -e "${red}Error: Cannot enable Static Maps Backend API"
            echo -ne "${white}"
            exit 225
        fi
    fi
}

[[ "$enableMaps" == "true" ]] && enableMapsAPIs

echo "Adding Firebase to Project..."
# TODO: Check this
if ! firebase projects:list | grep "$projectName" &>/dev/null; then
    if ! firebase projects:addfirebase "$projectName"; then
        echo -e "${red}Error: Cannot add Firebase to project."
        echo -ne "${white}"
        exit 201
    fi
else
    echo -e "Firebase already added to $projectName"
fi

echo "Creating Firestore Database..."
if [ -n "$firestoreRegion" ]; then
    firestoreRegion="europe-west6"
fi

if ! gcloud app create --region=\"$firestoreRegion\"; then
    echo -e "App Engine already created"
fi

if ! gcloud firestore databases create --project $projectName --region=\"$firestoreRegion\"; then
    echo -e "${red}Error: Cannot Create Firestore Database"
    echo -ne "${white}"
    exit 230
fi

echo "Creating Firebase SDK Service Account..."
service_email=$(gcloud iam service-accounts list | grep firebase-adminsdk | tr -s ' ' | cut -d ' ' -f2)
if ! gcloud iam service-accounts keys create /scripts/workspace/firebase.json --iam-account "$service_email" --project "$projectName"; then
    echo -e "${red}Error: Cannot create Firebase Service Account"
    echo -ne "${white}"
    exit 240
fi

createApps()
{
    base_create_app_command="firebase apps:create --project $projectName"
    base_sdkconfig_command="firebase apps:sdkconfig --project $projectName"
    
    if [[ "$createAndroid" == "true" ]]
    then
        echo "Creating ANDROID App..."
        command=$base_create_app_command" --package-name com.takeoff.\"$projectName\" ANDROID \"$projectName\"_android"
        if ! eval "$command"; then
            echo -e "${red}Error while creating Android APP." >&2
            echo -ne "${white}"
            exit 250
        fi
        command=$base_sdkconfig_command" --out /scripts/workspace/google-services.json ANDROID"
        if ! eval "$command"; then
            echo -e "${red}Error while exporting SDK Android Config." >&2
            echo -ne "${white}"
            exit 251
        fi
    fi

    if [[ "$createIOS" == "true" ]]
    then
        echo "Creating IOS App..."
        command=$base_create_app_command" --bundle-id com.takeoff.\"$projectName\" --app-store-id \"\" IOS \"$projectName\"_ios"
        if ! eval "$command"; then
            echo -e "${red}Error while creating IOS APP." >&2
            echo -ne "${white}"
            exit 252
        fi
        command=$base_sdkconfig_command" --out /scripts/workspace/GoogleService-Info.plist IOS"
        if ! eval "$command"; then
            echo -e "${red}Error while exporting SDK IOS Config." >&2
            echo -ne "${white}"
            exit 253
        fi
    fi

    if [[ "$createWeb" == "true" ]]
    then
        echo "Creating WEB App..."
        command=$base_create_app_command" WEB \"$projectName\"_web"
        if ! eval "$command"; then
            echo -e "${red}Error while creating WEB APP." >&2
            echo -ne "${white}"
            exit 254
        fi
        command=$base_sdkconfig_command" --out /scripts/workspace/webconfig.json WEB"
        if ! eval "$command"; then
            echo -e "${red}Error while exporting SDK WEB Config." >&2
            echo -ne "${white}"
            exit 255
        fi
    fi
}

if [[ "$createWeb" == "true" || "$createIOS" == "true" || "$createAndroid" == "true"]]
then
    echo "Creating APPs"
    createApps
fi
