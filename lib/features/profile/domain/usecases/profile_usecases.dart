import 'dart:io';
import '../entities/user_profile.dart';
import '../entities/app_info.dart';
import '../repositories/profile_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for getting user profile
class GetUserProfileUseCase {
  final ProfileRepository repository;

  const GetUserProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call() async {
    try {
      return await repository.getCurrentUserProfile();
    } catch (e) {
      return Left(ServerFailure('Failed to get user profile: ${e.toString()}'));
    }
  }
}

/// Use case for updating user profile
class UpdateUserProfileUseCase {
  final ProfileRepository repository;

  const UpdateUserProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call(UserProfile profile) async {
    try {
      return await repository.updateUserProfile(profile);
    } catch (e) {
      return Left(ServerFailure('Failed to update user profile: ${e.toString()}'));
    }
  }
}

/// Use case for updating user avatar
class UpdateUserAvatarUseCase {
  final ProfileRepository repository;

  const UpdateUserAvatarUseCase(this.repository);

  Future<Either<Failure, String>> call(File imageFile) async {
    try {
      // Validate file size (max 5MB)
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        return Left(ValidationFailure('Image file too large. Maximum size is 5MB.'));
      }

      // Validate file type
      final fileName = imageFile.path.toLowerCase();
      if (!fileName.endsWith('.jpg') &&
          !fileName.endsWith('.jpeg') &&
          !fileName.endsWith('.png')) {
        return Left(ValidationFailure('Invalid file type. Only JPG and PNG files are allowed.'));
      }

      return await repository.updateUserAvatar(imageFile);
    } catch (e) {
      return Left(ServerFailure('Failed to update user avatar: ${e.toString()}'));
    }
  }
}

/// Use case for deleting user avatar
class DeleteUserAvatarUseCase {
  final ProfileRepository repository;

  const DeleteUserAvatarUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    try {
      return await repository.deleteUserAvatar();
    } catch (e) {
      return Left(ServerFailure('Failed to delete user avatar: ${e.toString()}'));
    }
  }
}

/// Use case for managing user preferences
class GetUserPreferencesUseCase {
  final ProfileRepository repository;

  const GetUserPreferencesUseCase(this.repository);

  Future<Either<Failure, UserPreferences>> call() async {
    try {
      return await repository.getUserPreferences();
    } catch (e) {
      return Left(CacheFailure('Failed to get user preferences: ${e.toString()}'));
    }
  }
}

class SaveUserPreferencesUseCase {
  final ProfileRepository repository;

  const SaveUserPreferencesUseCase(this.repository);

  Future<Either<Failure, void>> call(UserPreferences preferences) async {
    try {
      return await repository.saveUserPreferences(preferences);
    } catch (e) {
      return Left(CacheFailure('Failed to save user preferences: ${e.toString()}'));
    }
  }
}

/// Use case for account management
class ChangePasswordUseCase {
  final ProfileRepository repository;

  const ChangePasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(String currentPassword, String newPassword) async {
    try {
      // Validate new password strength
      if (newPassword.length < 8) {
        return Left(ValidationFailure('Password must be at least 8 characters long.'));
      }

      if (!_hasUppercase(newPassword)) {
        return Left(ValidationFailure('Password must contain at least one uppercase letter.'));
      }

      if (!_hasLowercase(newPassword)) {
        return Left(ValidationFailure('Password must contain at least one lowercase letter.'));
      }

      if (!_hasDigits(newPassword)) {
        return Left(ValidationFailure('Password must contain at least one number.'));
      }

      return await repository.changePassword(currentPassword, newPassword);
    } catch (e) {
      return Left(ServerFailure('Failed to change password: ${e.toString()}'));
    }
  }

  bool _hasUppercase(String password) => password.contains(RegExp(r'[A-Z]'));
  bool _hasLowercase(String password) => password.contains(RegExp(r'[a-z]'));
  bool _hasDigits(String password) => password.contains(RegExp(r'[0-9]'));
}

class DeleteAccountUseCase {
  final ProfileRepository repository;

  const DeleteAccountUseCase(this.repository);

  Future<Either<Failure, void>> call(String password) async {
    try {
      return await repository.deleteAccount(password);
    } catch (e) {
      return Left(ServerFailure('Failed to delete account: ${e.toString()}'));
    }
  }
}

class RequestDataExportUseCase {
  final ProfileRepository repository;

  const RequestDataExportUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    try {
      return await repository.requestDataExport();
    } catch (e) {
      return Left(ServerFailure('Failed to request data export: ${e.toString()}'));
    }
  }
}

/// Use case for app information
class GetAppInfoUseCase {
  final ProfileRepository repository;

  const GetAppInfoUseCase(this.repository);

  Future<Either<Failure, AppInfo>> call() async {
    try {
      return await repository.getAppInfo();
    } catch (e) {
      return Left(CacheFailure('Failed to get app info: ${e.toString()}'));
    }
  }
}

/// Use case for signing out
class SignOutUseCase {
  final ProfileRepository repository;

  const SignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    try {
      return await repository.signOut();
    } catch (e) {
      return Left(ServerFailure('Failed to sign out: ${e.toString()}'));
    }
  }
}