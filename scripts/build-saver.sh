#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build"
DERIVED_DATA_DIR="${BUILD_DIR}/DerivedData"
MODULE_CACHE_DIR="${BUILD_DIR}/ModuleCache.noindex"
SANDBOX_HOME="${BUILD_DIR}/xcode-home"
PRODUCT_PATH="${DERIVED_DATA_DIR}/Build/Products/Release/Mystify.saver"
OUTPUT_PATH="${BUILD_DIR}/Mystify.saver"

rm -rf "${DERIVED_DATA_DIR}" "${MODULE_CACHE_DIR}" "${OUTPUT_PATH}" "${SANDBOX_HOME}"
mkdir -p "${MODULE_CACHE_DIR}" "${SANDBOX_HOME}/Library/Caches" "${SANDBOX_HOME}/Library/Logs"

export HOME="${SANDBOX_HOME}"
export CFFIXED_USER_HOME="${SANDBOX_HOME}"

xcodebuild \
  -project "${ROOT_DIR}/Mystify.xcodeproj" \
  -scheme Mystify \
  -configuration Release \
  -derivedDataPath "${DERIVED_DATA_DIR}" \
  CLANG_MODULE_CACHE_PATH="${MODULE_CACHE_DIR}" \
  build

cp -R "${PRODUCT_PATH}" "${OUTPUT_PATH}"

echo "Built ${OUTPUT_PATH}"
