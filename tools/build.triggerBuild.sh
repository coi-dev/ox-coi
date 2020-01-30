#!/usr/bin/env bash

# System flags
set -e

# User / CI input
platforms=$1
mode=$2
flavor=$3
buildName=$4
buildNumber=$5

# Constants
SCRIPT_BASEDIR=$(dirname "$0")
PLUGIN_FOLDER="flutter-deltachat-core";
CORE_BUILD_SCRIPT="./build-dcc.sh"
IOS_BUILD_FOLDER="build/app/outputs/ios/${flavor}"

# Setup
if [[ "$#" != 5 ]]; then
    echo "Usage of $0:"
    echo
    echo "1. parameter:     Platform [android, ios, all]"
    echo "2. parameter:     Build mode [debug, release]"
    echo "3. parameter:     Flavor [development, stable]"
    echo "4. parameter:     Build name (semantic versioning required)"
    echo "5. parameter:     Build number (integer)"
    echo
    echo "Example android:  ./build.triggerBuild.sh android release stable 0.450.1 415"
    echo "Example iOS:      ./build.triggerBuild.sh ios release stable 0.450.1 415"
    exit 0
fi

# Functions
function isAndroid {
    if [[ ${platforms} == "android" || ${platforms} == "all" ]]; then
        true
    else
        false
    fi
}

function isIos {
    if [[ ${platforms} == "ios" || ${platforms} == "all" ]]; then
        true
    else
        false
    fi
}

function isRelease {
    if [[ ${mode} == "release" ]]; then
        true
    else
        false
    fi
}
#flutter build apk --build-name=${BUILD_NAME} --build-number=${CI_PIPELINE_ID} --flavor development --debug
function androidDebugBuild {
    echo "Android debug build for ${flavor} started"
    flutter build apk --build-name=${buildName} --build-number=${buildNumber} --flavor ${flavor} --debug
}

function androidReleaseBuild {
    echo "Android release build for ${flavor} started"
    flutter build apk --build-name=${buildName} --build-number=${buildNumber} --flavor ${flavor} --split-per-abi --no-shrink
}

function iosDebugBuild {
    echo "Build mode has to be release to build ipa for export"
}

function iosReleaseBuild {
    echo "iOS release build for ${flavor} started"
    rm -rf ../ios/Flutter/Flutter.framework
    flutter build ios --release --build-name=${buildName} --build-number=${buildNumber} --flavor ${flavor}
    flutter clean

    xcodebuild -workspace ios/Runner.xcworkspace -scheme ${flavor} -sdk iphoneos -configuration Release-${flavor} archive -archivePath "${IOS_BUILD_FOLDER}/Runner.xcarchive" -allowProvisioningUpdates
    xcodebuild -exportArchive -archivePath "${IOS_BUILD_FOLDER}/Runner.xcarchive" -exportOptionsPlist ios/exportOptions${flavor}.plist -exportPath "${IOS_BUILD_FOLDER}/Runner.ipa" -allowProvisioningUpdates
}

function getCore {
    if [[ -d "$PLUGIN_FOLDER" ]]; then
        cd ${PLUGIN_FOLDER}
        git pull
        git submodule update
    else
        git clone --recurse-submodules https://github.com/open-xchange/flutter-deltachat-core.git
    fi
}

function buildCore {
    if [[ -f "$CORE_BUILD_SCRIPT" ]]; then
        if isAndroid; then
            ${CORE_BUILD_SCRIPT} android | sed 's/^/    /'
        elif isIos; then
            ${CORE_BUILD_SCRIPT} ios | sed 's/^/    /'
        fi
     else
        exit 2
     fi
}

# Execution
echo "-- Setup --"
cd ${SCRIPT_BASEDIR}/.. || error 1
echo "Building / updating core"
(
    cd .. || error 3
    getCore
    buildCore
)
echo "-- Building --"
if isAndroid; then
    if isRelease; then
        androidReleaseBuild
    else
        androidDebugBuild
    fi
elif isIos; then
    if isRelease; then
        iosReleaseBuild
    else
        iosDebugBuild
    fi
fi
echo "-- Finishing --"
