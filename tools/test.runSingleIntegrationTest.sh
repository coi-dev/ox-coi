#!/bin/bash

# User / CI input
target=$1
deviceId=$2
appId=$3
test="test_driver/$4"
provider=$5

# Constants
TARGET_ANDROID="android"
TARGET_IOS="ios"

# Functions
function error {
    echo >&2 $1
    exit $2
}
function isInstalled {
    command -v $1 >/dev/null 2>&1 || error "'$1' is not installed." 2
}

function setupAll {
   export FLUTTER_TEST_PROVIDER_TO_USE=${provider}
}

function setupIos {
    applesimutils --byId ${deviceId} --bundle ${appId} --setPermissions "camera=YES, contacts=YES, calendar=YES, photos=YES, speech=YES, microphone=YES, medialibrary=YES, notifications=YES, faceid=YES, homekit=YES, location=always, reminders=unset, motion=YES"
}

# Setup
if [[ "$#" = 0 ]]; then
    echo "Usage of $0:"
    echo
    echo "1. parameter:     Target [android, ios]"
    echo "2. parameter:     Emulator / device id [One of the devices listed when executing 'flutter devices'. Use one of the entries from the second column.]"
    echo "3. parameter:     App id / bundle identifier"
    echo "4. parameter:     Test which should get executed [All files in the test_driver folder are usable]"
    echo
    echo "Example android:  ./test.runIntegrationTests.sh android emulator-8888 com.openxchange.oxcoi.dev security_settings_test.dart"
    echo "Example iOS:      ./test.runIntegrationTests.sh ios abc-simulator-12345 com.openxchange.oxcoi.dev security_settings_test.dart"
    exit 0
fi

if [[ -z ${target} ]]; then
    error "No target specified. Available targets are: android, ios" 1
fi

if [[ -z ${deviceId} ]]; then
    error "No emulator / device specified. Available targets can be listed via 'flutter devices'." 1
fi

if [[ -z ${appId} ]]; then
    error "No app id / bundle identifier specified." 1
fi

isInstalled flutter

if [[ ${target} = ${TARGET_ANDROID} ]]; then
    isInstalled adb
elif [[ ${target} = ${TARGET_IOS} ]]; then
    isInstalled applesimutils
    if [[ -z ${appId} ]]; then
        error "No bundle id specified. Use e.g. com.openxchange.oxcoi.dev" 3
    fi
fi

setupAll

cd ..

# Execution
if [[ ${target} = ${TARGET_ANDROID} ]]; then
    FLUTTER_TEST_TARGET_PLATFORM=${target} FLUTTER_TEST_DEVICE_ID=${deviceId} FLUTTER_TEST_APP_ID=${appId} flutter drive -d ${deviceId} --target=test_driver/setup/app.dart --driver=${test} --flavor development
elif [[ ${target} = ${TARGET_IOS} ]]; then
    xcrun simctl uninstall ${deviceId} ${appId}
    sleep 5
    setupIos
    FLUTTER_TEST_TARGET_PLATFORM=${target} flutter drive -d ${deviceId} --target=test_driver/setup/app.dart --driver=${test} --flavor development
fi
