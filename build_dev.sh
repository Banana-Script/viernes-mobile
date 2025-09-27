#!/bin/bash

# Build script for DEV environment

echo "Building Viernes Mobile - DEV Environment"
echo "========================================"

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build for Android Dev
echo "Building Android Dev..."
flutter build apk --flavor dev --target lib/main_dev.dart

# Build for iOS Dev (requires macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Building iOS Dev..."
    flutter build ios --flavor dev --target lib/main_dev.dart --no-codesign
fi

echo "Dev build completed!"
echo "APK location: build/app/outputs/flutter-apk/app-dev-release.apk"