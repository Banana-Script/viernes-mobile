import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user_model.dart';

abstract class SecureStorageService {
  Future<void> storeAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> storeRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> storeUserData(UserModel user);
  Future<UserModel?> getUserData();
  Future<void> clearAllAuthData();
  Future<void> storeUserAvailabilityFlag(bool available);
  Future<bool?> getUserAvailabilityFlag();
}

class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _secureStorage;

  // Storage keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _userAvailabilityKey = 'user_availability';

  SecureStorageServiceImpl({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  @override
  Future<void> storeAuthToken(String token) async {
    await _secureStorage.write(key: _authTokenKey, value: token);
  }

  @override
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _authTokenKey);
  }

  @override
  Future<void> storeRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> storeUserData(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _secureStorage.write(key: _userDataKey, value: userJson);
  }

  @override
  Future<UserModel?> getUserData() async {
    final userJson = await _secureStorage.read(key: _userDataKey);
    if (userJson == null) return null;

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      // If parsing fails, return null and clear corrupted data
      await _secureStorage.delete(key: _userDataKey);
      return null;
    }
  }

  @override
  Future<void> storeUserAvailabilityFlag(bool available) async {
    await _secureStorage.write(
      key: _userAvailabilityKey,
      value: available.toString(),
    );
  }

  @override
  Future<bool?> getUserAvailabilityFlag() async {
    final availabilityString = await _secureStorage.read(key: _userAvailabilityKey);
    if (availabilityString == null) return null;
    return availabilityString.toLowerCase() == 'true';
  }

  @override
  Future<void> clearAllAuthData() async {
    await Future.wait([
      _secureStorage.delete(key: _authTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _userDataKey),
      _secureStorage.delete(key: _userAvailabilityKey),
    ]);
  }
}