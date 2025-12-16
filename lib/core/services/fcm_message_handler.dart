import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';
import 'notification_service.dart';

/// Top-level function for background message handling.
/// Must be a top-level function (not a class method).
/// Runs in a separate isolate, so Firebase and services must be initialized.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase in background isolate
  await Firebase.initializeApp();

  debugPrint('[FCM Background] Message received: ${message.messageId}');

  // Initialize NotificationService for background (required for showing notifications)
  try {
    final prefs = await SharedPreferences.getInstance();
    await NotificationService.instance.initialize(prefs);
  } catch (e) {
    debugPrint('[FCM Background] Error initializing NotificationService: $e');
  }

  // Handle the message - show notification via local notifications
  await FCMMessageHandler.handleMessage(message, isBackground: true);
}

/// FCM Message Handler
///
/// Processes incoming FCM messages and displays appropriate notifications.
/// Works with NotificationService for consistent notification display.
class FCMMessageHandler {
  /// Callback for notification tap - set this to navigate to conversation
  static void Function(int conversationId)? onNotificationTap;

  /// Initialize message handlers
  static void initialize() {
    debugPrint('[FCMMessageHandler] Initializing...');
    AppLogger.info('[FCMMessageHandler] Initializing...', tag: 'FCM');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check for initial message (app opened from terminated state)
    _checkInitialMessage();

    debugPrint('[FCMMessageHandler] Initialized');
    AppLogger.info('[FCMMessageHandler] Initialized', tag: 'FCM');
  }

  /// Handle foreground message
  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM Foreground] Message received: ${message.messageId}');
    AppLogger.info('[FCM Foreground] Message received: ${message.messageId}', tag: 'FCM');

    handleMessage(message, isBackground: false);
  }

  /// Handle notification tap (app was in background or terminated)
  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[FCM Tap] Notification tapped: ${message.messageId}');
    AppLogger.info('[FCM Tap] Notification tapped: ${message.messageId}', tag: 'FCM');

    final conversationId = _extractConversationId(message);
    if (conversationId != null && onNotificationTap != null) {
      onNotificationTap!(conversationId);
    }
  }

  /// Check for initial message (app opened from terminated state via notification)
  static Future<void> _checkInitialMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM Initial] App opened from notification');
      AppLogger.info('[FCM Initial] App opened from notification', tag: 'FCM');

      _handleNotificationTap(initialMessage);
    }
  }

  /// Handle incoming FCM message
  static Future<void> handleMessage(
    RemoteMessage message, {
    required bool isBackground,
  }) async {
    final data = message.data;
    final notificationType = data['type'];
    final conversationId = _extractConversationId(message);

    debugPrint('[FCM] Processing message - type: $notificationType, conversationId: $conversationId, isBackground: $isBackground');

    // Skip if viewing this conversation (foreground only)
    if (!isBackground && conversationId != null) {
      final currentConversation = NotificationService.instance.currentConversationId;
      if (currentConversation == conversationId) {
        debugPrint('[FCM] Skipping notification - viewing this conversation');
        AppLogger.debug('[FCM] Skipping notification - viewing conversation', tag: 'FCM');
        return;
      }
    }

    switch (notificationType) {
      case 'message':
        await NotificationService.instance.showMessageNotification(
          conversationId: conversationId ?? 0,
          message: data['message'] ?? message.notification?.body ?? '',
          senderName: data['sender_name'] ?? 'Customer',
        );
        break;

      case 'assignment':
        await NotificationService.instance.showAssignmentNotification(
          conversationId: conversationId ?? 0,
          agentName: data['agent_name'] ?? '',
        );
        break;

      case 'new_conversation':
        await NotificationService.instance.showNewConversationNotification(
          conversationId: conversationId ?? 0,
          userName: data['user_name'] ?? '',
        );
        break;

      default:
        // Fall back to showing notification from message payload
        if (message.notification != null) {
          debugPrint('[FCM] Unknown type, using notification payload');
          await NotificationService.instance.showMessageNotification(
            conversationId: conversationId ?? 0,
            message: message.notification!.body ?? '',
            senderName: message.notification!.title ?? 'Notification',
          );
        }
    }
  }

  /// Extract conversation ID from message data
  static int? _extractConversationId(RemoteMessage message) {
    final idString = message.data['conversation_id'];
    if (idString != null) {
      return int.tryParse(idString.toString());
    }
    return null;
  }
}
