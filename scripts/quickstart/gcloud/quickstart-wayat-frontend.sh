#!/bin/bash

set -e
FLAGS=$(getopt -a --options w:d:p:h --long "help,workspace:,directory:,project:,keystore:,backend-url:,frontend-url:,maps-static-secret:,google-services:,storage-bucket:" -- "$@")

eval set -- "$FLAGS"

while true; do
    case "$1" in
        -h | --help )             help="true"; shift 1;;
        -w | --workspace )        workspace=$2; shift 2;;
        -d | --directory )        directory=$2; shift 2;;
        -p | --project )          projectName=$2; shift 2;;
        --keystore )              keystore=$2; shift 2;;
        --backend-url )           backendUrl=$2; shift 2;;
        --frontend-url )          frontendUrl=$2; shift 2;;
        --maps-static-secret )    mapsStaticSecret=$2; shift 2;;
        --) shift; break;;
    esac
done

helpFunction() {
   echo "Inits the Wayat backend project in the specified workspace folder."
   echo ""
   echo "Flags:"
   echo -e "\t-w, --workspace        [Required] Path for the Takeoff Workspace Project directory"
   echo -e "\t-d, --directory        [Required] Path for the directory of the Frontend code"
   echo -e "\t-p, --project          [Required] Project shortname (ID)"
   echo -e "\t--keystore             [Required] Keystore file path"
   echo -e "\t--backend-url          [Required] Backend service url"
   echo -e "\t--frontend-url         [Required] Frontend service url"
   echo -e "\t--maps-static-secret   [Required] Maps static API secret"
}

# Colours for the messages.
white='\e[1;37m'
red='\e[0;31m'


# Mandatory argument check
checkMandatoryArguments() {
    if [ -z "$workspace" ];
    then
        echo -e "${red}Error: Missing paramenters, -w or --workspace is mandatory." >&2
        echo -e "${red}Use -h flag to display help." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
    if [ -z "$directory" ];
    then
        echo -e "${red}Error: Missing paramenters, -d or --directory is mandatory." >&2
        echo -e "${red}Use -h flag to display help." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
    if [ -z "$projectName" ];
    then
        echo -e "${red}Error: Missing paramenters, -p or --project is mandatory." >&2
        echo -e "${red}Use -h flag to display help." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
    if [ -z "$keystore" ];
    then
        echo -e "${red}Error: Missing paramenters, -p or --project is mandatory." >&2
        echo -e "${red}Use -h flag to display help." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
    if [ -z "$backendUrl" ];
    then
        echo -e "${red}Error: Missing paramenters, -p or --project is mandatory." >&2
        echo -e "${red}Use -h flag to display help." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
    if [ -z "$frontendUrl" ];
    then
        echo -e "${red}Error: Missing paramenters, -p or --project is mandatory." >&2
        echo -e "${red}Use -h flag to display help." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
    if [ -z "$mapsStaticSecret" ];
    then
        echo -e "${red}Error: Missing paramenters, -p or --project is mandatory." >&2
        echo -e "${red}Use -h flag to display help." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
    if [ ! -d "$workspace" ];
    then
        echo -e "${red}Error: Workspace directory does not exists." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
    if [ ! -d "$directory" ];
    then
        echo -e "${red}Error: Frontend code directory does not exists." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
    # Dir path
    currentPath=$(pwd)
    cd "$workspace"
    workspace=$(pwd)
    cd "$directory"
    directory=$(pwd)
    cd $currentPath
}

function obtainHangarPath {
    # This line goes to the script directory independent of wherever the user is and then jumps 3 directories back to get the path
    hangarPath=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd ../../.. && pwd )
}

# Required CLI check
ckeckCliInstalled() {
    # Check if GCloud CLI is installed
    if ! [ -x "$(command -v gcloud)" ]; then
        echo -e "${red}Error: GCloud CLI is not installed." >&2
        echo -ne "${white}" >&2
        exit 127
    fi
}

downloadTemplate() {
    wget -O "$workspace"/wayat-frontend-template.zip https://github.com/devonfw/hangar/archive/refs/heads/template/wayat-flutter-frontend.zip
    unzip "$workspace"/wayat-frontend-template.zip -d "$workspace/tmp"
    shopt -s dotglob
    mv -f "$workspace"/tmp/hangar-template-wayat-flutter-frontend/* "$directory"
    rm -rf "$workspace/tmp"
    rm "$workspace"/wayat-frontend-template.zip
}

prepareENVFile() {
    # Remove '-' character
    packageName="com.takeoff.${projectName//-/}"
    # Remove '_' character
    packageName="com.takeoff.${packageName//_/}"
    export backendUrl
    export projectName
    export messageSenderId=$(cat "${workspace}/webconfig.json" | grep messagingSenderId | awk '{print $2}' | sed s/\"//g | sed s/,//g)
    export mapsStaticSecret
    export webClientId=$(cat "${workspace}/google-services.json" | grep client_id | awk 'FNR == 3 {print $2}' | sed s/\"//g | sed s/,//g)
    export webApiKey=$(cat "${workspace}/webconfig.json" | grep apiKey | awk '{print $2}' | sed s/\"//g | sed s/,//g)
    export webAppId=$(cat "${workspace}/webconfig.json" | grep appId | awk '{print $2}' | sed s/\"//g | sed s/,//g)
    export webAuthDomain=$(cat "${workspace}/webconfig.json" | grep authDomain | awk '{print $2}' | sed s/\"//g | sed s/,//g)
    export androidApiKey=$(cat "${workspace}/google-services.json" | grep current_key | awk '{print $2}' | sed s/\"//g | sed s/,//g)
    export androidAppId=$(cat "${workspace}/google-services.json" | grep mobilesdk_app_id | awk '{print $2}' | sed s/\"//g | sed s/,//g)
    export iosApiKey=$(cat "${workspace}/GoogleService-Info.plist" | grep API_KEY -A 2 | awk 'FNR == 2 {print $1}' | cut -d'<' -f2 | cut -d'>' -f2)
    export iosAppId=$(cat "${workspace}/GoogleService-Info.plist" | grep GOOGLE_APP_ID -A 2 | awk 'FNR == 2 {print $1}' | cut -d'<' -f2 | cut -d'>' -f2)
    export iosAndroidClientId=$(cat "${workspace}/GoogleService-Info.plist" | grep ANDROID_CLIENT_ID -A 2 | awk 'FNR == 2 {print $1}' | cut -d'<' -f2 | cut -d'>' -f2)
    export iosClientId=$(cat "${workspace}/GoogleService-Info.plist" | grep CLIENT_ID -A 2 | awk 'FNR == 2 {print $1}' | cut -d'<' -f2 | cut -d'>' -f2)
    export iosBundleId=$packageName
    
    variablesSubstitution='$backendUrl $projectName $messageSenderId $mapsStaticSecret $webClientId $webApiKey $webAppId $webAuthDomain $androidApiKey $androidAppId $iosApiKey $iosAppId $iosAndroidClientId $iosClientId $iosBundleId'
    # shellcheck disable=SC2016
    envsubst "\'$variablesSubstitution\'" < "$directory/env.template" > "$directory/.env"
    rm "$directory/env.template"
    
    export storePassword=android
    export keyPassword=android
    export keyAlias=upload
    export storeFile=/workspace/keystore.jks

    variablesSubstitution='$storePassword $keyPassword $keyAlias $storeFile'
    # shellcheck disable=SC2016
    envsubst "\'$variablesSubstitution\'" < "$directory/android/key.properties.template" > "$directory/android/key.properties"
    rm "$directory/android/key.properties.template"

    cp "${workspace}/google-services.json" "$directory/google-services.json"
}

commitFiles() {
    cd "$directory" && git add -A && git commit -m "Init Wayat Frontend Code" && git push
}

addSecrets() {
    "$hangarPath"/scripts/pipelines/gcloud/add-secret.sh -d "$directory" -f "$directory/.env" -r .env -b develop
    "$hangarPath"/scripts/pipelines/gcloud/add-secret.sh -d "$directory" -f "$directory/android/key.properties" -r android/key.properties -b develop
    "$hangarPath"/scripts/pipelines/gcloud/add-secret.sh -d "$directory" -f "$directory/google-services.json" -r android/app/google-services.json -b develop
    "$hangarPath"/scripts/pipelines/gcloud/add-secret.sh -d "$directory" -f "$keystore" -r keystore.jks -b develop
    "$hangarPath"/scripts/pipelines/gcloud/add-secret.sh -d "$directory" -n ANDROID_API_KEY -v $androidApiKey -b develop
}

setupPackageName() {
    # Remove '-' character
    packageName="com.takeoff.${projectName//-/}"
    # Remove '_' character
    packageName="com.takeoff.${packageName//_/}"
    
    sed -i 's/com.takeof.project/$packageName/g' "$directory/android/app/build.gradle"
    sed -i 's/com.takeof.project/$packageName/g' "$directory/android/app/src/debug/AndroidManifest.xml"
    sed -i 's/com.takeof.project/$packageName/g' "$directory/android/app/src/main/AndroidManifest.xml"
    sed -i 's/com.takeof.project/$packageName/g' "$directory/android/app/src/profile/AndroidManifest.xml"
    sed -i 's/com.takeof.project/$packageName/g' "$directory/ios/Runner.xcodeproj/project.pbxproj"
    sed -i 's/com.takeof.project/$packageName/g' "$directory/lib/features/map/widgets/platform_map_widget/web_desktop_map_widget.dart"
}

corsCloudStorage() {
# shellcheck disable=SC2016
    envsubst '$frontendUrl' < "$hangarPath/scripts/quickstart/gcloud/cors.json" > "$hangarPath/scripts/quickstart/gcloud/cors.json"
    gsutil cors set "$hangarPath/scripts/quickstart/gcloud/cors.json" "gs://${projectName}.appspot.com"
}

nextSteps() {
    echo "Next steps:"
    echo "1- Go to https://console.cloud.google.com/apis/credentials/oauthclient/$webClientId?project=$projectName"
    echo "and in \"JavaScript authoritative sources\" section add frontend url: $frontendUrl"
    echo "2- Go to https://console.firebase.google.com/project/$projectName/appcheck/apps and register SafetyNet in android app"
    echo "3- Go to https://console.firebase.google.com/project/$projectName/authentication/providers, then enable Google Sign In and Phone authentication"
}

#==============================================================
# SCRIPT EXECUTION:

if [[ "$help" == "true" ]]; then helpFunction; exit; fi

checkMandatoryArguments

ckeckCliInstalled

obtainHangarPath

downloadTemplate

prepareENVFile

setupPackageName

commitFiles

addSecrets

nextSteps