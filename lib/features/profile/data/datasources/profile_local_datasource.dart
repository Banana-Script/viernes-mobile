import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/user_profile_model.dart';
import '../../domain/entities/app_info.dart';

/// Local data source for profile-related operations
/// Handles local storage, secure storage, and device information
class ProfileLocalDataSource {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  ProfileLocalDataSource(this._prefs, this._secureStorage);

  // === USER PREFERENCES OPERATIONS ===

  /// Get user preferences from local storage
  Future<UserPreferences> getUserPreferences() async {
    try {
      final prefsJson = _prefs.getString('user_preferences');
      if (prefsJson != null) {
        final prefsMap = json.decode(prefsJson) as Map<String, dynamic>;
        return UserPreferences.fromJson(prefsMap);
      }
      return UserPreferences.defaultPreferences();
    } catch (e) {
      // Return default preferences if there's an error
      return UserPreferences.defaultPreferences();
    }
  }

  /// Save user preferences to local storage
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    try {
      final prefsJson = json.encode(preferences.toJson());
      await _prefs.setString('user_preferences', prefsJson);
    } catch (e) {
      throw Exception('Failed to save user preferences: $e');
    }
  }

  // === USER PROFILE CACHE OPERATIONS ===

  /// Cache user profile data
  Future<void> cacheUserProfile(UserProfileModel profile) async {
    try {
      final profileJson = json.encode(profile.toJson());
      await _secureStorage.write(key: 'cached_user_profile', value: profileJson);
    } catch (e) {
      throw Exception('Failed to cache user profile: $e');
    }
  }

  /// Get cached user profile data
  Future<UserProfileModel?> getCachedUserProfile() async {
    try {
      final profileJson = await _secureStorage.read(key: 'cached_user_profile');
      if (profileJson != null) {
        final profileMap = json.decode(profileJson) as Map<String, dynamic>;
        return UserProfileModel.fromJson(profileMap);
      }
      return null;
    } catch (e) {
      // Return null if there's an error reading the cache
      return null;
    }
  }

  /// Clear cached user profile data
  Future<void> clearCachedUserProfile() async {
    try {
      await _secureStorage.delete(key: 'cached_user_profile');
    } catch (e) {
      throw Exception('Failed to clear cached user profile: $e');
    }
  }

  // === USER AVAILABILITY CACHE ===

  /// Cache user availability status
  Future<void> cacheUserAvailability(bool isAvailable) async {
    try {
      await _prefs.setBool('user_availability', isAvailable);
      await _prefs.setInt('availability_cached_at', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw Exception('Failed to cache user availability: $e');
    }
  }

  /// Get cached user availability status
  /// Returns null if cache is expired (older than 5 minutes)
  Future<bool?> getCachedUserAvailability() async {
    try {
      final cachedAt = _prefs.getInt('availability_cached_at');
      if (cachedAt != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(cachedAt);
        final now = DateTime.now();
        final difference = now.difference(cacheTime);

        // Cache expires after 5 minutes
        if (difference.inMinutes < 5) {
          return _prefs.getBool('user_availability');
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // === APP INFORMATION OPERATIONS ===

  /// Get application information from package info
  Future<AppInfo> getAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      return AppInfo(
        appName: packageInfo.appName,
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        packageName: packageInfo.packageName,
        buildDate: DateTime.now(), // Could be enhanced with actual build date
        supportLinks: const {
          'help': 'https://viernes.app/help',
          'support': 'https://viernes.app/support',
          'contact': 'mailto:support@viernes.app',
          'website': 'https://viernes.app',
        },
        legalLinks: const {
          'terms': 'https://viernes.app/terms',
          'privacy': 'https://viernes.app/privacy',
          'licenses': 'https://viernes.app/licenses',
        },
      );
    } catch (e) {
      // Return default app info if package info fails
      return AppInfo.viernes();
    }
  }

  // === AUTHENTICATION TOKEN MANAGEMENT ===

  /// Store authentication token securely
  Future<void> storeAuthToken(String token) async {
    try {
      await _secureStorage.write(key: 'auth_token', value: token);
    } catch (e) {
      throw Exception('Failed to store auth token: $e');
    }
  }

  /// Get stored authentication token
  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: 'auth_token');
    } catch (e) {
      return null;
    }
  }

  /// Delete stored authentication token
  Future<void> deleteAuthToken() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
    } catch (e) {
      throw Exception('Failed to delete auth token: $e');
    }
  }

  // === CLEANUP OPERATIONS ===

  /// Clear all user data from local storage
  Future<void> clearAllUserData() async {
    try {
      // Clear secure storage
      await _secureStorage.deleteAll();

      // Clear shared preferences (except app-level settings)
      await _prefs.remove('cached_user_profile');
      await _prefs.remove('user_availability');
      await _prefs.remove('availability_cached_at');

      // Note: We don't clear theme and language preferences as they're app-level
    } catch (e) {
      throw Exception('Failed to clear user data: $e');
    }
  }

  // === DEVICE INFORMATION ===

  /// Get device-specific information for debugging
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      return {
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': 'Failed to get device info: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}