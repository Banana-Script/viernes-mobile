# Claude Code Configuration - Viernes Mobile

## Project Overview
**Viernes Mobile** is a Flutter migration of the Viernes React frontend application. This is a frontend-only project that creates a mobile version of the existing web application with complete feature parity.

## Project Structure & Key Files

### 📋 Planning Documents
- **`PLAN_DESARROLLO_FLUTTER.md`** - Complete 14-week development plan with phases, timeline, and deliverables
- **`VIERNES_DESIGN_SYSTEM.md`** - Complete visual identity and design system documentation
- **`VIERNES_MOBILE_MIGRATION_GUIDE.md`** - Detailed feature migration guide with API specifications

### 🎯 Project Scope
**Core Features to Implement:**
1. **Authentication** - Login only (email/password + Google OAuth) - NO registration needed
2. **Dashboard** - Identical metrics and visualizations as React version
3. **Conversations** - Full chat system with real-time messaging and all React features
4. **Profile** - Complete user profile management matching React functionality

### 🏗️ Architecture Specifications

#### **Technology Stack**
```yaml
dependencies:
  flutter: ^3.24.3
  flutter_riverpod: ^2.5.0
  dio: ^5.4.0
  firebase_auth: ^4.15.0
  firebase_core: ^2.24.0
  go_router: ^12.1.0
  flutter_secure_storage: ^9.0.0
  fl_chart: ^0.68.0

  # Mobile-specific additions
  connectivity_plus: ^6.0.5
  dio_retry_interceptor: ^6.0.0
  local_auth: ^2.1.7
  flutter_animate: ^4.3.0
  dio_cache_interceptor: ^3.5.0
  cached_network_image: ^3.3.0
  web_socket_channel: ^2.4.0
  image_picker: ^1.0.5
  file_picker: ^6.1.1
  google_sign_in: ^6.2.1
  flutter_image_compress: ^2.3.0

dev_dependencies:
  riverpod_generator: ^2.4.0
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
  mocktail: ^1.0.0
```

#### **Project Structure**
```
lib/
├── core/                    # Core configuration and utilities
│   ├── config/
│   │   ├── environment.dart
│   │   └── firebase_config.dart
│   ├── constants/
│   │   └── app_constants.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   └── dio_providers.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── extensions.dart
├── features/                # Feature-based organization
│   ├── authentication/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── application/
│   │   └── presentation/
│   ├── dashboard/
│   ├── conversations/
│   └── profile/
├── shared/                  # Shared components
│   ├── providers/
│   └── widgets/
└── l10n/                   # Internationalization
```

## 🚀 Development Commands

### **Setup Commands**
```bash
# Create new Flutter project
flutter create --org com.bananascript viernes_mobile

# Add dependencies
flutter pub add flutter_riverpod dio firebase_auth firebase_core go_router flutter_secure_storage fl_chart

# Setup Firebase
flutterfire configure

# Run code generation
dart run build_runner build --delete-conflicting-outputs
```

### **Development Commands**
```bash
# Development mode
flutter run --flavor dev -t lib/main_dev.dart

# Production mode
flutter run --flavor prod -t lib/main_prod.dart

# Run tests
flutter test

# Generate code (models, providers)
dart run build_runner watch

# Analyze code
flutter analyze

# Format code
dart format .
```

### **Build Commands**
```bash
# Android APK
flutter build apk --flavor prod -t lib/main_prod.dart

# Android App Bundle
flutter build appbundle --flavor prod -t lib/main_prod.dart

# iOS
flutter build ios --flavor prod -t lib/main_prod.dart
```

## 📅 Development Timeline (14 Weeks)

### **Phase 1: Foundation (Weeks 1-2)**
- [ ] Project setup and Firebase configuration
- [ ] Design system implementation
- [ ] Core architecture (Riverpod, Dio, routing)
- [ ] Base widgets and theme configuration

### **Phase 2: Authentication (Weeks 3-4)**
- [ ] Firebase Auth setup
- [ ] Login screens (email/password + Google)
- [ ] Token management and secure storage
- [ ] Biometric authentication integration

### **Phase 3: Dashboard (Weeks 5-8)**
- [ ] Dashboard layout and navigation
- [ ] Data visualization with fl_chart
- [ ] Metrics integration matching React version
- [ ] Real-time data updates and caching

### **Phase 4: Conversations (Weeks 9-12)**
- [ ] Chat interface and message bubbles
- [ ] Real-time messaging (WebSocket/SSE)
- [ ] File upload and media handling
- [ ] Conversation management features

### **Phase 5: Profile & Polish (Weeks 13-14)**
- [ ] Profile management screens
- [ ] Settings and preferences
- [ ] Performance optimization
- [ ] Testing and deployment preparation

## 🔧 Implementation Guidelines

### **Code Standards**
- Use **Clean Architecture** with feature-based organization
- Implement **Riverpod** for state management
- Follow **Material Design 3** with Viernes custom theming
- Use **Freezed** for immutable data models
- Implement **comprehensive testing** (unit, widget, integration)

### **Mobile Optimization**
- Implement **offline-first** architecture
- Add **connection state management**
- Optimize for **battery efficiency**
- Include **push notifications** for real-time features
- Support **biometric authentication**

### **Performance Requirements**
- App startup time: <2 seconds
- Maintain 60 FPS during scrolling
- Memory usage: <150MB peak
- Network requests: <500ms average
- Crash rate: <0.1%

## 🎨 Design System References

### **Colors (from VIERNES_DESIGN_SYSTEM.md)**
- Primary: #374151 (Dark Gray)
- Secondary: #FFE61B (Bright Yellow)
- Accent: #51f5f8 (Cyan)
- Success: #22c55e
- Danger: #ef4444
- Warning: #f59e0b

### **Typography**
- Font Family: Nunito (Google Fonts)
- Heading 1: 40px/48px, Bold (700)
- Heading 2: 32px/40px, Bold (700)
- Body: 16px/24px, Regular (400)

## 🔐 Security Considerations

### **Authentication Security**
- Use Firebase Auth with backend token validation
- Store tokens in flutter_secure_storage
- Implement automatic token refresh
- Add biometric authentication for convenience

### **API Security**
- Implement SSL certificate pinning
- Add request signing for sensitive operations
- Use proper error handling to avoid information leakage
- Implement rate limiting awareness

## 📱 Platform-Specific Setup

### **iOS Configuration (ios/Runner/Info.plist)**
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for file attachments</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access for file attachments</string>
<key>NSFaceIDUsageDescription</key>
<string>This app uses Face ID for secure authentication</string>
```

### **Android Configuration (android/app/src/main/AndroidManifest.xml)**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## 🧪 Testing Strategy

### **Testing Types**
- **Unit Tests**: Business logic, repositories, use cases
- **Widget Tests**: UI components, screen interactions
- **Integration Tests**: Complete user flows
- **Golden Tests**: Visual regression testing

### **Test Commands**
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

## 📊 Success Metrics & KPIs

### **Technical KPIs**
- Code coverage: >80%
- Performance score: >90
- Crash-free rate: >99.5%
- App store rating: >4.5 stars

### **Feature Parity KPIs**
- Authentication: 100% feature match with React
- Dashboard: All metrics and visualizations functional
- Conversations: Complete chat functionality
- Profile: Full user management capabilities

## 🚀 Deployment & CI/CD

### **Environment Setup**
- Development: Firebase dev project
- Staging: Firebase staging project
- Production: Firebase prod project

### **CI/CD Pipeline**
- Automated testing on every PR
- Build automation for releases
- Automated deployment to TestFlight/Play Console
- Performance monitoring with Firebase Performance

## 📚 Key Reference Files

When implementing features, refer to these files:
- **Design System**: `VIERNES_DESIGN_SYSTEM.md` for UI specifications
- **Feature Details**: `VIERNES_MOBILE_MIGRATION_GUIDE.md` for implementation details
- **Development Plan**: `PLAN_DESARROLLO_FLUTTER.md` for timeline and milestones

## 🔄 Backend Integration

### **Important Notes**
- **All backend endpoints already exist** - no backend changes needed
- **APIs are functional** with React frontend - just need mobile client
- **Authentication flow** uses existing Firebase + backend token validation
- **Real-time chat** uses existing WebSocket/SSE endpoints
- **File uploads** use existing media handling APIs

### **API Base URLs**
```dart
// Configure in environment.dart
class Environment {
  static const String devBaseUrl = 'https://dev.viernes.com/api';
  static const String prodBaseUrl = 'https://api.viernes.com';
}
```

---

**Last Updated**: September 24, 2025
**Project Status**: Ready to start Phase 1
**Next Step**: Begin foundation setup following Phase 1 timeline