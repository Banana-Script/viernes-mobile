import 'package:flutter_test/flutter_test.dart';
import 'package:viernes_mobile/features/auth/domain/entities/user_entity.dart';

void main() {
  group('OrganizationalStatus', () {
    test('isActive should return true for status code 010', () {
      // Arrange
      const status = OrganizationalStatus(
        id: 1,
        valueDefinition: '010',
        description: 'Active',
      );

      // Act & Assert
      expect(status.isActive, true);
    });

    test('isActive should return false for status code 020', () {
      // Arrange
      const status = OrganizationalStatus(
        id: 2,
        valueDefinition: '020',
        description: 'Inactive',
      );

      // Act & Assert
      expect(status.isActive, false);
    });

    test('isActive should return false for any other status code', () {
      // Arrange
      const status = OrganizationalStatus(
        id: 3,
        valueDefinition: '030',
        description: 'Suspended',
      );

      // Act & Assert
      expect(status.isActive, false);
    });

    test('should create status with all fields', () {
      // Arrange & Act
      const status = OrganizationalStatus(
        id: 4,
        valueDefinition: '020',
        description: 'Inactive',
      );

      // Assert
      expect(status.id, 4);
      expect(status.valueDefinition, '020');
      expect(status.description, 'Inactive');
    });

    test('should support equality comparison', () {
      // Arrange
      const status1 = OrganizationalStatus(
        id: 1,
        valueDefinition: '010',
        description: 'Active',
      );
      const status2 = OrganizationalStatus(
        id: 1,
        valueDefinition: '010',
        description: 'Active',
      );
      const status3 = OrganizationalStatus(
        id: 2,
        valueDefinition: '020',
        description: 'Inactive',
      );

      // Act & Assert
      expect(status1, status2);
      expect(status1 == status3, false);
    });
  });

  group('UserEntity', () {
    test('should create user entity with all fields', () {
      // Arrange
      const role = OrganizationalRole(
        id: 11,
        valueDefinition: '020',
        description: 'Admin',
      );
      const status = OrganizationalStatus(
        id: 4,
        valueDefinition: '020',
        description: 'Inactive',
      );

      // Act
      const user = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        emailVerified: true,
        databaseId: 660,
        available: false,
        fullname: 'Test Full Name',
        organizationalRole: role,
        organizationalStatus: status,
        organizationId: 131,
        organizationUserId: 580,
        roleId: 11,
        statusId: 4,
      );

      // Assert
      expect(user.uid, 'test-uid');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.photoURL, 'https://example.com/photo.jpg');
      expect(user.emailVerified, true);
      expect(user.databaseId, 660);
      expect(user.available, false);
      expect(user.fullname, 'Test Full Name');
      expect(user.organizationalRole, role);
      expect(user.organizationalStatus, status);
      expect(user.organizationId, 131);
      expect(user.organizationUserId, 580);
      expect(user.roleId, 11);
      expect(user.statusId, 4);
    });

    test('copyWith should update only specified fields', () {
      // Arrange
      const originalUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        emailVerified: false,
        databaseId: 660,
      );

      // Act
      final updatedUser = originalUser.copyWith(
        emailVerified: true,
        fullname: 'New Name',
      );

      // Assert
      expect(updatedUser.uid, 'test-uid'); // Unchanged
      expect(updatedUser.email, 'test@example.com'); // Unchanged
      expect(updatedUser.emailVerified, true); // Changed
      expect(updatedUser.fullname, 'New Name'); // Changed
      expect(updatedUser.databaseId, 660); // Unchanged
    });
  });
}
