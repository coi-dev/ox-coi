#!/usr/bin/env bash

set -eo pipefail

source tools/i18n.common.sh

function convertToPot {
    echo "Converting strings to POT"

    local INPUT_FILE="$1"
    local POT_FILE="$2"

    local HTTP_CODE=$(curl -sw '%{http_code}' -F "input=@$INPUT_FILE" \
        -o "$POT_FILE" "$TRANSLATION_SERVICE_URL/po")

    if [ "$HTTP_CODE" != "200" ]; then
        echo "Error $HTTP_CODE"
        cat "$POT_FILE"
        exit 1
    fi
}

# TODO android

INPUT_STRINGS_ZIP="$TMP_DIR/input-strings.zip"
prepareIosStrings "$INPUT_STRINGS_ZIP"
convertToPot "$INPUT_STRINGS_ZIP" "i18n/ios.pot"