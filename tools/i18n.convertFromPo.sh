#!/usr/bin/env bash

set -eo pipefail

source tools/i18n.common.sh

function convertFromPo {
	echo "Converting PO to strings"

    local INPUT_STRINGS_ZIP="$1"
    local PO_ZIP_PATH="$2"
	local PLATFORM_NAME="$3"

	local OUTPUT_STRINGS_ZIP="$TMP_DIR/strings-out.zip"

	local HTTP_CODE=$(curl -sw '%{http_code}' -o "$OUTPUT_STRINGS_ZIP" \
		-F "input=@$PO_ZIP_PATH" -F "input=@$INPUT_STRINGS_ZIP" \
		"$TRANSLATION_SERVICE_URL/$PLATFORM_NAME")

	if [ "$HTTP_CODE" != "200" ]; then
        echo "Error $HTTP_CODE"
        cat "$POT_FILE"
        exit 1
    fi

	unzip -o "$OUTPUT_STRINGS_ZIP"
}

function preparePo {
	echo "Preparing PO for conversion"

	local PO_ZIP_PATH="$1"
	local PLATFORM_NAME="$2"

	local FILES=$(find "i18n/$PLATFORM_NAME" -name "*.po")
	echo "$FILES" | while read -r FILE; do
    #for FILE in "${FILES[@]}"; do
        zip -r "$PO_ZIP_PATH" "$FILE"
    done
}

PO_ZIP_PATH="$TMP_DIR/po.zip"
preparePo "$PO_ZIP_PATH" ios

INPUT_STRINGS_ZIP="$TMP_DIR/input-strings.zip"
prepareIosStrings "$INPUT_STRINGS_ZIP"

convertFromPo "$INPUT_STRINGS_ZIP" "$PO_ZIP_PATH" ios

# TODO rename languages