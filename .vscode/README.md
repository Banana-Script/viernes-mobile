# VS Code Configuration for Viernes Mobile

This directory contains VS Code configuration files optimized for Flutter multi-environment development.

## Launch Configurations

### 🔧 Development Environment
- **🔧 DEV - Debug** - Run development build (any available device)
- **🔧 DEV - Release** - Run development build in release mode

### 🚀 Production Environment
- **🚀 PROD - Debug** - Run production build (any available device)
- **🚀 PROD - Release** - Run production build in release mode

## Task Shortcuts

### Build Tasks
- **🧹 Flutter Clean** - Clean build artifacts
- **📦 Flutter Pub Get** - Get dependencies
- **🏗️ Build APK Dev** - Build development APK
- **🏗️ Build APK Prod** - Build production APK

### Run Tasks
- **🔧 Run DEV (iOS)** - Run development on iOS
- **🚀 Run PROD (iOS)** - Run production on iOS
- **🔧 Run DEV (Android)** - Run development on Android
- **🚀 Run PROD (Android)** - Run production on Android

### Analysis Tasks
- **🧪 Run Tests** - Execute all tests
- **🔍 Flutter Analyze** - Run static analysis
- **🩺 Flutter Doctor** - Check Flutter installation

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd+Shift+D` | Run DEV (iOS) |
| `Cmd+Shift+P` | Run PROD (iOS) |
| `Cmd+Shift+A` | Run DEV (Android) |
| `Cmd+Shift+Ctrl+A` | Run PROD (Android) |
| `Cmd+Shift+B` | Build APK Dev |
| `Cmd+Shift+Ctrl+B` | Build APK Prod |
| `Cmd+Shift+T` | Run Tests |
| `Cmd+Shift+L` | Flutter Analyze |
| `Cmd+Shift+C` | Flutter Clean |

## Settings Highlights

- **Auto Format on Save** - Automatically formats Dart code
- **Import Organization** - Automatically organizes imports
- **Dart Line Length** - Set to 120 characters
- **DevTools Integration** - Opens DevTools in Flutter mode
- **File Exclusions** - Hides build artifacts and cache files

## Usage

1. **Start Development**: Press `F5` and select a launch configuration
2. **Quick Tasks**: Use `Cmd+Shift+P` → "Tasks: Run Task"
3. **Keyboard Shortcuts**: Use the predefined shortcuts for quick actions
4. **Debug**: All configurations support breakpoints and hot reload

## Environment Variables

The configuration includes environment variables for proper Flutter development:
- `ENVIRONMENT=dev` - Default environment setting
- Flutter SDK paths and debugging options are pre-configured

## Tips

- Use different launch configurations to test both environments
- The DEV environment connects to `viernes-for-business-dev` Firebase project
- The PROD environment connects to `viernes-for-business` Firebase project
- Both environments can be installed on the same device simultaneously