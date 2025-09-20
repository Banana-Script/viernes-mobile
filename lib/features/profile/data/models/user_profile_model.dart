import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_profile.dart';

/// Data model for user profile that extends the domain entity
/// Handles serialization/deserialization and Firebase integration
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    super.id,
    super.firebaseUid,
    super.databaseId,
    super.email,
    super.displayName,
    super.fullName,
    super.photoURL,
    super.phoneNumber,
    super.isEmailVerified,
    super.isAvailable,
    super.createdAt,
    super.lastSeen,
    super.organization,
    super.role,
    super.status,
  });

  /// Create UserProfileModel from Firebase User
  factory UserProfileModel.fromFirebaseUser(User user) {
    return UserProfileModel(
      firebaseUid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      phoneNumber: user.phoneNumber,
      isEmailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime,
      lastSeen: user.metadata.lastSignInTime,
    );
  }

  /// Create UserProfileModel from API response
  factory UserProfileModel.fromApiResponse(Map<String, dynamic> json, User? firebaseUser) {
    return UserProfileModel(
      id: json['id']?.toString(),
      firebaseUid: firebaseUser?.uid,
      databaseId: json['database_id'] as int? ?? json['id'] as int?,
      email: json['email'] as String? ?? firebaseUser?.email,
      displayName: firebaseUser?.displayName,
      fullName: json['fullname'] as String? ?? json['full_name'] as String?,
      photoURL: firebaseUser?.photoURL,
      phoneNumber: json['phone'] as String? ?? firebaseUser?.phoneNumber,
      isEmailVerified: firebaseUser?.emailVerified ?? false,
      isAvailable: json['available'] as bool? ?? false,
      createdAt: _parseDateTime(json['created_at']) ?? firebaseUser?.metadata.creationTime,
      lastSeen: _parseDateTime(json['last_seen']) ?? firebaseUser?.metadata.lastSignInTime,
      organization: json['organization'] != null
          ? UserOrganizationModel.fromJson(json['organization'] as Map<String, dynamic>)
          : null,
      role: json['role'] != null
          ? UserRoleModel.fromJson(json['role'] as Map<String, dynamic>)
          : null,
      status: json['status'] != null
          ? UserStatusModel.fromJson(json['status'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Create UserProfileModel from domain entity
  factory UserProfileModel.fromDomain(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      firebaseUid: profile.firebaseUid,
      databaseId: profile.databaseId,
      email: profile.email,
      displayName: profile.displayName,
      fullName: profile.fullName,
      photoURL: profile.photoURL,
      phoneNumber: profile.phoneNumber,
      isEmailVerified: profile.isEmailVerified,
      isAvailable: profile.isAvailable,
      createdAt: profile.createdAt,
      lastSeen: profile.lastSeen,
      organization: profile.organization,
      role: profile.role,
      status: profile.status,
    );
  }

  /// Merge Firebase user data with API response data
  UserProfileModel mergeWithFirebaseUser(User firebaseUser) {
    return UserProfileModel(
      id: id,
      firebaseUid: firebaseUser.uid,
      databaseId: databaseId,
      email: firebaseUser.email ?? email,
      displayName: firebaseUser.displayName ?? displayName,
      fullName: fullName,
      photoURL: firebaseUser.photoURL ?? photoURL,
      phoneNumber: firebaseUser.phoneNumber ?? phoneNumber,
      isEmailVerified: firebaseUser.emailVerified,
      isAvailable: isAvailable,
      createdAt: createdAt ?? firebaseUser.metadata.creationTime,
      lastSeen: firebaseUser.metadata.lastSignInTime ?? lastSeen,
      organization: organization,
      role: role,
      status: status,
    );
  }

  /// Update availability status
  UserProfileModel updateAvailability(bool newAvailability) {
    return UserProfileModel(
      id: id,
      firebaseUid: firebaseUid,
      databaseId: databaseId,
      email: email,
      displayName: displayName,
      fullName: fullName,
      photoURL: photoURL,
      phoneNumber: phoneNumber,
      isEmailVerified: isEmailVerified,
      isAvailable: newAvailability,
      createdAt: createdAt,
      lastSeen: DateTime.now(), // Update last seen when availability changes
      organization: organization,
      role: role,
      status: status,
    );
  }

  /// Convert to JSON for API requests
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'database_id': databaseId,
      'email': email,
      'display_name': displayName,
      'fullname': fullName,
      'photo_url': photoURL,
      'phone': phoneNumber,
      'email_verified': isEmailVerified,
      'available': isAvailable,
      'created_at': createdAt?.toIso8601String(),
      'last_seen': lastSeen?.toIso8601String(),
      'organization': organization?.toJson(),
      'role': role?.toJson(),
      'status': status?.toJson(),
    };
  }

  /// Create from JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String?,
      firebaseUid: json['firebase_uid'] as String? ?? json['firebaseUid'] as String?,
      databaseId: json['database_id'] as int? ?? json['databaseId'] as int?,
      email: json['email'] as String?,
      displayName: json['display_name'] as String? ?? json['displayName'] as String?,
      fullName: json['fullname'] as String? ?? json['fullName'] as String?,
      photoURL: json['photo_url'] as String? ?? json['photoURL'] as String?,
      phoneNumber: json['phone'] as String? ?? json['phoneNumber'] as String?,
      isEmailVerified: json['email_verified'] as bool? ?? json['isEmailVerified'] as bool? ?? false,
      isAvailable: json['available'] as bool? ?? json['isAvailable'] as bool? ?? false,
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      lastSeen: _parseDateTime(json['last_seen'] ?? json['lastSeen']),
      organization: json['organization'] != null
          ? UserOrganizationModel.fromJson(json['organization'] as Map<String, dynamic>)
          : null,
      role: json['role'] != null
          ? UserRoleModel.fromJson(json['role'] as Map<String, dynamic>)
          : null,
      status: json['status'] != null
          ? UserStatusModel.fromJson(json['status'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

/// Data model for user organization
class UserOrganizationModel extends UserOrganization {
  const UserOrganizationModel({
    super.id,
    super.name,
    super.description,
    super.timezone,
    super.settings,
  });

  factory UserOrganizationModel.fromJson(Map<String, dynamic> json) {
    return UserOrganizationModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      timezone: json['timezone'] as String?,
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'timezone': timezone,
      'settings': settings,
    };
  }
}

/// Data model for user role
class UserRoleModel extends UserRole {
  const UserRoleModel({
    super.id,
    super.name,
    super.description,
    super.permissions,
  });

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'] as List)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions,
    };
  }
}

/// Data model for user status
class UserStatusModel extends UserStatus {
  const UserStatusModel({
    required super.id,
    required super.description,
    required super.valueDefinition,
  });

  factory UserStatusModel.fromJson(Map<String, dynamic> json) {
    return UserStatusModel(
      id: json['id'] as int,
      description: json['description'] as String,
      valueDefinition: json['value_definition'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'value_definition': valueDefinition,
    };
  }
}