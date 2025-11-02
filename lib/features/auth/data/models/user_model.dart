import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

class OrganizationalRoleModel extends OrganizationalRole {
  const OrganizationalRoleModel({
    required super.id,
    required super.valueDefinition,
    required super.description,
  });

  factory OrganizationalRoleModel.fromJson(Map<String, dynamic> json) {
    return OrganizationalRoleModel(
      id: json['id'] ?? 0,
      valueDefinition: json['value_definition'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value_definition': valueDefinition,
      'description': description,
    };
  }
}

class OrganizationalStatusModel extends OrganizationalStatus {
  const OrganizationalStatusModel({
    required super.id,
    required super.valueDefinition,
    required super.description,
  });

  factory OrganizationalStatusModel.fromJson(Map<String, dynamic> json) {
    return OrganizationalStatusModel(
      id: json['id'] ?? 0,
      valueDefinition: json['value_definition'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value_definition': valueDefinition,
      'description': description,
    };
  }
}

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoURL,
    required super.emailVerified,
    super.databaseId,
    super.available,
    super.fullname,
    super.organizationalRole,
    super.organizationalStatus,
    super.organizationId,
    super.organizationUserId,
    super.roleId,
    super.statusId,
  });

  /// Creates a UserModel from Firebase User (only basic fields)
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoURL: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }

  /// Creates a UserModel from backend JSON response from /users/me endpoint
  /// Backend structure:
  /// {
  ///   "id": 580,                           // organization_users.id
  ///   "user_id": 660,                      // users.id (the actual user ID)
  ///   "organization_id": 131,
  ///   "role_id": 11,
  ///   "status_id": 4,
  ///   "status": {
  ///     "id": 4,
  ///     "value_definition": "020",
  ///     "description": "Inactive"
  ///   },
  ///   "role": {
  ///     "id": 11,
  ///     "value_definition": "020",
  ///     "description": "Admin"
  ///   },
  ///   "user": {
  ///     "id": 660,
  ///     "fullname": "Jeisson Huerfano",
  ///     "email": "fricred+pash@gmail.com",
  ///     "firebase_uid": "auz4lE3u2CVlbIlSBkLfLYGX82Z2"
  ///   }
  /// }
  factory UserModel.fromBackendJson(Map<String, dynamic> json) {
    // Extract nested user data
    final userData = json['user'] as Map<String, dynamic>?;
    final roleData = json['role'] as Map<String, dynamic>?;
    final statusData = json['status'] as Map<String, dynamic>?;

    return UserModel(
      // Firebase fields - get from nested user object
      uid: userData?['firebase_uid'] ?? '',
      email: userData?['email'] ?? '',
      displayName: userData?['fullname'],
      photoURL: null, // Not provided by backend
      emailVerified: true, // Assume verified if they're in the backend

      // Backend user fields
      databaseId: userData?['id'], // This is users.id (e.g., 660)
      fullname: userData?['fullname'],
      available: json['available'],

      // Organization user fields
      organizationUserId: json['id'], // This is organization_users.id (e.g., 580)
      organizationId: json['organization_id'],
      roleId: json['role_id'],
      statusId: json['status_id'],

      // Parse nested objects
      organizationalRole: roleData != null
          ? OrganizationalRoleModel.fromJson(roleData)
          : null,
      organizationalStatus: statusData != null
          ? OrganizationalStatusModel.fromJson(statusData)
          : null,
    );
  }

  /// Creates a UserModel from legacy backend JSON format (for compatibility)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      emailVerified: json['emailVerified'] ?? false,
      databaseId: json['database_id'],
      available: json['available'],
      fullname: json['fullname'],
      organizationalRole: json['organizationalRole'] != null
          ? OrganizationalRoleModel.fromJson(json['organizationalRole'])
          : null,
      organizationalStatus: json['organizationalStatus'] != null
          ? OrganizationalStatusModel.fromJson(json['organizationalStatus'])
          : null,
      organizationId: json['organization_id'],
      organizationUserId: json['organization_user_id'],
      roleId: json['role_id'],
      statusId: json['status_id'],
    );
  }

  /// Merges backend data into an existing UserModel (typically from Firebase)
  UserModel mergeWithBackendData(Map<String, dynamic> backendData) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      emailVerified: emailVerified,
      databaseId: backendData['database_id'],
      available: backendData['available'],
      fullname: backendData['fullname'],
      organizationalRole: backendData['organizationalRole'] != null
          ? OrganizationalRoleModel.fromJson(backendData['organizationalRole'])
          : null,
      organizationalStatus: backendData['organizationalStatus'] != null
          ? OrganizationalStatusModel.fromJson(backendData['organizationalStatus'])
          : null,
      organizationId: backendData['organization_id'],
      organizationUserId: backendData['organization_user_id'],
      roleId: backendData['role_id'],
      statusId: backendData['status_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'emailVerified': emailVerified,
      'database_id': databaseId,
      'available': available,
      'fullname': fullname,
      'organizationalRole': organizationalRole != null
          ? {
              'id': organizationalRole!.id,
              'value_definition': organizationalRole!.valueDefinition,
              'description': organizationalRole!.description,
            }
          : null,
      'organizationalStatus': organizationalStatus != null
          ? {
              'id': organizationalStatus!.id,
              'value_definition': organizationalStatus!.valueDefinition,
              'description': organizationalStatus!.description,
            }
          : null,
      'organization_id': organizationId,
      'organization_user_id': organizationUserId,
      'role_id': roleId,
      'status_id': statusId,
    };
  }
}
