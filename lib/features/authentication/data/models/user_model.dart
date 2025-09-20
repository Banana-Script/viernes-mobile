import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoURL,
    required super.emailVerified,
    super.databaseId,
    super.available,
    super.organizationalRole,
    super.organizationalStatus,
    super.organizationId,
  });

  // Factory constructor from Firebase User
  factory UserModel.fromFirebaseUser(User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified,
    );
  }

  // Factory constructor from JSON (API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      emailVerified: json['emailVerified'] ?? false,
      databaseId: json['database_id']?.toString(),
      available: json['available'],
      organizationalRole: json['organizationalRole'] != null
          ? OrganizationalRoleModel.fromJson(json['organizationalRole'])
          : null,
      organizationalStatus: json['organizationalStatus'] != null
          ? OrganizationalStatusModel.fromJson(json['organizationalStatus'])
          : null,
      organizationId: json['organization_id']?.toString(),
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'emailVerified': emailVerified,
      'database_id': databaseId,
      'available': available,
      'organizationalRole': organizationalRole != null
          ? (organizationalRole as OrganizationalRoleModel).toJson()
          : null,
      'organizationalStatus': organizationalStatus != null
          ? (organizationalStatus as OrganizationalStatusModel).toJson()
          : null,
      'organization_id': organizationId,
    };
  }

  // Convert entity to model
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      photoURL: entity.photoURL,
      emailVerified: entity.emailVerified,
      databaseId: entity.databaseId,
      available: entity.available,
      organizationalRole: entity.organizationalRole,
      organizationalStatus: entity.organizationalStatus,
      organizationId: entity.organizationId,
    );
  }

  @override
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? emailVerified,
    String? databaseId,
    bool? available,
    OrganizationalRole? organizationalRole,
    OrganizationalStatus? organizationalStatus,
    String? organizationId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      emailVerified: emailVerified ?? this.emailVerified,
      databaseId: databaseId ?? this.databaseId,
      available: available ?? this.available,
      organizationalRole: organizationalRole ?? this.organizationalRole,
      organizationalStatus: organizationalStatus ?? this.organizationalStatus,
      organizationId: organizationId ?? this.organizationId,
    );
  }
}

class OrganizationalRoleModel extends OrganizationalRole {
  const OrganizationalRoleModel({
    required super.valueDefinition,
    required super.description,
  });

  factory OrganizationalRoleModel.fromJson(Map<String, dynamic> json) {
    return OrganizationalRoleModel(
      valueDefinition: json['value_definition'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value_definition': valueDefinition,
      'description': description,
    };
  }
}

class OrganizationalStatusModel extends OrganizationalStatus {
  const OrganizationalStatusModel({
    required super.valueDefinition,
    required super.description,
  });

  factory OrganizationalStatusModel.fromJson(Map<String, dynamic> json) {
    return OrganizationalStatusModel(
      valueDefinition: json['value_definition'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value_definition': valueDefinition,
      'description': description,
    };
  }
}