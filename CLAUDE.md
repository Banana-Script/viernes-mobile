# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
# Development
flutter run --flavor dev --target lib/main_dev.dart

# Production
flutter run --flavor prod --target lib/main_prod.dart

# Build APKs
flutter build apk --flavor dev --target lib/main_dev.dart
flutter build apk --flavor prod --target lib/main_prod.dart

# Analysis
flutter analyze

# Tests
flutter test
flutter test test/path/to/specific_test.dart  # Single test

# Clean rebuild
flutter clean && flutter pub get
```

VS Code tasks are preconfigured in `.vscode/tasks.json` with keyboard shortcuts (see `.vscode/README.md`).

## Architecture

This is a Flutter customer service mobile app using **Clean Architecture** with a hybrid state management approach.

### Project Structure

```
lib/
├── main_dev.dart / main_prod.dart   # Entry points (set environment, init Firebase)
├── app.dart                          # Root widget, AuthenticationWrapper
├── core/
│   ├── config/environment_config.dart  # Dev/prod environment settings
│   ├── di/dependency_injection.dart    # Manual DI container (all singletons)
│   ├── services/                       # HTTP client, SSE, notifications, FCM
│   └── theme/                          # Design system (colors, typography, theme manager)
├── features/                           # Feature modules
│   ├── auth/
│   ├── conversations/
│   ├── customers/
│   ├── dashboard/
│   └── ...
└── shared/widgets/                     # Reusable UI components
```

### Feature Module Pattern

Each feature follows Clean Architecture with three layers:

```
features/<feature>/
├── data/
│   ├── datasources/    # Remote data sources (HTTP calls)
│   ├── models/         # API/database models with toJson/fromJson
│   └── repositories/   # Repository implementations
├── domain/
│   ├── entities/       # Business logic entities
│   ├── repositories/   # Repository interfaces
│   └── usecases/       # Single-responsibility use cases
└── presentation/
    ├── pages/          # Screen widgets
    ├── providers/      # ChangeNotifier state management
    └── widgets/        # Feature-specific widgets
```

### State Management

- **Provider (`ChangeNotifier`)**: Feature-level state (AuthProvider, ConversationProvider, etc.)
- **Riverpod**: App-level concerns (theme management via `ThemeManager`)

Providers are initialized in `DependencyInjection.initialize()` and registered in `ViernesApp` via `MultiProvider`.

### Dependency Injection

All dependencies are wired in `lib/core/di/dependency_injection.dart`:
- Single `HttpClient` instance shared across features
- Each feature initializes its datasource → repository → use cases → provider chain
- Access via static getters: `DependencyInjection.authProvider`, `.conversationProvider`, etc.

### Multi-Environment Setup

Two environments with separate Firebase projects:
- **dev**: `main_dev.dart`, flavor `dev`, Firebase project `viernes-for-business-dev`
- **prod**: `main_prod.dart`, flavor `prod`, Firebase project `viernes-for-business`

Android flavors configured in `android/app/build.gradle.kts`.

### Real-Time Features

- **SSE (Server-Sent Events)**: `ConversationSseService` for live conversation updates
- **FCM**: Push notifications via `FCMTokenService` and `FCMMessageHandler`
- **NotificationService**: Local notifications with user ID filtering

SSE connects after authentication in `AuthenticationWrapper` and disconnects on logout.

### Key Files to Understand

1. `lib/app.dart` - Root widget, auth state handling, SSE lifecycle
2. `lib/core/di/dependency_injection.dart` - All DI wiring
3. `lib/core/services/http_client.dart` - Dio client with Firebase token interceptor
4. `lib/features/*/presentation/providers/*_provider.dart` - Feature state management

## Deployment Notes

To upload to Play Store with dev backend, use flavor `prod` with target `main_dev.dart`:
```bash
flutter build appbundle --flavor prod --target lib/main_dev.dart
```

## Code Conventions

- Dart line length: 120 characters
- Use cases: one per file, single business operation
- Entities (domain) vs Models (data): conversion happens in repositories
- Logging: `debugPrint` with component tags like `[AuthWrapper]`, `[SSE Init]`
