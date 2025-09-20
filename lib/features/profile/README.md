# Profile Feature

Comprehensive profile management feature for the Viernes mobile app with user availability functionality matching the web application.

## Features

### ✅ User Profile Management
- User avatar with edit capability and image upload
- Professional profile header with Viernes branding
- User information display (name, email, organization, role)
- Profile editing with validation and error handling
- Real-time profile updates with optimistic UI

### ✅ User Availability System
- Real-time availability status toggle
- Pulsing indicator for online status
- API integration matching web app functionality
- Optimistic updates with error handling
- Organization timezone support

### ✅ Organization Integration
- Organization information display
- User role and status management
- Organization settings integration
- Timezone handling

### ✅ Settings Management
- Theme selection (Light/Dark/System)
- Language selection (English/Spanish)
- Notification preferences
- Account management

### ✅ Account Security
- Password change with validation
- Account deletion with confirmation
- Data export requests
- Secure authentication with Firebase

### ✅ App Information
- Version information display
- Help and support links
- Terms of service and privacy policy
- External link handling

## Architecture

### Clean Architecture Implementation
```
├── domain/
│   ├── entities/          # Core business entities
│   ├── repositories/      # Abstract repository contracts
│   └── usecases/         # Business logic use cases
├── data/
│   ├── datasources/      # Data source implementations
│   ├── models/           # Data models and DTOs
│   └── repositories/     # Repository implementations
└── presentation/
    ├── pages/            # UI screens
    ├── widgets/          # Reusable UI components
    └── providers/        # State management
```

### Key Components

#### Domain Layer
- `UserProfile`: Core user entity with organization and role info
- `AppInfo`: Application information entity
- `UserPreferences`: User settings and preferences
- `ProfileRepository`: Repository contract for data operations
- Use cases for all profile operations

#### Data Layer
- `UserStatusService`: API integration for user availability
- `ProfileLocalDataSource`: Local storage and caching
- `ProfileRemoteDataSource`: Remote API operations
- `ProfileRepositoryImpl`: Repository implementation

#### Presentation Layer
- `EnhancedProfilePage`: Main profile screen
- `UserAvailabilityWidget`: Availability toggle component
- `ProfileHeaderWidget`: Professional profile header
- `SettingsSectionWidget`: Organized settings sections

## Usage

### Basic Integration

```dart
import 'package:viernes_mobile/features/profile/profile_dependencies.dart';

// In your app
MaterialApp(
  // ... other config
  routes: {
    '/profile': (context) => const EnhancedProfilePage(),
  },
)
```

### Provider Usage

```dart
// Access user profile
final userProfile = ref.watch(userProfileProvider);

// Toggle availability
final availabilityNotifier = ref.read(userAvailabilityProvider.notifier);
await availabilityNotifier.toggleAvailability();

// Update profile
final profileNotifier = ref.read(userProfileProvider.notifier);
await profileNotifier.updateUserProfile(updatedProfile);
```

### Widget Usage

```dart
// User availability widget
const UserAvailabilityWidget(
  showTitle: true,
  padding: EdgeInsets.all(16),
)

// Organization info
OrganizationInfoWidget(
  organization: userProfile.organization,
)

// Settings section
SettingsSectionWidget(
  title: 'Account',
  children: [
    SettingsTileWidget(
      icon: Icons.security_outlined,
      title: 'Change Password',
      subtitle: 'Update your account password',
      onTap: () => _showChangePasswordDialog(),
    ),
  ],
)
```

## API Integration

### Endpoints Used
- `GET /organization_users/{id}` - Get user profile
- `PUT /organization_users/{id}` - Update user profile
- `POST /organization_users/change_agent_availability/{id}/{status}` - Toggle availability
- `GET /organization` - Get organization info

### Firebase Integration
- Authentication with ID tokens
- Avatar storage in Firebase Storage
- Profile data caching and sync

## Error Handling

- Comprehensive error handling with user-friendly messages
- Network error recovery with retry mechanisms
- Offline support with local caching
- Input validation with clear feedback

## Internationalization

- Full support for English and Spanish
- Consistent with web app translations
- Extensible for additional languages

## Testing

- Unit tests for all use cases
- Widget tests for UI components
- Integration tests for complete flows
- Error scenario coverage

## Performance

- Optimistic UI updates for better UX
- Efficient caching strategies
- Image optimization for avatars
- Memory-efficient list rendering

## Security

- Secure token management
- Input sanitization and validation
- Secure storage for sensitive data
- Firebase security rules compliance