#!/usr/bin/env bash

# System flags
set -e

# User / CI input
repository=$1

# Constants
SCRIPT_BASEDIR=$(dirname "$0")
TEMP_CUSTOMER_FOLDER="customerRepository"

ANDROID_APP_FOLDER="android/app"

IOS_APP_FOLDER="ios/OX Coi"
IOS_FIREBASE_FOLDER="${IOS_APP_FOLDER}/Firebase"

# Setup
if [[ "$#" != 1 ]]; then
    echo "Usage of $0:"
    echo
    echo "1. parameter:     A git repository providing required customer files"
    echo
    echo "Example: ./setup.loadCustomer.sh git@gitlab.open-xchange.com:mobile/coi-customer-ox.git"
    exit 0
fi

# Functions
function error {
    echo >&2 $1
    exit $2
}

# Execution
echo "-- Setup --"
cd ${SCRIPT_BASEDIR} || error "Can't navigate into app directory" 1
echo "-- Clean up --"
rm -rf "${TEMP_CUSTOMER_FOLDER}"
echo "-- Getting customer repository --"
git clone $1 ${TEMP_CUSTOMER_FOLDER}
echo "---------------------------"
cat ${TEMP_CUSTOMER_FOLDER}/README.md
echo "---------------------------"
echo "-- Copy Firebase config --"
mkdir -p "../${ANDROID_APP_FOLDER}"
mkdir -p "../${IOS_FIREBASE_FOLDER}"
cp "${TEMP_CUSTOMER_FOLDER}/${ANDROID_APP_FOLDER}/"* "../${ANDROID_APP_FOLDER}/"
cp "${TEMP_CUSTOMER_FOLDER}/${IOS_FIREBASE_FOLDER}/"* "../${IOS_FIREBASE_FOLDER}/"
echo "-- Finishing --"
