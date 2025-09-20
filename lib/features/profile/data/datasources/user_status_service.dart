import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/network/dio_client.dart';

/// Service for managing user availability status
/// Matches the web app UserStatusService functionality
class UserStatusService {
  final Dio _dio;
  final FirebaseAuth _auth;

  UserStatusService()
      : _dio = DioClient.instance.dio,
        _auth = FirebaseAuth.instance;

  /// Get current user availability status
  /// Matches: GET /organization_users/read/{databaseId}
  Future<bool> getUserStatus(int databaseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get Firebase ID token for authentication
      final idToken = await user.getIdToken();

      final response = await _dio.get(
        '/organization_users/read/$databaseId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      // API returns just a boolean, so we need to handle the response properly
      if (response.data is bool) {
        return response.data as bool;
      } else if (response.data is Map<String, dynamic>) {
        return response.data['available'] as bool? ?? false;
      } else {
        // If response.data is a string or other type, try to parse it
        return response.data.toString().toLowerCase() == 'true';
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch user status: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch user status: $e');
    }
  }

  /// Toggle user availability status
  /// Matches: POST /organization_users/change_agent_availability/{databaseId}/{available}
  Future<void> toggleUserAvailability(int databaseId, bool available) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get Firebase ID token for authentication
      final idToken = await user.getIdToken();

      await _dio.post(
        '/organization_users/change_agent_availability/$databaseId/$available',
        data: {}, // Empty body as per the web app implementation
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden: You do not have permission to change availability');
      } else if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to toggle user availability: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to toggle user availability: $e');
    }
  }

  /// Get user profile with availability status
  /// This extends the basic status check to include full user profile data
  Future<Map<String, dynamic>> getUserProfile(int databaseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get Firebase ID token for authentication
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

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to fetch user profile: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Update user profile information
  Future<Map<String, dynamic>> updateUserProfile(int databaseId, Map<String, dynamic> profileData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get Firebase ID token for authentication
      final idToken = await user.getIdToken();

      final response = await _dio.put(
        '/organization_users/$databaseId',
        data: profileData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to update user profile: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Get organization information for the user
  Future<Map<String, dynamic>> getUserOrganization() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get Firebase ID token for authentication
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
      throw Exception('Failed to fetch organization: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch organization: $e');
    }
  }
}