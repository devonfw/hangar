#!/bin/bash

set -e
FLAGS=$(getopt -a --options n:r:o:h --long "help,output:,enable-maps,setup-ios,setup-android,setup-web" -- "$@")

eval set -- "$FLAGS"

while true; do
    case "$1" in
        -h | --help )             help="true"; shift 1;;
        -n )                      projectName=$2; shift 2;;
        -o | --output )           outputPath=$2; shift 2;;
        -r )                      firestoreRegion=$2; shift 2;;
        --enable-maps )           enableMaps="true"; shift 1;;
        --setup-ios )             setupIOS="true"; shift 1;;
        --setup-android )         setupAndroid="true"; shift 1;;
        --setup-web )             setupWeb="true"; shift 1;;
        --) shift; break;;
    esac
done

helpFunction() {
   echo "Enables Firebase and required APIs on a Google Cloud project."
   echo ""
   echo "Arguments:"
   echo -e "\t-n                   [Required] Name of the project."
   echo -e "\t-o, --output         [Required] Output path to store credentials."
   echo -e "\t-r                              Region where to create Firestore Database."
   echo -e "\t--enable-maps                   Enables APIs related to Maps services."
   echo -e "\t--setup-ios                     Enables IOS APIs and creates IOS App."
   echo -e "\t--setup-android                 Enables Android APIs and creates Android App."
   echo -e "\t--setup-web                     Enables Web APIs and creates Web App."
}

# Colours for the messages.
white='\e[1;37m'
red='\e[0;31m'

# Mandatory argument check
checkMandatoryArguments() {
    # Project name check
    if [ -z "$projectName" ];
    then
        echo -e "${red}Error: Missing paramenters, -n is mandatory." >&2
        echo -e "${red}Use -h flag to display help." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
    # Output path check
    if [ -z "$outputPath" ];
    then
        echo -e "${red}Error: Missing paramenters, -o is mandatory." >&2
        echo -e "${red}Use -h flag to display help." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
    if ! test -d "$outputPath"; then
        echo -e "${red}Error: Wrong output path." >&2
        echo -ne "${white}"
        exit 2
    fi
    currentPath="$(pwd)"
    cd "${outputPath}" && outputPath="$(pwd)"
    cd "${currentPath}"
    
}

# Required CLI check
ckeckCliInstalled() {
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
        exit 127
    fi
}

checkGcloudProjectName() {
    # Check if exists a Google Cloud project with that project ID. 
    if ! gcloud projects describe "$projectName" 2> /dev/null ; then
        echo -e "${red}Error: Project $projectName does not exist."
        echo -ne "${white}"
        exit 200
    fi
}

enableFirebaseServices() {
    echo "Enabling Firebase API..."
    if ! gcloud services enable firebase.googleapis.com --project "$projectName"; then
        echo -e "${red}Error: Cannot enable Firebase API"
        echo -ne "${white}"
        exit 220
    fi
    echo "Enabling Firestore API..."
    if ! gcloud services enable firestore.googleapis.com --project "$projectName"; then
        echo -e "${red}Error: Cannot enable Firestore API"
        echo -ne "${white}"
        exit 221
    fi
}

enableMapsAPIs() {
    # Geocoding API service (coordinates to location)
    echo "Enabling Maps APIs:"
    if ! gcloud services enable apikeys.googleapis.com --project "$projectName"; then
        echo -e "${red}Error: Cannot enable API keys"
        echo -ne "${white}"
        exit 216
    fi
    echo "Enabling Geocoding Backend..."
    if ! gcloud services enable geocoding-backend.googleapis.com --project "$projectName"; then
        echo -e "${red}Error: Cannot enable Geocoding Backend API"
        echo -ne "${white}"
        exit 224
    fi
    # Android MAPS API service
    if [[ "$setupAndroid" == "true" ]]
    then
        echo "Enabling Maps Android Backend..."
        if ! gcloud services enable maps-android-backend.googleapis.com --project "$projectName"; then
            echo -e "${red}Error: Cannot enable Maps Android Backend API"
            echo -ne "${white}"
            exit 222
        fi
    fi
    # IOS MAPS API service
    if [[ "$setupIOS" == "true" ]]
    then
        echo "Enabling Maps IOS Backend..."
        if ! gcloud services enable maps-ios-backend.googleapis.com --project "$projectName"; then
            echo -e "${red}Error: Cannot enable Maps IOS Backend API"
            echo -ne "${white}"
            exit 223
        fi
    fi
    # WEB MAPS API service
    if [[ "$setupWeb" == "true" ]]
    then
        echo "Enabling Maps WEB..."
        if ! gcloud services enable --project "$projectName" maps-backend.googleapis.com ; then
            echo -e "${red}Error: Cannot enable Maps Backend API"
            echo -ne "${white}"
            exit 216
        fi
    fi
    # Static MAPS API service (coordinates to screenshot)
    echo "Enabling Static Maps Backend..."
    if ! gcloud services enable static-maps-backend.googleapis.com --project "$projectName"; then
        echo -e "${red}Error: Cannot enable Static Maps Backend API"
        echo -ne "${white}"
        exit 225
    fi
}

addFirebaseToGcloudProject() {
    echo "Adding Firebase to Project..."
    if [[ $( firebase projects:list | grep "$projectName" ) == "" ]] ; then
        if ! firebase projects:addfirebase "$projectName"; then
            echo -e "${red}Error: Cannot add Firebase to project."
            echo -ne "${white}"
            exit 201
        fi
    else
        echo -e "Firebase already added to $projectName."
    fi
}

createFirestoreDB() {
    echo "Creating Firestore Database..."
    if [[ "$firestoreRegion" == "" ]]; then
        firestoreRegion="europe-west6"
    fi
    if ! gcloud app create --region=$firestoreRegion &> /dev/null ; then
        echo -e "App Engine already created"
    fi
    if ! gcloud firestore databases create --project $projectName --region=$firestoreRegion; then
        echo -e "${red}Error: Cannot Create Firestore Database"
        echo -ne "${white}"
        exit 230
    fi
}

createFirebaseSDKAccount() {
    echo "Creating Firebase SDK Service Account..."
    service_email=$(gcloud iam service-accounts list | grep firebase-adminsdk | tr -s ' ' | cut -d ' ' -f2)
    if ! gcloud iam service-accounts keys create $outputPath"/firebase.json" --iam-account "$service_email" --project "$projectName"; then
        echo -e "${red}Error: Cannot create Firebase Service Account"
        echo -ne "${white}"
        exit 240
    fi
}

setupAndroidKeystore() {
    # keystore password
    # repeat password
    # first and last name
    # organizational unit
    # organization
    # city or locality
    # state or province
    # country code
    # country code confirmation
    echo -e "android\nandroid\n\n\n\n\n\n\nyes\n" | keytool -genkey -v -keystore $outputPath"/keystore.jks" -keyalg RSA -keysize 2048 -validity 10000 -alias upload -keypass android &> /dev/null
    echo -e "android\n" | keytool -list -v -alias upload -keystore $outputPath"/keystore.jks" 2> /dev/null | grep SHA1 -m 1 > $outputPath"/shaKeys.txt"
    echo -e "android\n" | keytool -list -v -alias upload -keystore $outputPath"/keystore.jks" 2> /dev/null | grep SHA256 -m 1 >> $outputPath"/shaKeys.txt"
}

registerShaKeys() {
    appId="${projectName}_android"
    sha1Key=$(echo -e "android\n" | keytool -list -v -alias upload -keystore $outputPath"/keystore.jks" 2> /dev/null | grep SHA1 -m 1 | cut -d' ' -f3)
    sha256Key=$(echo -e "android\n" | keytool -list -v -alias upload -keystore $outputPath"/keystore.jks" 2> /dev/null | grep SHA256 -m 1 | cut -d' ' -f3)
    if ! firebase apps:android:sha:create $appId $sha1Key --project ${projectName} ; then
        echo -e "${red}Error: Cannot add SHA1 key."
        echo -ne "${white}"
        exit 303
    fi
    if ! firebase apps:android:sha:create $appId $sha256Key --project ${projectName} ; then
        echo -e "${red}Error: Cannot add SHA256 key."
        echo -ne "${white}"
        exit 304
    fi
}

createPlatformApps() {
    base_create_app_command="firebase apps:create --project ${projectName}"
    base_sdkconfig_command="firebase apps:sdkconfig --project ${projectName}"
    # Remove '-' character
    packageName="com.takeoff.${projectName//-/}"
    # Remove '_' character
    packageName="com.takeoff.${packageName//_/}"
    # ANDROID setup:
    if [[ "$setupAndroid" == "true" ]]
    then
        echo "Creating ANDROID App..."
        command=$base_create_app_command" --package-name ${packageName} ANDROID ${projectName}_android"
        if ! eval "$command"; then
            echo -e "${red}Error while creating Android APP." >&2
            echo -ne "${white}"
            exit 250
        fi
        setupAndroidKeystore
        if ! gcloud services enable apikeys.googleapis.com --project "${projectName}" ; then
            echo -e "${red}Error while enabling API keys API." >&2
            echo -ne "${white}"
            exit 250
        fi
        registerShaKeys
        command=$base_sdkconfig_command" --out ${outputPath}/google-services.json ANDROID"
        if ! eval "$command"; then
            echo -e "${red}Error while exporting SDK Android Config." >&2
            echo -ne "${white}" >&2
            exit 251
        fi
    fi
    # IOS setup:
    if [[ "$setupIOS" == "true" ]]
    then
        echo "Creating IOS App..."
        command=$base_create_app_command" --bundle-id ${packageName} --app-store-id \"\" IOS ${projectName}_ios"
        if ! eval "$command"; then
            echo -e "${red}Error while creating IOS APP." >&2
            echo -ne "${white}" >&2
            exit 252
        fi
        command=$base_sdkconfig_command" --out ${outputPath}/GoogleService-Info.plist IOS"
        if ! eval "$command"; then
            echo -e "${red}Error while exporting SDK IOS Config." >&2
            echo -ne "${white}" >&2
            exit 253
        fi
    fi
    # WEB setup:
    if [[ "$setupWeb" == "true" ]]
    then
        echo "Creating WEB App..."
        command=$base_create_app_command" WEB ${projectName}_web"
        if ! eval "$command"; then
            echo -e "${red}Error while creating WEB APP." >&2
            echo -ne "${white}" >&2
            exit 254
        fi
        command=$base_sdkconfig_command" --out ${outputPath}/webconfig.json WEB"
        if ! eval "$command"; then
            echo -e "${red}Error while exporting SDK WEB Config." >&2
            echo -ne "${white}" >&2
            exit 255
        fi
    fi
}

#==============================================================
# SCRIPT EXECUTION:

if [[ "$help" == "true" ]]; then helpFunction; exit; fi

checkMandatoryArguments

ckeckCliInstalled

checkGcloudProjectName

enableFirebaseServices

[[ "$enableMaps" == "true" ]] && enableMapsAPIs

addFirebaseToGcloudProject

createFirestoreDB

createFirebaseSDKAccount

if [[ "$setupWeb" == "true" ]] || [[ "$setupIOS" == "true" ]] || [[ "$setupAndroid" == "true" ]]
then
    echo "Creating APPs"
    createPlatformApps
fi