#!/bin/bash

set -e
set -o pipefail

BUILDFOLDER=$PWD/build/app/outputs/ios/development/debug

flutter build ios --build-name=0.1.0 --build-number=501
flutter clean

xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -sdk iphoneos -configuration Release archive -archivePath $BUILDFOLDER/Runner.xcarchive >/dev/null
xcodebuild -exportArchive -archivePath $BUILDFOLDER/Runner.xcarchive -exportOptionsPlist ios/exportOptions.plist -exportPath $BUILDFOLDER/Runner.ipa