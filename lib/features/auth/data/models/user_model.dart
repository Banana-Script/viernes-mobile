import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

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

  /// Creates a UserModel from backend JSON (all fields)
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
              'value_definition': organizationalRole!.valueDefinition,
              'description': organizationalRole!.description,
            }
          : null,
      'organizationalStatus': organizationalStatus != null
          ? {
              'value_definition': organizationalStatus!.valueDefinition,
              'description': organizationalStatus!.description,
            }
          : null,
      'organization_id': organizationId,
    };
  }
}