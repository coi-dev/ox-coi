#!/usr/bin/env bash

# System flags
set -e

# Constants
SCRIPT_BASEDIR=$(dirname "$0")
TRANSLATIONS_FOLDER="translations";
TRANSLATION_FILE="oxcoi.pot"
INPUT_FILE="../lib/src/l10n/l.dart"
CUSTOMER_INPUT_FILE="../lib/generated/l_dynamic.dart"

# Execution
echo "-- Setup --"
cd ${SCRIPT_BASEDIR}/.. || error "Can't navigate into app directory" 1
cd ${TRANSLATIONS_FOLDER} || error "Can't navigate into translation directory" 2

echo "-- Creating translations --"
echo "Using: `xgettext -V | grep xgettext`"
xgettext -L c -c --no-location --keyword=translationKey:1,2 --keyword=translationKey:1 --sort-output -o ${TRANSLATION_FILE} ${INPUT_FILE} ${CUSTOMER_INPUT_FILE}

echo "-- Finishing --"
echo "Updated '${TRANSLATION_FILE}' in `pwd`"