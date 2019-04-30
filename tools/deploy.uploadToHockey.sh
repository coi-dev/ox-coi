#!/bin/bash

set -e
set -o pipefail

RELEASE_NOTES=`cat tools/deploy.releaseNotesHockeyDev.md`

curl \
  -F "status=2" \
  -F "notify=1" \
  -F "notes=$RELEASE_NOTES" \
  -F "notes_type=1" \
  -F "ipa=@build/app/outputs/apk/development/release/app-development-release.apk" \
  -H "X-HockeyAppToken: $BUILD_TOKEN" \
  https://rink.hockeyapp.net/api/2/apps/${HOCKEY_APP_ID}/app_versions/upload
