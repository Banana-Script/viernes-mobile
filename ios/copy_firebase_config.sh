#!/bin/bash

# Script to copy the appropriate Firebase configuration based on build configuration

CONFIG_PATH=""

if [[ "${CONFIGURATION}" == *"dev"* ]] || [[ "${CONFIGURATION}" == *"Dev"* ]]; then
    CONFIG_PATH="${SRCROOT}/config/dev/GoogleService-Info.plist"
elif [[ "${CONFIGURATION}" == *"prod"* ]] || [[ "${CONFIGURATION}" == *"Prod"* ]]; then
    CONFIG_PATH="${SRCROOT}/config/prod/GoogleService-Info.plist"
else
    # Default to prod for Release builds
    CONFIG_PATH="${SRCROOT}/config/prod/GoogleService-Info.plist"
fi

echo "Build Configuration: ${CONFIGURATION}"
echo "Copying Firebase config from: ${CONFIG_PATH}"

# Copy to Runner directory (required for Xcode build)
cp "${CONFIG_PATH}" "${SRCROOT}/Runner/GoogleService-Info.plist"

# Ensure the destination directory exists
mkdir -p "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app"

# Copy the appropriate config file to the main bundle
cp "${CONFIG_PATH}" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

echo "Firebase configuration copied successfully"