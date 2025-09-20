# Firebase Multi-Environment Setup Guide

This guide provides step-by-step instructions for setting up Firebase with multi-environment support (dev/prod) in the Viernes Flutter mobile app.

## Prerequisites

1. **Firebase Project**: Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. **Flutter CLI**: Ensure Flutter is installed and configured
3. **Firebase CLI**: Install Firebase CLI for project management

## 1. Multi-Environment Overview

The app supports two environments:
- **Development** (`dev`) - Bundle ID: `com.bananascript.viernes.viernesMobile.dev`
- **Production** (`prod`) - Bundle ID: `com.bananascript.viernes.viernesMobile`

## 2. Firebase Project Configuration

### Step 1: Create Firebase Projects
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create two projects:
   - `viernes-dev` (for development)
   - `viernes-prod` (for production)
3. Enable Google Analytics (recommended) for both projects

### Step 2: Enable Authentication Methods
1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable the following providers:
   - **Email/Password**: Enable this provider
   - **Google**: Enable and configure OAuth consent screen

## 2. Android Configuration

### Step 1: Add Android App to Firebase
1. In Firebase Console, click "Add app" and select Android
2. Register app with package name: `com.viernes.mobile`
3. Download `google-services.json` file
4. Place it in `android/app/google-services.json`

### Step 2: Configure Android Build Files
The following files have already been configured:

- `android/build.gradle.kts`: Firebase Gradle plugin added
- `android/app/build.gradle.kts`: Google services plugin applied

### Step 3: Configure Google Sign-In for Android
1. In Firebase Console, go to **Authentication** > **Sign-in method** > **Google**
2. Note the **Web client ID** - you'll need this for iOS configuration
3. Android configuration is automatically handled by `google-services.json`

## 3. iOS Configuration

### Step 1: Add iOS App to Firebase
1. In Firebase Console, click "Add app" and select iOS
2. Register app with bundle ID: `com.viernes.mobile`
3. Download `GoogleService-Info.plist` file
4. Add it to `ios/Runner/GoogleService-Info.plist` using Xcode

### Step 2: Configure iOS Build Settings
Add the following to `ios/Runner/Info.plist`:

```xml
<!-- Google Sign-In URL Scheme -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

Replace `YOUR_REVERSED_CLIENT_ID` with the value from `GoogleService-Info.plist`.

## 4. Environment Configuration

### Step 1: Create Environment Files
Copy the example files and fill in your Firebase credentials:

```bash
cp .env.example .env
```

### Step 2: Configure Environment Variables
Edit `.env` file with your Firebase project credentials:

```env
# Firebase Configuration
FIREBASE_API_KEY=your_firebase_api_key_here
FIREBASE_AUTH_DOMAIN=your_project_id.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project_id.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
FIREBASE_APP_ID=your_app_id
FIREBASE_IOS_CLIENT_ID=your_ios_client_id

# API Configuration
API_BASE_URL=https://bot.dev.viernes-for-business.bananascript.io

# Google Sign In Configuration
GOOGLE_CLIENT_ID=your_google_client_id
```

## 5. Google Sign-In Configuration

### Android Google Sign-In
1. Generate SHA-1 certificate fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
2. Add SHA-1 fingerprint to Firebase project settings
3. Download updated `google-services.json`

### iOS Google Sign-In
1. Get iOS client ID from `GoogleService-Info.plist`
2. Add REVERSED_CLIENT_ID URL scheme to `Info.plist`
3. Configure OAuth consent screen in Google Cloud Console

## 6. Backend API Configuration

The app integrates with the Viernes backend API for user management:

### API Endpoints Used:
- `POST /auth/register` - User registration
- `GET /users/by-uid/{uid}` - Get user by Firebase UID
- `GET /auth/current-user-organizational-info` - Get user organizational data
- `GET /user-status/{databaseId}` - Get user availability status
- `POST /user-status/{databaseId}/toggle` - Toggle user availability

### Authentication Flow:
1. User authenticates with Firebase (email/password or Google)
2. Firebase returns ID token
3. ID token is sent to backend API for user data retrieval
4. Backend validates token and returns user information

## 7. Multi-Environment File Structure

```
viernes_mobile/
├── lib/
│   ├── core/config/
│   │   ├── environment.dart (environment detection)
│   │   └── firebase_config.dart (multi-env Firebase config)
│   ├── main_dev.dart (development entry point)
│   └── main_prod.dart (production entry point)
├── android/app/
│   ├── src/
│   │   ├── dev/google-services.json (dev Firebase config)
│   │   └── prod/google-services.json (prod Firebase config)
│   └── build.gradle.kts (with dev/prod flavors)
├── ios/Runner/
│   ├── GoogleService-Info-Dev.plist
│   └── GoogleService-Info-Prod.plist
└── scripts/
    └── configure_firebase.sh (environment configuration script)
```

## 8. Build and Run

### Configure Environment
```bash
# Configure for development
./scripts/configure_firebase.sh dev

# Configure for production
./scripts/configure_firebase.sh prod
```

### Development Build
```bash
# Run development flavor
flutter run --flavor dev -t lib/main_dev.dart --dart-define=ENVIRONMENT=development

# Build development APK
flutter build apk --flavor dev -t lib/main_dev.dart --dart-define=ENVIRONMENT=development
```

### Production Build
```bash
# Run production flavor
flutter run --flavor prod -t lib/main_prod.dart --dart-define=ENVIRONMENT=production

# Build production APK
flutter build apk --flavor prod -t lib/main_prod.dart --dart-define=ENVIRONMENT=production
```

## 8. Troubleshooting

### Common Issues:

1. **Google Sign-In fails on Android**
   - Verify SHA-1 fingerprint is added to Firebase
   - Ensure `google-services.json` is up to date

2. **Google Sign-In fails on iOS**
   - Check REVERSED_CLIENT_ID in `Info.plist`
   - Verify bundle ID matches Firebase configuration

3. **Authentication errors**
   - Check Firebase project permissions
   - Verify API keys in environment file
   - Ensure authentication methods are enabled in Firebase Console

4. **API integration issues**
   - Verify API base URL in environment
   - Check network connectivity
   - Validate Firebase ID token format

## 9. Security Considerations

1. **Environment Variables**: Never commit `.env` files to version control
2. **API Keys**: Use different Firebase projects for development/production
3. **Token Storage**: Tokens are stored securely using `flutter_secure_storage`
4. **Backend Validation**: Always validate Firebase tokens on the backend

## 10. Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Authentication Flow Testing
1. Test email/password login
2. Test Google Sign-In
3. Test logout functionality
4. Test token refresh
5. Test error handling

## Support

For additional help:
- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Google Sign-In Documentation](https://pub.dev/packages/google_sign_in)
- [Flutter Documentation](https://docs.flutter.dev/)