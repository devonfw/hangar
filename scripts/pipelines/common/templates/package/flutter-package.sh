#!/bin/bash

# Colours for the messages.
white='\e[1;37m'
green='\e[1;32m'

export tag=$(grep -m 1 version pubspec.yaml | tr -s ' ' | tr -d ':' | cut -d' ' -f2 | cut -d'+' -f1)

if [[ ${FLUTTER_PLATFORM} == "android" ]]; then
    # We check if the bucket we needed exists, we create it if not
    if (gcloud storage ls --project="${PROJECT_ID}" | grep "${PROJECT_ID}-apk" >> /dev/null)
    then
        echo -e "${green}Bucket ${PROJECT_ID}-apk already exists.${white}"
    else
        echo -e "${green}The bucket ${PROJECT_ID}-apk does not exist, creating it...${white}"
        gcloud storage buckets create gs://"${PROJECT_ID}"-apk --project="${PROJECT_ID}"
    fi
    gcloud storage cp build/app/outputs/flutter-apk/app-release.apk gs://"${PROJECT_ID}"-apk/app-release-"$SHORT_SHA".apk
fi
