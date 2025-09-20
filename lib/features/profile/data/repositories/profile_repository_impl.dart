import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/app_info.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/user_status_service.dart';
import '../datasources/profile_local_datasource.dart';
import '../models/user_profile_model.dart';
import '../../../../core/errors/failures.dart';

/// Implementation of ProfileRepository
/// Coordinates between remote API, Firebase, and local storage
class ProfileRepositoryImpl implements ProfileRepository {
  final UserStatusService _userStatusService;
  final ProfileLocalDataSource _localDataSource;
  final FirebaseAuth _firebaseAuth;
  final FirebaseStorage _firebaseStorage;

  ProfileRepositoryImpl(
    this._userStatusService,
    this._localDataSource,
    this._firebaseAuth,
    this._firebaseStorage,
  );

  // === USER PROFILE OPERATIONS ===

  @override
  Future<Either<Failure, UserProfile>> getCurrentUserProfile() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return Left(AuthenticationFailure('User not authenticated'));
      }

      // Try to get cached profile first
      final cachedProfile = await _localDataSource.getCachedUserProfile();
      if (cachedProfile != null) {
        // Merge with current Firebase user data
        final mergedProfile = cachedProfile.mergeWithFirebaseUser(firebaseUser);
        return Right(mergedProfile);
      }

      // If no cache or cache is stale, fetch from API
      if (cachedProfile?.databaseId != null) {
        try {
          final apiResponse = await _userStatusService.getUserProfile(cachedProfile!.databaseId!);
          final profile = UserProfileModel.fromApiResponse(apiResponse, firebaseUser);

          // Cache the new profile
          await _localDataSource.cacheUserProfile(profile);

          return Right(profile);
        } catch (e) {
          // If API fails, return Firebase user data only
          final firebaseProfile = UserProfileModel.fromFirebaseUser(firebaseUser);
          return Right(firebaseProfile);
        }
      }

      // Fallback to Firebase user data only
      final firebaseProfile = UserProfileModel.fromFirebaseUser(firebaseUser);
      return Right(firebaseProfile);

    } catch (e) {
      return Left(ServerFailure('Failed to get user profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return Left(AuthenticationFailure('User not authenticated'));
      }

      // Update Firebase profile
      if (profile.displayName != firebaseUser.displayName) {
        await firebaseUser.updateDisplayName(profile.displayName);
      }

      // Update backend profile if we have database ID
      if (profile.databaseId != null) {
        try {
          final updateData = {
            'fullname': profile.fullName,
            'phone': profile.phoneNumber,
          };

          final apiResponse = await _userStatusService.updateUserProfile(
            profile.databaseId!,
            updateData,
          );

          final updatedProfile = UserProfileModel.fromApiResponse(apiResponse, firebaseUser);

          // Cache the updated profile
          await _localDataSource.cacheUserProfile(updatedProfile);

          return Right(updatedProfile);
        } catch (e) {
          // If API update fails, return the Firebase-updated profile
          final profileModel = UserProfileModel.fromDomain(profile);
          return Right(profileModel.mergeWithFirebaseUser(firebaseUser));
        }
      }

      // Return updated profile with Firebase data
      final profileModel = UserProfileModel.fromDomain(profile);
      return Right(profileModel.mergeWithFirebaseUser(firebaseUser));

    } catch (e) {
      return Left(ServerFailure('Failed to update user profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> updateUserAvatar(File imageFile) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return Left(AuthenticationFailure('User not authenticated'));
      }

      // Upload to Firebase Storage
      final fileName = 'profile_images/${firebaseUser.uid}.jpg';
      final storageRef = _firebaseStorage.ref().child(fileName);

      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update Firebase profile with new photo URL
      await firebaseUser.updatePhotoURL(downloadUrl);

      // Update cached profile
      final cachedProfile = await _localDataSource.getCachedUserProfile();
      if (cachedProfile != null) {
        final updatedProfile = UserProfileModel(
          id: cachedProfile.id,
          firebaseUid: cachedProfile.firebaseUid,
          databaseId: cachedProfile.databaseId,
          email: cachedProfile.email,
          displayName: cachedProfile.displayName,
          fullName: cachedProfile.fullName,
          photoURL: downloadUrl,
          phoneNumber: cachedProfile.phoneNumber,
          isEmailVerified: cachedProfile.isEmailVerified,
          isAvailable: cachedProfile.isAvailable,
          createdAt: cachedProfile.createdAt,
          lastSeen: cachedProfile.lastSeen,
          organization: cachedProfile.organization,
          role: cachedProfile.role,
          status: cachedProfile.status,
        );
        await _localDataSource.cacheUserProfile(updatedProfile);
      }

      return Right(downloadUrl);

    } catch (e) {
      return Left(ServerFailure('Failed to update user avatar: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserAvatar() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return Left(AuthenticationFailure('User not authenticated'));
      }

      // Delete from Firebase Storage
      try {
        final fileName = 'profile_images/${firebaseUser.uid}.jpg';
        final storageRef = _firebaseStorage.ref().child(fileName);
        await storageRef.delete();
      } catch (e) {
        // Ignore if file doesn't exist
      }

      // Update Firebase profile to remove photo URL
      await firebaseUser.updatePhotoURL(null);

      // Update cached profile
      final cachedProfile = await _localDataSource.getCachedUserProfile();
      if (cachedProfile != null) {
        final updatedProfile = UserProfileModel(
          id: cachedProfile.id,
          firebaseUid: cachedProfile.firebaseUid,
          databaseId: cachedProfile.databaseId,
          email: cachedProfile.email,
          displayName: cachedProfile.displayName,
          fullName: cachedProfile.fullName,
          photoURL: null,
          phoneNumber: cachedProfile.phoneNumber,
          isEmailVerified: cachedProfile.isEmailVerified,
          isAvailable: cachedProfile.isAvailable,
          createdAt: cachedProfile.createdAt,
          lastSeen: cachedProfile.lastSeen,
          organization: cachedProfile.organization,
          role: cachedProfile.role,
          status: cachedProfile.status,
        );
        await _localDataSource.cacheUserProfile(updatedProfile);
      }

      return const Right(null);

    } catch (e) {
      return Left(ServerFailure('Failed to delete user avatar: ${e.toString()}'));
    }
  }

  // === USER AVAILABILITY OPERATIONS ===

  @override
  Future<Either<Failure, bool>> getUserAvailabilityStatus() async {
    try {
      // Try cache first
      final cachedAvailability = await _localDataSource.getCachedUserAvailability();
      if (cachedAvailability != null) {
        return Right(cachedAvailability);
      }

      // Get from profile if available
      final profileResult = await getCurrentUserProfile();
      return profileResult.fold(
        (failure) => Left(failure),
        (profile) async {
          if (profile.databaseId != null) {
            try {
              final availability = await _userStatusService.getUserStatus(profile.databaseId!);

              // Cache the result
              await _localDataSource.cacheUserAvailability(availability);

              return Right(availability);
            } catch (e) {
              // Fallback to profile availability
              return Right(profile.isAvailable);
            }
          } else {
            return Right(profile.isAvailable);
          }
        },
      );

    } catch (e) {
      return Left(ServerFailure('Failed to get user availability: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleUserAvailability(bool isAvailable) async {
    try {
      final profileResult = await getCurrentUserProfile();

      return profileResult.fold(
        (failure) => Left(failure),
        (profile) async {
          if (profile.databaseId != null) {
            try {
              // Update availability via API
              await _userStatusService.toggleUserAvailability(profile.databaseId!, isAvailable);

              // Cache the new status
              await _localDataSource.cacheUserAvailability(isAvailable);

              // Update cached profile
              if (profile is UserProfileModel) {
                final updatedProfile = profile.updateAvailability(isAvailable);
                await _localDataSource.cacheUserProfile(updatedProfile);
              }

              return Right(isAvailable);
            } catch (e) {
              return Left(ServerFailure('Failed to toggle availability: ${e.toString()}'));
            }
          } else {
            return Left(ValidationFailure('User database ID not found'));
          }
        },
      );

    } catch (e) {
      return Left(ServerFailure('Failed to toggle user availability: ${e.toString()}'));
    }
  }

  // === USER PREFERENCES OPERATIONS ===

  @override
  Future<Either<Failure, UserPreferences>> getUserPreferences() async {
    try {
      final preferences = await _localDataSource.getUserPreferences();
      return Right(preferences);
    } catch (e) {
      return Left(CacheFailure('Failed to get user preferences: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUserPreferences(UserPreferences preferences) async {
    try {
      await _localDataSource.saveUserPreferences(preferences);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save user preferences: ${e.toString()}'));
    }
  }

  // === ACCOUNT MANAGEMENT OPERATIONS ===

  @override
  Future<Either<Failure, void>> requestPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure('Failed to send password reset email: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user?.email == null) {
        return Left(AuthenticationFailure('User not authenticated'));
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure('Failed to change password: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user?.email == null) {
        return Left(AuthenticationFailure('User not authenticated'));
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Clear local data first
      await _localDataSource.clearAllUserData();

      // Delete Firebase user account
      await user.delete();

      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure('Failed to delete account: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> requestDataExport() async {
    try {
      // This would typically involve calling a backend endpoint
      // For now, we'll return a not implemented error
      return Left(ServerFailure('Data export functionality not yet implemented'));
    } catch (e) {
      return Left(ServerFailure('Failed to request data export: ${e.toString()}'));
    }
  }

  // === APP INFORMATION OPERATIONS ===

  @override
  Future<Either<Failure, AppInfo>> getAppInfo() async {
    try {
      final appInfo = await _localDataSource.getAppInfo();
      return Right(appInfo);
    } catch (e) {
      return Left(CacheFailure('Failed to get app info: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkForUpdates() async {
    try {
      // This would typically involve checking app store APIs
      // For now, we'll return false (no updates available)
      return const Right(false);
    } catch (e) {
      return Left(ServerFailure('Failed to check for updates: ${e.toString()}'));
    }
  }

  // === AUTHENTICATION OPERATIONS ===

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // Clear local data
      await _localDataSource.clearAllUserData();

      // Sign out from Firebase
      await _firebaseAuth.signOut();

      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure('Failed to sign out: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> refreshAuthToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Left(AuthenticationFailure('User not authenticated'));
      }

      // Force refresh the ID token
      await user.getIdToken(true);

      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure('Failed to refresh auth token: ${e.toString()}'));
    }
  }
}