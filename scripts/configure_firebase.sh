#!/bin/bash

# Firebase Configuration Script
# This script copies the appropriate Firebase configuration files based on the build configuration

set -e

# Get the environment from the first parameter, default to 'dev'
ENVIRONMENT=${1:-dev}

# Define the paths
IOS_RUNNER_PATH="ios/Runner"
ANDROID_APP_PATH="android/app"

echo "🔥 Configuring Firebase for environment: $ENVIRONMENT"

# Configure iOS
if [ "$ENVIRONMENT" = "prod" ]; then
    echo "📱 Copying production iOS Firebase config..."
    cp "$IOS_RUNNER_PATH/GoogleService-Info-Prod.plist" "$IOS_RUNNER_PATH/GoogleService-Info.plist"
else
    echo "📱 Copying development iOS Firebase config..."
    cp "$IOS_RUNNER_PATH/GoogleService-Info-Dev.plist" "$IOS_RUNNER_PATH/GoogleService-Info.plist"
fi

# Configure Android
if [ "$ENVIRONMENT" = "prod" ]; then
    echo "🤖 Copying production Android Firebase config..."
    cp "$ANDROID_APP_PATH/src/prod/google-services.json" "$ANDROID_APP_PATH/google-services.json"
else
    echo "🤖 Copying development Android Firebase config..."
    cp "$ANDROID_APP_PATH/src/dev/google-services.json" "$ANDROID_APP_PATH/google-services.json"
fi

echo "✅ Firebase configuration complete for $ENVIRONMENT environment"
echo ""
echo "💡 To build the app with this configuration:"
echo "   For development: flutter run --flavor dev -t lib/main_dev.dart"
echo "   For production:  flutter run --flavor prod -t lib/main_prod.dart"