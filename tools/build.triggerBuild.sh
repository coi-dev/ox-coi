#!/usr/bin/env bash

# System flags
set -e

# User / CI input
platforms=$1
mode=$2
flavor=$3
buildName=$4
buildNumber=$5
coreVersion=$6

# Constants
SCRIPT_BASEDIR=$(dirname "$0")
PLUGIN_FOLDER="flutter-deltachat-core";
CORE_BUILD_SCRIPT="./build-dcc.sh"
IOS_BUILD_FOLDER="build/app/outputs/ios/${flavor}"

ANDROID_ARM_32="armeabi-v7a_libnative-utils.so"
ANDROID_ARM_64="arm64-v8a_libnative-utils.so"
ANDROID_X86="x86_libnative-utils.so"
ANDROID_X64="x86_64_libnative-utils.so"
ANDROID_LIBRARY_FOLDER="android/libs"
ANDROID_LIBRARY_FILENAME="libnative-utils.so"

IOS_LIBRARY_FOLDER="ios/Libraries"
IOS_LIBRARY_FILENAME="libdeltachat.a"

# Setup
if [[ "$#" != 6 ]]; then
    echo "Usage of $0:"
    echo
    echo "1. parameter:     Platform [android, ios, all]"
    echo "2. parameter:     Build mode [debug, release]"
    echo "3. parameter:     Flavor [development, stable]"
    echo "4. parameter:     Build name (semantic versioning required)"
    echo "5. parameter:     Build number (integer)"
    echo "6. parameter:     Core version [local, latest, 'Github tag']"
    echo
    echo "Example android:  ./build.triggerBuild.sh android release stable 0.450.1 415 local"
    echo "Example iOS:      ./build.triggerBuild.sh ios release stable 0.450.1 415 local"
    exit 0
fi

# Functions
function error {
    echo >&2 $1
    exit $2
}

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

function isLocalDcc {
    if [[ ${coreVersion} == "local" ]]; then
        true
    else
        false
    fi
}

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

function setupPlugin {
    if [[ -d "$PLUGIN_FOLDER" ]]; then
        if [[ -n ${CI} ]]; then
            (
                cd ${PLUGIN_FOLDER} || error "Can't navigate into plugin directory" 4
                if [[ "latest" == ${coreVersion} ]]; then
                    git checkout develop
                    git pull
                else
                    git checkout ${coreVersion}
                fi
            )
        else
            echo "Plugin repository found, using the current state. To ensure the latest plugin + DCC is used, please execute 'git pull && git submodule update' in the plugin repository"
        fi
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
        error "Core script is missing" 2
     fi
}

function wgetQuiet {
    wget -q --show-progress $1
}

function downloadCore {
    urlLatest="https://github.com/open-xchange/flutter-deltachat-core/releases/latest/download/"
    urlTag="https://github.com/open-xchange/flutter-deltachat-core/releases/download/${coreVersion}/"

    if isAndroid; then
        if [[ ${coreVersion} == "latest" ]]; then
            wgetQuiet "${urlLatest}${ANDROID_ARM_32}";
            wgetQuiet "${urlLatest}${ANDROID_ARM_64}";
            wgetQuiet "${urlLatest}${ANDROID_X86}";
            wgetQuiet "${urlLatest}${ANDROID_X64}";
        else
            wgetQuiet "${urlTag}${ANDROID_ARM_32}";
            wgetQuiet "${urlTag}${ANDROID_ARM_64}";
            wgetQuiet "${urlTag}${ANDROID_X86}";
            wgetQuiet "${urlTag}${ANDROID_X64}";
        fi
    elif isIos; then
        if [[ ${coreVersion} == "latest" ]]; then
            wgetQuiet "${urlLatest}${IOS_LIBRARY_FILENAME}";
        else
            wgetQuiet "${urlTag}${IOS_LIBRARY_FILENAME}";
        fi
    fi
}

function moveSingleCoreFile {
    if isAndroid; then
        folder=$(sed "s/_$ANDROID_LIBRARY_FILENAME//g" <<< $1)
        targetFolder="../${PLUGIN_FOLDER}/${ANDROID_LIBRARY_FOLDER}/${folder}/"
        targetPath="${targetFolder}${ANDROID_LIBRARY_FILENAME}"
        mkdir -p ${targetFolder}
        rm -f ${targetPath}
        echo "Moving $1 to ${targetPath}"
        mv ${1} ${targetPath}
    elif isIos; then
        targetFolder="../${PLUGIN_FOLDER}/${IOS_LIBRARY_FOLDER}/"
        targetPath="${targetFolder}${IOS_LIBRARY_FILENAME}"
        mkdir -p ${targetFolder}
        rm -f ${targetPath}
        echo "Moving $1 to ${targetFolder}"
        mv ${1} ${targetFolder}
    fi
}

function moveCore {
    if isAndroid; then
        moveSingleCoreFile ${ANDROID_ARM_32}
        moveSingleCoreFile ${ANDROID_ARM_64}
        moveSingleCoreFile ${ANDROID_X86}
        moveSingleCoreFile ${ANDROID_X64}
    elif isIos; then
        moveSingleCoreFile ${IOS_LIBRARY_FILENAME}
    fi
}

# Execution
echo "-- Setup --"
cd ${SCRIPT_BASEDIR}/.. || error "Can't navigate into app directory" 1
echo "Get plugin repository"
(
    cd .. || error "Can't navigate into parent directory" 3
    setupPlugin
)
if isLocalDcc; then
    echo "Building / updating core"
    (
        cd ../${PLUGIN_FOLDER} || error "Can't navigate into plugin directory" 4
        buildCore
    )
else
    echo "Downloading core"
    (
        downloadCore
        echo "Moving core"
        moveCore
    )
fi
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
echo "-- Performing additional build steps --"
if isIos; then
    echo "Adjusting symlinks"
    cd "../$PLUGIN_FOLDER/$IOS_LIBRARY_FOLDER"
    ln -sf "../../delta_chat_core/deltachat-ffi/deltachat.h" .
fi
echo "-- Finishing --"
