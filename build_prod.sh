#!/bin/bash

# Build script for PROD environment

echo "Building Viernes Mobile - PROD Environment"
echo "========================================="

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build for Android Prod
echo "Building Android Prod..."
flutter build apk --flavor prod --target lib/main_prod.dart

# Build for iOS Prod (requires macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Building iOS Prod..."
    flutter build ios --flavor prod --target lib/main_prod.dart --no-codesign
fi

echo "Prod build completed!"
echo "APK location: build/app/outputs/flutter-apk/app-prod-release.apk"