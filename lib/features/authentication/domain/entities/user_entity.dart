import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  final String? databaseId;
  final bool? available;
  final OrganizationalRole? organizationalRole;
  final OrganizationalStatus? organizationalStatus;
  final String? organizationId;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.emailVerified,
    this.databaseId,
    this.available,
    this.organizationalRole,
    this.organizationalStatus,
    this.organizationId,
  });

  UserEntity copyWith({
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
    return UserEntity(
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

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoURL,
        emailVerified,
        databaseId,
        available,
        organizationalRole,
        organizationalStatus,
        organizationId,
      ];
}

class OrganizationalRole extends Equatable {
  final String valueDefinition;
  final String description;

  const OrganizationalRole({
    required this.valueDefinition,
    required this.description,
  });

  @override
  List<Object> get props => [valueDefinition, description];
}

class OrganizationalStatus extends Equatable {
  final String valueDefinition;
  final String description;

  const OrganizationalStatus({
    required this.valueDefinition,
    required this.description,
  });

  @override
  List<Object> get props => [valueDefinition, description];
}