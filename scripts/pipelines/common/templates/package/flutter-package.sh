#!/bin/bash
export tag=$(grep -m 1 version pubspec.yaml | tr -s ' ' | tr -d ':' | cut -d' ' -f2 | cut -d'+' -f1)

# Colours for the messages.
red='\e[0;31m'

if [[ ${FLUTTER_PLATFORM} == "android" ]]; then
    flutter pub get
    flutter build apk --release
    gcloud storage cp build/app/outputs/flutter-apk/app-release.apk gs://"${PROJECT_ID}"-apk/app-release-"${SHORT_SHA}".apk
elif [[ ${FLUTTER_PLATFORM} == "web" ]]; then
    flutter pub get
    if [[ ${FLUTTER_WEB_RENDERER} == "" ]]; then
        flutter build web --release --web-renderer auto --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false
        # Check if the web renderer is supported
    elif [ "${FLUTTER_WEB_RENDERER}" == "canvaskit" ] || [ "${FLUTTER_WEB_RENDERER}" == "html" ]; then
        flutter build web --release --web-renderer "${FLUTTER_WEB_RENDERER}" --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false
    else
        echo -e "${red}Error: Web renderer ${FLUTTER_WEB_RENDERER} not supported ." >&2
        exit 1
    fi
fi
