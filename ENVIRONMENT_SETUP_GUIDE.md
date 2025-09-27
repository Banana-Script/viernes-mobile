# Viernes Mobile - Multi-Environment Setup Guide

This guide explains how to use the multi-environment setup for Viernes Mobile, following 2025 Flutter best practices.

## Overview

The project now supports two environments:
- **DEV**: Development environment with `viernes-for-business-dev` Firebase project
- **PROD**: Production environment with `viernes-for-business` Firebase project

## Environment Features

### Visual Differentiation
- **DEV**: App name shows as "Viernes Dev" with development Firebase project
- **PROD**: App name shows as "Viernes" with production Firebase project
- Different bundle IDs allow both versions to be installed simultaneously

### Bundle IDs
- **DEV**: `com.bananascript.viernesforbusiness.dev`
- **PROD**: `com.bananascript.viernesforbusiness`

### Firebase Projects
- **DEV**: `viernes-for-business-dev`
- **PROD**: `viernes-for-business`

## Running the App

### Development Environment
```bash
# Run on device/emulator
flutter run --flavor dev --target lib/main_dev.dart

# Debug build
flutter build apk --flavor dev --target lib/main_dev.dart --debug

# Release build
flutter build apk --flavor dev --target lib/main_dev.dart --release

# iOS (requires macOS)
flutter run --flavor dev --target lib/main_dev.dart
flutter build ios --flavor dev --target lib/main_dev.dart
```

### Production Environment
```bash
# Run on device/emulator
flutter run --flavor prod --target lib/main_prod.dart

# Debug build
flutter build apk --flavor prod --target lib/main_prod.dart --debug

# Release build
flutter build apk --flavor prod --target lib/main_prod.dart --release

# iOS (requires macOS)
flutter run --flavor prod --target lib/main_prod.dart
flutter build ios --flavor prod --target lib/main_prod.dart
```

### Quick Build Scripts
```bash
# Build development version
./build_dev.sh

# Build production version
./build_prod.sh
```

## File Structure

```
lib/
├── main.dart              # Default entry point (PROD)
├── main_dev.dart          # DEV environment entry point
├── main_prod.dart         # PROD environment entry point
├── firebase_options_dev.dart    # DEV Firebase configuration
├── firebase_options_prod.dart   # PROD Firebase configuration
└── core/
    └── config/
        └── environment_config.dart  # Environment-specific settings

android/
└── app/
    └── src/
        ├── dev/
        │   ├── google-services.json     # DEV Firebase config
        │   └── res/
        │       └── values/
        │           └── strings.xml      # DEV app name
        ├── prod/
        │   ├── google-services.json     # PROD Firebase config
        │   └── res/
        │       └── values/
        │           └── strings.xml      # PROD app name
        └── main/...

ios/
├── config/
│   ├── dev/
│   │   └── GoogleService-Info.plist    # DEV Firebase config
│   └── prod/
│       └── GoogleService-Info.plist    # PROD Firebase config
└── Flutter/
    ├── Dev.xcconfig      # DEV build configuration
    └── Prod.xcconfig     # PROD build configuration
```

## Environment Configuration

The `EnvironmentConfig` class provides environment-specific settings:

```dart
// Check current environment
if (EnvironmentConfig.isDev) {
  // Development-specific code
}

// Get environment-specific values
String appName = EnvironmentConfig.appName;
String apiUrl = EnvironmentConfig.apiBaseUrl;
bool debugMode = EnvironmentConfig.enableDebugMode;
```

## Simultaneous Installation

Both environments can be installed on the same device simultaneously because they use different bundle IDs:

- Install DEV: `flutter install --flavor dev --target lib/main_dev.dart`
- Install PROD: `flutter install --flavor prod --target lib/main_prod.dart`

You'll see both "Viernes Dev" and "Viernes" apps on your device.

## Firebase Configuration

Each environment uses its own Firebase project:

### DEV Environment
- Project ID: `viernes-for-business-dev`
- Automatic configuration via `firebase_options_dev.dart`
- Uses dev-specific API keys and configuration

### PROD Environment
- Project ID: `viernes-for-business`
- Automatic configuration via `firebase_options_prod.dart`
- Uses production API keys and configuration

## iOS Build Configurations

For iOS development, you'll need to create build schemes in Xcode:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Create new schemes for "Dev" and "Prod"
3. Set the corresponding `.xcconfig` files for each scheme
4. The Firebase configuration will be automatically copied during build

## Troubleshooting

### Common Issues

1. **Build fails with Google Services error**
   - Ensure the package name in `google-services.json` matches the flavor's application ID
   - DEV should use `com.bananascript.viernesforbusiness.dev`
   - PROD should use `com.bananascript.viernesforbusiness`

2. **Firebase initialization fails**
   - Check that the correct Firebase options file is imported in main files
   - Verify Firebase projects are properly configured in the console

3. **App names not showing correctly**
   - Check `android/app/src/{flavor}/res/values/strings.xml` files
   - Verify iOS `Info.plist` uses `$(DISPLAY_NAME)` placeholder

## Adding New Environments

To add a new environment (e.g., staging):

1. Create new Firebase project
2. Add flavor in `android/app/build.gradle.kts`
3. Create `android/app/src/staging/` directory with configuration
4. Create `lib/main_staging.dart` and `lib/firebase_options_staging.dart`
5. Add staging configuration to `EnvironmentConfig`
6. Create iOS build configuration

## Best Practices

- Always test both environments before releasing
- Keep Firebase projects separate for security
- Use environment-specific API endpoints
- Implement feature flags for environment-specific features
- Monitor both environments separately in analytics
- Use different app icons for easy visual identification

## Commands Reference

```bash
# Development
flutter run --flavor dev --target lib/main_dev.dart
flutter build apk --flavor dev --target lib/main_dev.dart

# Production
flutter run --flavor prod --target lib/main_prod.dart
flutter build apk --flavor prod --target lib/main_prod.dart

# Clean and rebuild
flutter clean && flutter pub get

# Check for issues
flutter doctor
flutter analyze
```