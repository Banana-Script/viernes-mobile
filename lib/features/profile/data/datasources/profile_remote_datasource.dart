import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_profile_model.dart';

/// Remote data source for profile-related operations
/// Handles API calls to the Viernes backend
class ProfileRemoteDataSource {
  final Dio _dio;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  ProfileRemoteDataSource()
      : _dio = DioClient.instance.dio,
        _auth = FirebaseAuth.instance,
        _storage = FirebaseStorage.instance;

  /// Get user profile from the API
  Future<UserProfileModel> getUserProfile(int databaseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();

      final response = await _dio.get(
        '/organization_users/$databaseId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      return UserProfileModel.fromApiResponse(response.data, user);
    } on DioException catch (e) {
      throw Exception('Failed to get user profile: ${e.message}');
    }
  }

  /// Update user profile via API
  Future<UserProfileModel> updateUserProfile(int databaseId, Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();

      final response = await _dio.put(
        '/organization_users/$databaseId',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      return UserProfileModel.fromApiResponse(response.data, user);
    } on DioException catch (e) {
      throw Exception('Failed to update user profile: ${e.message}');
    }
  }

  /// Upload avatar to Firebase Storage
  Future<String> uploadAvatar(File file, String userId) async {
    try {
      final fileName = 'profile_images/$userId.jpg';
      final ref = _storage.ref().child(fileName);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  /// Delete avatar from Firebase Storage
  Future<void> deleteAvatar(String userId) async {
    try {
      final fileName = 'profile_images/$userId.jpg';
      final ref = _storage.ref().child(fileName);
      await ref.delete();
    } catch (e) {
      // Ignore if file doesn't exist
    }
  }

  /// Get organization information
  Future<Map<String, dynamic>> getOrganization() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();

      final response = await _dio.get(
        '/organization',
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to get organization: ${e.message}');
    }
  }

  /// Request data export
  Future<void> requestDataExport() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();

      await _dio.post(
        '/users/export-data',
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception('Failed to request data export: ${e.message}');
    }
  }

  /// Check for app updates
  Future<Map<String, dynamic>> checkForUpdates() async {
    try {
      final response = await _dio.get('/app/version');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to check for updates: ${e.message}');
    }
  }
}