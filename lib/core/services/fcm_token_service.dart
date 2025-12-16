import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../utils/logger.dart';

/// FCM Token Service
///
/// Manages FCM token lifecycle:
/// - Token retrieval and refresh
/// - Token registration in Firestore
/// - Token deletion on logout
class FCMTokenService {
  static FCMTokenService? _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collectionName = 'fcm_tokens';

  String? _currentToken;
  String? _currentUserUid;
  int? _currentUserDatabaseId;
  StreamSubscription<String>? _tokenRefreshSubscription;

  FCMTokenService._();

  /// Get the singleton instance
  static FCMTokenService get instance {
    _instance ??= FCMTokenService._();
    return _instance!;
  }

  /// Current FCM token
  String? get currentToken => _currentToken;

  /// Initialize FCM and get token
  Future<void> initialize() async {
    debugPrint('[FCMTokenService] Initializing...');
    AppLogger.info('[FCMTokenService] Initializing...', tag: 'FCM');

    // Request permissions first
    await _requestPermissions();

    // Cancel existing subscription if any (prevents leaks on re-initialization)
    await _tokenRefreshSubscription?.cancel();

    // Listen for token refresh (important: set up BEFORE getting token)
    // On iOS, token comes via this listener after APNs token is ready
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(_handleTokenRefresh);

    // Configure foreground notification presentation (iOS)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get initial token (may fail on iOS if APNs not ready yet)
    await _getTokenWithRetry();

    debugPrint('[FCMTokenService] Initialized');
    AppLogger.info('[FCMTokenService] Initialized', tag: 'FCM');
  }

  /// Get FCM token with retry for iOS APNs timing issues
  Future<void> _getTokenWithRetry() async {
    // On iOS, we may need to wait for APNs token
    if (Platform.isIOS) {
      // Check if APNs token is available
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null) {
        debugPrint('[FCMTokenService] iOS: APNs token not ready, will receive via onTokenRefresh');
        AppLogger.info('[FCMTokenService] iOS: Waiting for APNs token...', tag: 'FCM');

        // Retry after a short delay (APNs registration can take a moment)
        await Future.delayed(const Duration(seconds: 2));
        final retryApns = await _messaging.getAPNSToken();
        if (retryApns == null) {
          debugPrint('[FCMTokenService] iOS: APNs still not ready, token will come via refresh');
          return;
        }
      }
    }

    // Try to get FCM token
    try {
      _currentToken = await _messaging.getToken();
      if (_currentToken != null) {
        debugPrint('[FCMTokenService] Token obtained successfully');
        AppLogger.info('[FCMTokenService] Token obtained', tag: 'FCM');
      }
    } catch (e) {
      debugPrint('[FCMTokenService] Error getting token: $e');
      AppLogger.warning('[FCMTokenService] Token not available yet, will receive via refresh', tag: 'FCM');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('[FCMTokenService] Permission status: ${settings.authorizationStatus}');
      AppLogger.info(
        '[FCMTokenService] Permission status: ${settings.authorizationStatus}',
        tag: 'FCM',
      );
    } catch (e) {
      debugPrint('[FCMTokenService] Error requesting permissions: $e');
      AppLogger.error('[FCMTokenService] Error requesting permissions: $e', tag: 'FCM');
    }
  }

  /// Handle token refresh
  void _handleTokenRefresh(String newToken) {
    debugPrint('[FCMTokenService] Token refreshed');
    AppLogger.info('[FCMTokenService] Token refreshed', tag: 'FCM');

    _currentToken = newToken;

    // Re-register with Firestore if user is logged in
    if (_currentUserUid != null && _currentUserDatabaseId != null) {
      registerToken(
        userUid: _currentUserUid!,
        userDatabaseId: _currentUserDatabaseId!,
      );
    }
  }

  /// Register FCM token in Firestore for the logged-in user
  Future<bool> registerToken({
    required String userUid,
    required int userDatabaseId,
  }) async {
    if (_currentToken == null) {
      debugPrint('[FCMTokenService] No token to register');
      AppLogger.warning('[FCMTokenService] No token to register', tag: 'FCM');
      return false;
    }

    _currentUserUid = userUid;
    _currentUserDatabaseId = userDatabaseId;

    try {
      // Check if token already exists
      final query = await _firestore
          .collection(_collectionName)
          .where('fcm_token', isEqualTo: _currentToken)
          .limit(1)
          .get();

      final data = {
        'user_uid': userUid,
        'user_database_id': userDatabaseId,
        'fcm_token': _currentToken,
        'device_type': Platform.isIOS ? 'ios' : 'android',
        'device_name': _getDeviceName(),
        'is_active': true,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (query.docs.isEmpty) {
        // Create new token document
        data['created_at'] = FieldValue.serverTimestamp();
        await _firestore.collection(_collectionName).add(data);
        debugPrint('[FCMTokenService] Token registered (new document)');
        AppLogger.info('[FCMTokenService] Token registered (new document)', tag: 'FCM');
      } else {
        // Update existing token document
        await query.docs.first.reference.update(data);
        debugPrint('[FCMTokenService] Token registered (updated existing)');
        AppLogger.info('[FCMTokenService] Token registered (updated existing)', tag: 'FCM');
      }

      return true;
    } catch (e) {
      debugPrint('[FCMTokenService] Error registering token: $e');
      AppLogger.error('[FCMTokenService] Error registering token: $e', tag: 'FCM');
      return false;
    }
  }

  /// Unregister token when user logs out (mark as inactive)
  Future<void> unregisterToken() async {
    if (_currentToken == null) {
      debugPrint('[FCMTokenService] No token to unregister');
      return;
    }

    try {
      final query = await _firestore
          .collection(_collectionName)
          .where('fcm_token', isEqualTo: _currentToken)
          .get();

      for (final doc in query.docs) {
        await doc.reference.update({
          'is_active': false,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      debugPrint('[FCMTokenService] Token unregistered');
      AppLogger.info('[FCMTokenService] Token unregistered', tag: 'FCM');
    } catch (e) {
      debugPrint('[FCMTokenService] Error unregistering token: $e');
      AppLogger.error('[FCMTokenService] Error unregistering token: $e', tag: 'FCM');
    }

    _currentUserUid = null;
    _currentUserDatabaseId = null;
  }

  /// Get device name for identification
  String _getDeviceName() {
    try {
      if (Platform.isIOS) {
        return 'iOS Device';
      } else if (Platform.isAndroid) {
        return 'Android Device';
      }
      return 'Unknown Device';
    } catch (e) {
      return 'Unknown Device';
    }
  }

  /// Dispose the service and clean up resources
  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _currentToken = null;
    _currentUserUid = null;
    _currentUserDatabaseId = null;
    _instance = null;
  }
}
