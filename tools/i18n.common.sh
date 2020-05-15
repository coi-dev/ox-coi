TRANSLATION_SERVICE_URL="http://services.open-xchange.com:8080"

# Create temporary directory
TMP_DIR="$(mktemp -d)"
function cleanup {
    rm -fr "$TMP_DIR" 2> /dev/null || true
}
trap cleanup EXIT

function prepareIosStrings {
	echo "Preparing iOS strings for conversion"

    local INPUT_STRINGS_ZIP="$1"

    local INPUT_STRINGS_DIR="ios/OX Coi/en.lproj"
    local FILES=$(find "$INPUT_STRINGS_DIR" -name "*.strings" \
    	-o -name "*.stringsdict")
    echo "$FILES" | while read -r FILE; do
        zip -r "$INPUT_STRINGS_ZIP" "$FILE"
    done
}