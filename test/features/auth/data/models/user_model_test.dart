import 'package:flutter_test/flutter_test.dart';
import 'package:viernes_mobile/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel.fromBackendJson', () {
    test('should correctly parse backend JSON with nested structure', () {
      // Arrange
      final json = {
        'id': 580, // organization_users.id
        'user_id': 660, // users.id
        'organization_id': 131,
        'role_id': 11,
        'status_id': 4,
        'status': {
          'id': 4,
          'value_definition': '020',
          'description': 'Inactive',
        },
        'role': {
          'id': 11,
          'value_definition': '020',
          'description': 'Admin',
        },
        'user': {
          'id': 660,
          'fullname': 'Jeisson Huerfano',
          'email': 'fricred+pash@gmail.com',
          'firebase_uid': 'auz4lE3u2CVlbIlSBkLfLYGX82Z2',
        },
        'available': false,
      };

      // Act
      final model = UserModel.fromBackendJson(json);

      // Assert - Firebase fields from nested user object
      expect(model.uid, 'auz4lE3u2CVlbIlSBkLfLYGX82Z2');
      expect(model.email, 'fricred+pash@gmail.com');
      expect(model.displayName, 'Jeisson Huerfano');
      expect(model.emailVerified, true);

      // Assert - Backend user fields
      expect(model.databaseId, 660); // users.id
      expect(model.fullname, 'Jeisson Huerfano');
      expect(model.available, false);

      // Assert - Organization user fields
      expect(model.organizationUserId, 580); // organization_users.id
      expect(model.organizationId, 131);
      expect(model.roleId, 11);
      expect(model.statusId, 4);

      // Assert - Nested role object
      expect(model.organizationalRole, isNotNull);
      expect(model.organizationalRole!.id, 11);
      expect(model.organizationalRole!.valueDefinition, '020');
      expect(model.organizationalRole!.description, 'Admin');

      // Assert - Nested status object
      expect(model.organizationalStatus, isNotNull);
      expect(model.organizationalStatus!.id, 4);
      expect(model.organizationalStatus!.valueDefinition, '020');
      expect(model.organizationalStatus!.description, 'Inactive');
      expect(model.organizationalStatus!.isActive, false);
    });

    test('should handle active status (010) correctly', () {
      // Arrange
      final json = {
        'id': 580,
        'user_id': 660,
        'organization_id': 131,
        'role_id': 11,
        'status_id': 3,
        'status': {
          'id': 3,
          'value_definition': '010',
          'description': 'Active',
        },
        'role': {
          'id': 11,
          'value_definition': '020',
          'description': 'Admin',
        },
        'user': {
          'id': 660,
          'fullname': 'Test User',
          'email': 'test@example.com',
          'firebase_uid': 'test-uid',
        },
      };

      // Act
      final model = UserModel.fromBackendJson(json);

      // Assert
      expect(model.organizationalStatus, isNotNull);
      expect(model.organizationalStatus!.valueDefinition, '010');
      expect(model.organizationalStatus!.isActive, true);
    });

    test('should handle missing optional fields gracefully', () {
      // Arrange
      final json = {
        'id': 580,
        'user_id': 660,
        'organization_id': 131,
        'role_id': 11,
        'status_id': 4,
        // No status object
        // No role object
        'user': {
          'id': 660,
          'fullname': 'Test User',
          'email': 'test@example.com',
          'firebase_uid': 'test-uid',
        },
      };

      // Act
      final model = UserModel.fromBackendJson(json);

      // Assert
      expect(model.uid, 'test-uid');
      expect(model.email, 'test@example.com');
      expect(model.organizationalRole, isNull);
      expect(model.organizationalStatus, isNull);
    });

    test('should handle empty nested user object', () {
      // Arrange
      final json = {
        'id': 580,
        'user_id': 660,
        'organization_id': 131,
        'role_id': 11,
        'status_id': 4,
        'user': <String, dynamic>{},
      };

      // Act
      final model = UserModel.fromBackendJson(json);

      // Assert
      expect(model.uid, ''); // Default value
      expect(model.email, ''); // Default value
      expect(model.databaseId, isNull);
    });
  });

  group('OrganizationalRoleModel', () {
    test('should parse from JSON correctly', () {
      // Arrange
      final json = {
        'id': 11,
        'value_definition': '020',
        'description': 'Admin',
      };

      // Act
      final model = OrganizationalRoleModel.fromJson(json);

      // Assert
      expect(model.id, 11);
      expect(model.valueDefinition, '020');
      expect(model.description, 'Admin');
    });

    test('should convert to JSON correctly', () {
      // Arrange
      const model = OrganizationalRoleModel(
        id: 11,
        valueDefinition: '020',
        description: 'Admin',
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], 11);
      expect(json['value_definition'], '020');
      expect(json['description'], 'Admin');
    });
  });

  group('OrganizationalStatusModel', () {
    test('should parse from JSON correctly', () {
      // Arrange
      final json = {
        'id': 4,
        'value_definition': '020',
        'description': 'Inactive',
      };

      // Act
      final model = OrganizationalStatusModel.fromJson(json);

      // Assert
      expect(model.id, 4);
      expect(model.valueDefinition, '020');
      expect(model.description, 'Inactive');
      expect(model.isActive, false);
    });

    test('should convert to JSON correctly', () {
      // Arrange
      const model = OrganizationalStatusModel(
        id: 3,
        valueDefinition: '010',
        description: 'Active',
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], 3);
      expect(json['value_definition'], '010');
      expect(json['description'], 'Active');
    });
  });
}
