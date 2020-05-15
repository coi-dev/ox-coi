#!/bin/bash

# System flags
set -e

VERBOSE=$1

# Constants
SCRIPT_BASEDIR=$(dirname "$0")

function debugOutput {
  if [[ ${VERBOSE} != '' ]]; then
      echo $1
  fi
}

# Execution
debugOutput "-- Running GENDL --"
cd "${SCRIPT_BASEDIR}/.." || error "Can't navigate into app directory" 1
(
  dart ./tools/gendl/gendl.dart -j assets/customer/json/onboarding.json -d lib/generated/l_dynamic.dart $1
)
debugOutput "-- 🍺 All things are GENDL'd --"
