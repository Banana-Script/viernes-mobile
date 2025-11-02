class OrganizationalRole {
  final int id;
  final String valueDefinition;
  final String description;

  const OrganizationalRole({
    required this.id,
    required this.valueDefinition,
    required this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrganizationalRole &&
        other.id == id &&
        other.valueDefinition == valueDefinition &&
        other.description == description;
  }

  @override
  int get hashCode => id.hashCode ^ valueDefinition.hashCode ^ description.hashCode;

  @override
  String toString() {
    return 'OrganizationalRole(id: $id, valueDefinition: $valueDefinition, description: $description)';
  }
}

class OrganizationalStatus {
  final int id;
  final String valueDefinition;
  final String description;

  const OrganizationalStatus({
    required this.id,
    required this.valueDefinition,
    required this.description,
  });

  /// Helper to check if the status represents an active agent
  /// Status value_definition "010" = Active, "020" = Inactive
  bool get isActive => valueDefinition == "010";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrganizationalStatus &&
        other.id == id &&
        other.valueDefinition == valueDefinition &&
        other.description == description;
  }

  @override
  int get hashCode => id.hashCode ^ valueDefinition.hashCode ^ description.hashCode;

  @override
  String toString() {
    return 'OrganizationalStatus(id: $id, valueDefinition: $valueDefinition, description: $description)';
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
  final int? databaseId; // This is the user.id from backend (e.g., 660)
  final bool? available;
  final String? fullname;
  final OrganizationalRole? organizationalRole;
  final OrganizationalStatus? organizationalStatus;
  final int? organizationId;

  // Organization user fields
  final int? organizationUserId; // This is the organization_users.id (e.g., 580)
  final int? roleId; // Role ID from organization_users
  final int? statusId; // Status ID from organization_users

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
    this.organizationUserId,
    this.roleId,
    this.statusId,
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
        other.organizationId == organizationId &&
        other.organizationUserId == organizationUserId &&
        other.roleId == roleId &&
        other.statusId == statusId;
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
        organizationId.hashCode ^
        organizationUserId.hashCode ^
        roleId.hashCode ^
        statusId.hashCode;
  }

  @override
  String toString() {
    return 'UserEntity(uid: $uid, email: $email, displayName: $displayName, photoURL: $photoURL, emailVerified: $emailVerified, databaseId: $databaseId, available: $available, fullname: $fullname, organizationalRole: $organizationalRole, organizationalStatus: $organizationalStatus, organizationId: $organizationId, organizationUserId: $organizationUserId, roleId: $roleId, statusId: $statusId)';
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
    int? organizationUserId,
    int? roleId,
    int? statusId,
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
      organizationUserId: organizationUserId ?? this.organizationUserId,
      roleId: roleId ?? this.roleId,
      statusId: statusId ?? this.statusId,
    );
  }
}
