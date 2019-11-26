#!/bin/bash

set -e
set -o pipefail

FLAVOR="stable"

BUILDFOLDER=$PWD/build/app/outputs/ios/development/$FLAVOR

rm -f ios/Flutter/Flutter.framework
flutter build ios --build-name=0.1.0 --build-number=502 --flavor $FLAVOR
flutter clean

xcodebuild -workspace ios/Runner.xcworkspace -scheme $FLAVOR -sdk iphoneos -configuration Release-$FLAVOR archive -archivePath $BUILDFOLDER/Runner.xcarchive -allowProvisioningUpdates
xcodebuild -exportArchive -archivePath $BUILDFOLDER/Runner.xcarchive -exportOptionsPlist ios/exportOptions.plist -exportPath $BUILDFOLDER/Runner.ipa -allowProvisioningUpdates