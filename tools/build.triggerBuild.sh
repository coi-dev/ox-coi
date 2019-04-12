#!/bin/bash

set -e
set -o pipefail

PROJECT_FOLDER=`pwd`
PLUGIN_FOLDER="flutter-deltachat-core";

BUILD_NAME="oxdev-r999.0-android-b$BUILD_ID"

cd ..
if [[ -d "$PLUGIN_FOLDER" ]]; then
    cd ${PLUGIN_FOLDER}
    git pull
    git submodule update
else
    git clone --recurse-submodules https://github.com/open-xchange/flutter-deltachat-core.git
fi
cd ${PROJECT_FOLDER}
flutter build apk --build-name=${BUILD_NAME} --build-number=${BUILD_ID} --flavor development