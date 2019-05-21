#!/bin/bash

set -e
set -o pipefail

PLUGIN_FOLDER="flutter-deltachat-core";
BUILD_NAME="oxdev-r999.0"

(
    cd ..
    if [[ -d "$PLUGIN_FOLDER" ]]; then
        cd ${PLUGIN_FOLDER}
        git pull
        git submodule update
    else
        git clone --recurse-submodules https://github.com/open-xchange/flutter-deltachat-core.git
    fi
)
flutter build apk --build-name=${BUILD_NAME} --build-number=${CI_PIPELINE_ID} --flavor development