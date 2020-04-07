#!/bin/bash

set -e
set -o pipefail

PLATFORM=$1
DISTRIBUTION_GROUP="Collaborators"

if [[ ${PLATFORM} == "ios" ]]; then
    FILE="build/app/outputs/ios/development/Runner.ipa/OX COI Messenger Dev.ipa"
    APP_CENTER_APP="open-xchange/OX-COI-Messenger-Dev-1"
else
    FILE="build/app/outputs/apk/development/debug/app-development-debug.apk"
    APP_CENTER_APP="open-xchange/OX-COI-Messenger-Dev"
fi

appcenter distribute release --app "${APP_CENTER_APP}" --file "${FILE}" --group ${DISTRIBUTION_GROUP} --output json