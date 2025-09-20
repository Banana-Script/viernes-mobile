import 'package:equatable/equatable.dart';

/// User profile entity representing the complete user information
/// Matches the web app user data structure with additional mobile-specific fields
class UserProfile extends Equatable {
  final String? id;
  final String? firebaseUid;
  final int? databaseId;
  final String? email;
  final String? displayName;
  final String? fullName;
  final String? photoURL;
  final String? phoneNumber;
  final bool isEmailVerified;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? lastSeen;
  final UserOrganization? organization;
  final UserRole? role;
  final UserStatus? status;

  const UserProfile({
    this.id,
    this.firebaseUid,
    this.databaseId,
    this.email,
    this.displayName,
    this.fullName,
    this.photoURL,
    this.phoneNumber,
    this.isEmailVerified = false,
    this.isAvailable = false,
    this.createdAt,
    this.lastSeen,
    this.organization,
    this.role,
    this.status,
  });

  UserProfile copyWith({
    String? id,
    String? firebaseUid,
    int? databaseId,
    String? email,
    String? displayName,
    String? fullName,
    String? photoURL,
    String? phoneNumber,
    bool? isEmailVerified,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? lastSeen,
    UserOrganization? organization,
    UserRole? role,
    UserStatus? status,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      databaseId: databaseId ?? this.databaseId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      fullName: fullName ?? this.fullName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      organization: organization ?? this.organization,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'databaseId': databaseId,
      'email': email,
      'displayName': displayName,
      'fullName': fullName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'isEmailVerified': isEmailVerified,
      'isAvailable': isAvailable,
      'createdAt': createdAt?.toIso8601String(),
      'lastSeen': lastSeen?.toIso8601String(),
      'organization': organization?.toJson(),
      'role': role?.toJson(),
      'status': status?.toJson(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String?,
      firebaseUid: json['firebaseUid'] as String?,
      databaseId: json['databaseId'] as int?,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      fullName: json['fullName'] as String?,
      photoURL: json['photoURL'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
      organization: json['organization'] != null
          ? UserOrganization.fromJson(json['organization'] as Map<String, dynamic>)
          : null,
      role: json['role'] != null
          ? UserRole.fromJson(json['role'] as Map<String, dynamic>)
          : null,
      status: json['status'] != null
          ? UserStatus.fromJson(json['status'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Get the user's initials for avatar display
  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final names = fullName!.trim().split(' ');
      if (names.length >= 2) {
        return '${names.first[0]}${names.last[0]}'.toUpperCase();
      }
      return fullName![0].toUpperCase();
    }
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName![0].toUpperCase();
    }
    if (email != null && email!.isNotEmpty) {
      return email![0].toUpperCase();
    }
    return 'U';
  }

  /// Get the display name prioritizing fullName, then displayName, then email
  String get preferredDisplayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    if (email != null && email!.isNotEmpty) {
      return email!.split('@').first;
    }
    return 'User';
  }

  @override
  List<Object?> get props => [
        id,
        firebaseUid,
        databaseId,
        email,
        displayName,
        fullName,
        photoURL,
        phoneNumber,
        isEmailVerified,
        isAvailable,
        createdAt,
        lastSeen,
        organization,
        role,
        status,
      ];
}

/// User organization entity
class UserOrganization extends Equatable {
  final int? id;
  final String? name;
  final String? description;
  final String? timezone;
  final Map<String, dynamic>? settings;

  const UserOrganization({
    this.id,
    this.name,
    this.description,
    this.timezone,
    this.settings,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'timezone': timezone,
      'settings': settings,
    };
  }

  factory UserOrganization.fromJson(Map<String, dynamic> json) {
    return UserOrganization(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      timezone: json['timezone'] as String?,
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [id, name, description, timezone, settings];
}

/// User role entity
class UserRole extends Equatable {
  final int? id;
  final String? name;
  final String? description;
  final List<String>? permissions;

  const UserRole({
    this.id,
    this.name,
    this.description,
    this.permissions,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions,
    };
  }

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'] as List)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, name, description, permissions];
}

/// User status entity - matches the web app value definitions
class UserStatus extends Equatable {
  final int id;
  final String description;
  final String valueDefinition;

  const UserStatus({
    required this.id,
    required this.description,
    required this.valueDefinition,
  });

  /// Check if the status represents an active user
  bool get isActive => valueDefinition == '010';

  /// Check if the status represents an inactive user
  bool get isInactive => valueDefinition == '020';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'value_definition': valueDefinition,
    };
  }

  factory UserStatus.fromJson(Map<String, dynamic> json) {
    return UserStatus(
      id: json['id'] as int,
      description: json['description'] as String,
      valueDefinition: json['value_definition'] as String,
    );
  }

  @override
  List<Object?> get props => [id, description, valueDefinition];
}