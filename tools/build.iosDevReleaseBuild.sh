#!/bin/bash

set -e
set -o pipefail

BUILDFOLDER=$PWD/build/app/outputs/ios/development/debug

flutter build ios --build-name=0.1.0 --build-number=502 --flavor development
flutter clean

xcodebuild -workspace ios/Runner.xcworkspace -scheme development -sdk iphoneos -configuration Release-development archive -archivePath $BUILDFOLDER/Runner.xcarchive -allowProvisioningUpdates
xcodebuild -exportArchive -archivePath $BUILDFOLDER/Runner.xcarchive -exportOptionsPlist ios/exportOptions.plist -exportPath $BUILDFOLDER/Runner.ipa -allowProvisioningUpdates