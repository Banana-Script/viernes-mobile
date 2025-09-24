import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_result_model.dart';

abstract class SecureStorageService {
  Future<void> storeAuthResult(AuthResultModel authResult);

  Future<AuthResultModel?> getAuthResult();

  Future<void> storeAccessToken(String token);

  Future<String?> getAccessToken();

  Future<void> storeRefreshToken(String token);

  Future<String?> getRefreshToken();

  Future<void> storeBiometricEnabled(bool enabled);

  Future<bool> getBiometricEnabled();

  Future<void> clearAuthData();

  Future<void> clearAll();
}

class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _authResultKey = 'auth_result';
  static const String _biometricEnabledKey = 'biometric_enabled';

  SecureStorageServiceImpl({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
                resetOnError: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
              lOptions: LinuxOptions(),
              wOptions: WindowsOptions(),
              mOptions: MacOsOptions(),
            );

  @override
  Future<void> storeAuthResult(AuthResultModel authResult) async {
    try {
      final json = jsonEncode(authResult.toJson());
      await _secureStorage.write(key: _authResultKey, value: json);
    } catch (e) {
      throw StorageException(message: 'Failed to store auth result: ${e.toString()}');
    }
  }

  @override
  Future<AuthResultModel?> getAuthResult() async {
    try {
      final json = await _secureStorage.read(key: _authResultKey);
      if (json == null) return null;

      final Map<String, dynamic> data = jsonDecode(json);
      return AuthResultModel.fromJson(data);
    } catch (e) {
      throw StorageException(message: 'Failed to retrieve auth result: ${e.toString()}');
    }
  }

  @override
  Future<void> storeAccessToken(String token) async {
    try {
      await _secureStorage.write(key: _accessTokenKey, value: token);
    } catch (e) {
      throw StorageException(message: 'Failed to store access token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: _accessTokenKey);
    } catch (e) {
      throw StorageException(message: 'Failed to retrieve access token: ${e.toString()}');
    }
  }

  @override
  Future<void> storeRefreshToken(String token) async {
    try {
      await _secureStorage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      throw StorageException(message: 'Failed to store refresh token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      throw StorageException(message: 'Failed to retrieve refresh token: ${e.toString()}');
    }
  }

  @override
  Future<void> storeBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(key: _biometricEnabledKey, value: enabled.toString());
    } catch (e) {
      throw StorageException(message: 'Failed to store biometric setting: ${e.toString()}');
    }
  }

  @override
  Future<bool> getBiometricEnabled() async {
    try {
      final value = await _secureStorage.read(key: _biometricEnabledKey);
      return value?.toLowerCase() == 'true';
    } catch (e) {
      throw StorageException(message: 'Failed to retrieve biometric setting: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _authResultKey),
      ]);
    } catch (e) {
      throw StorageException(message: 'Failed to clear auth data: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw StorageException(message: 'Failed to clear all data: ${e.toString()}');
    }
  }
}