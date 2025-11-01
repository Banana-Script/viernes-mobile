class OrganizationalRole {
  final String valueDefinition;
  final String description;

  const OrganizationalRole({
    required this.valueDefinition,
    required this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrganizationalRole &&
        other.valueDefinition == valueDefinition &&
        other.description == description;
  }

  @override
  int get hashCode => valueDefinition.hashCode ^ description.hashCode;

  @override
  String toString() {
    return 'OrganizationalRole(valueDefinition: $valueDefinition, description: $description)';
  }
}

class OrganizationalStatus {
  final String valueDefinition;
  final String description;

  const OrganizationalStatus({
    required this.valueDefinition,
    required this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrganizationalStatus &&
        other.valueDefinition == valueDefinition &&
        other.description == description;
  }

  @override
  int get hashCode => valueDefinition.hashCode ^ description.hashCode;

  @override
  String toString() {
    return 'OrganizationalStatus(valueDefinition: $valueDefinition, description: $description)';
  }
}

class UserEntity {
  // Firebase fields
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;

  // Backend fields
  final int? databaseId;
  final bool? available;
  final String? fullname;
  final OrganizationalRole? organizationalRole;
  final OrganizationalStatus? organizationalStatus;
  final int? organizationId;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.emailVerified,
    this.databaseId,
    this.available,
    this.fullname,
    this.organizationalRole,
    this.organizationalStatus,
    this.organizationId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoURL == photoURL &&
        other.emailVerified == emailVerified &&
        other.databaseId == databaseId &&
        other.available == available &&
        other.fullname == fullname &&
        other.organizationalRole == organizationalRole &&
        other.organizationalStatus == organizationalStatus &&
        other.organizationId == organizationId;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoURL.hashCode ^
        emailVerified.hashCode ^
        databaseId.hashCode ^
        available.hashCode ^
        fullname.hashCode ^
        organizationalRole.hashCode ^
        organizationalStatus.hashCode ^
        organizationId.hashCode;
  }

  @override
  String toString() {
    return 'UserEntity(uid: $uid, email: $email, displayName: $displayName, photoURL: $photoURL, emailVerified: $emailVerified, databaseId: $databaseId, available: $available, fullname: $fullname, organizationalRole: $organizationalRole, organizationalStatus: $organizationalStatus, organizationId: $organizationId)';
  }

  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? emailVerified,
    int? databaseId,
    bool? available,
    String? fullname,
    OrganizationalRole? organizationalRole,
    OrganizationalStatus? organizationalStatus,
    int? organizationId,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      emailVerified: emailVerified ?? this.emailVerified,
      databaseId: databaseId ?? this.databaseId,
      available: available ?? this.available,
      fullname: fullname ?? this.fullname,
      organizationalRole: organizationalRole ?? this.organizationalRole,
      organizationalStatus: organizationalStatus ?? this.organizationalStatus,
      organizationId: organizationId ?? this.organizationId,
    );
  }
}