#!/bin/bash

set -e
set -o pipefail

projectFolder=`pwd`

cd ..
git clone --recurse-submodules https://github.com/open-xchange/flutter-deltachat-core.git
cd ${projectFolder}
flutter build apk