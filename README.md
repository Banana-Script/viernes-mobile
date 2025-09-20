# Viernes Mobile

A Flutter application for video calls and communication, built for iOS and Android.

## 🚀 Features

- Multi-platform support (iOS, Android)
- Firebase integration for authentication and storage
- Video calling functionality
- Multi-environment setup (dev/prod)
- Localization support
- Modern Flutter architecture with Riverpod

## 🏗️ Architecture

This project follows a clean architecture pattern with:

- **Features**: Organized by domain (authentication, conversations, etc.)
- **Core**: Shared utilities, themes, and configuration
- **Shared**: Common providers and widgets

## 🔧 Setup

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / Xcode
- Firebase account with two projects (dev/prod)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Banana-Script/viernes-mobile.git
cd viernes-mobile
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Set up your Firebase projects (dev and prod)
   - Update the configuration in `lib/core/config/firebase_config.dart`
   - Add your `google-services.json` files for Android
   - Add your `GoogleService-Info.plist` files for iOS

## 🚀 Running the App

### Development Environment
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

### Production Environment
```bash
flutter run --flavor prod -t lib/main_prod.dart
```

## 🔥 Firebase Configuration

The app uses a multi-environment Firebase setup:

- **Development**: Uses `viernes-dev` Firebase project
- **Production**: Uses `viernes-prod` Firebase project

### Bundle IDs
- **Dev**: `com.bananascript.viernes.viernesMobile.dev`
- **Prod**: `com.bananascript.viernes.viernesMobile`

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- 🔄 Web (in progress)
- 🔄 macOS (in progress)

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 🏗️ Build

### Android
```bash
# Development
flutter build apk --flavor dev -t lib/main_dev.dart

# Production
flutter build apk --flavor prod -t lib/main_prod.dart
```

### iOS
```bash
# Development
flutter build ios --flavor dev -t lib/main_dev.dart

# Production
flutter build ios --flavor prod -t lib/main_prod.dart
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏢 Organization

This project is maintained by [Banana Script](https://github.com/Banana-Script).
