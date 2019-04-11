#!/bin/bash

set -e
set -o pipefail

PROJECT_FOLDER=`pwd`
PLUGIN_FOLDER="flutter-deltachat-core";

cd ..
if [[ -d "PLUGIN_FOLDER" ]]; then
    cd PLUGIN_FOLDER
    git pull
else
    git clone --recurse-submodules https://github.com/open-xchange/flutter-deltachat-core.git
fi
cd ${PROJECT_FOLDER}
flutter build apk