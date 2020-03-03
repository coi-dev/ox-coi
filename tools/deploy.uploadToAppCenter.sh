#!/bin/bash

set -e
set -o pipefail

RELEASE_NOTES=`cat tools/deploy.releaseNotesHockeyDev.md`
DISTRIBUTION_GROUP="Collaborators"
APK="build/app/outputs/apk/development/debug/app-development-debug.apk"
APPCENTER_APP="OX COI Messenger Dev"

appcenter "distribute release --app \"${APPCENTER_APP}\" --file ${APK} --group \"${DISTRIBUTION_GROUP}\" --output json --release-notes \"${RELEASE_NOTES}\""