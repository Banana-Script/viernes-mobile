import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_preferences.dart';
import '../models/sse_events.dart';
import '../utils/logger.dart';
import 'organization_sse_service.dart';

/// Notification Service
///
/// Handles local notifications for the app.
/// Listens to SSE events and shows notifications based on user preferences.
class NotificationService {
  static NotificationService? _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  late NotificationPreferencesRepository _prefsRepository;
  NotificationPreferences _preferences = NotificationPreferences.defaultPreferences;

  // Notification IDs (use large gaps to prevent collision with conversationId)
  static const int _messageNotificationId = 1000000;
  static const int _assignmentNotificationId = 2000000;
  static const int _newConversationNotificationId = 3000000;

  // Notification channels (Android)
  static const String _messageChannelId = 'viernes_messages';
  static const String _messageChannelName = 'Messages';
  static const String _messageChannelDescription = 'New message notifications';

  static const String _assignmentChannelId = 'viernes_assignments';
  static const String _assignmentChannelName = 'Assignments';
  static const String _assignmentChannelDescription = 'Agent assignment notifications';

  static const String _conversationChannelId = 'viernes_conversations';
  static const String _conversationChannelName = 'Conversations';
  static const String _conversationChannelDescription = 'New conversation notifications';

  // SSE subscriptions
  final List<VoidCallback> _unsubscribers = [];

  // Callback for notification tap
  void Function(int conversationId)? onNotificationTap;

  // Track currently visible conversation to avoid duplicate notifications
  int? _currentConversationId;

  /// Get current conversation ID (for FCM handler to check)
  int? get currentConversationId => _currentConversationId;

  // Track current user ID for filtering notifications (database_id)
  int? _currentUserId;

  NotificationService._();

  /// Get the singleton instance
  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  /// Current preferences
  NotificationPreferences get preferences => _preferences;

  /// Initialize the notification service
  Future<void> initialize(SharedPreferences prefs) async {
    debugPrint('[NotificationService] Initializing...');
    AppLogger.info('[NotificationService] Initializing...', tag: 'Notifications');

    _prefsRepository = NotificationPreferencesRepository(prefs);
    _preferences = _prefsRepository.load();

    // Initialize the notifications plugin
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels (Android)
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    // Request permissions
    if (Platform.isIOS) {
      await _requestIOSPermissions();
    } else if (Platform.isAndroid) {
      await _requestAndroidPermissions();
    }

    debugPrint('[NotificationService] Initialized, preferences: $_preferences');
    AppLogger.info('[NotificationService] Initialized', tag: 'Notifications');
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Messages channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _messageChannelId,
        _messageChannelName,
        description: _messageChannelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );

    // Assignments channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _assignmentChannelId,
        _assignmentChannelName,
        description: _assignmentChannelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );

    // New conversations channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _conversationChannelId,
        _conversationChannelName,
        description: _conversationChannelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );
  }

  /// Request iOS notification permissions
  Future<void> _requestIOSPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Request Android notification permissions (required for Android 13+)
  Future<void> _requestAndroidPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    final granted = await androidPlugin.requestNotificationsPermission();
    debugPrint('[NotificationService] Android notification permission granted: $granted');
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    AppLogger.info(
      '[NotificationService] Notification tapped: ${response.payload}',
      tag: 'Notifications',
    );

    if (response.payload != null) {
      final conversationId = int.tryParse(response.payload!);
      if (conversationId != null) {
        onNotificationTap?.call(conversationId);
      }
    }
  }

  /// Start listening to SSE events
  void startListening() {
    debugPrint('[NotificationService] startListening called, enabled: ${_preferences.enabled}');

    if (!_preferences.enabled) {
      debugPrint('[NotificationService] Notifications disabled, not listening');
      AppLogger.info(
        '[NotificationService] Notifications disabled, not listening',
        tag: 'Notifications',
      );
      return;
    }

    final sseService = OrganizationSSEService.instance;

    // Subscribe to agent assigned events
    if (_preferences.showAssignmentNotifications) {
      final unsub = sseService.subscribe(
        SSEEventType.agentAssigned,
        _handleAgentAssigned,
      );
      _unsubscribers.add(unsub);
    }

    // Subscribe to new conversation events
    if (_preferences.showNewConversationNotifications) {
      final unsub = sseService.subscribe(
        SSEEventType.newConversation,
        _handleNewConversation,
      );
      _unsubscribers.add(unsub);
    }

    // Subscribe to user message events
    if (_preferences.showMessageNotifications) {
      final unsub = sseService.subscribe(
        SSEEventType.userMessage,
        _handleUserMessage,
      );
      _unsubscribers.add(unsub);
    }

    debugPrint('[NotificationService] Started listening to SSE events');
    AppLogger.info(
      '[NotificationService] Started listening to SSE events',
      tag: 'Notifications',
    );
  }

  /// Stop listening to SSE events
  void stopListening() {
    for (final unsub in _unsubscribers) {
      unsub();
    }
    _unsubscribers.clear();

    AppLogger.info(
      '[NotificationService] Stopped listening to SSE events',
      tag: 'Notifications',
    );
  }

  /// Set the current conversation (to avoid showing notifications for visible chat)
  void setCurrentConversation(int? conversationId) {
    _currentConversationId = conversationId;
  }

  /// Set the current user ID (database_id) for filtering message notifications
  void setCurrentUserId(int? userId) {
    _currentUserId = userId;
    debugPrint('[NotificationService] Current user ID set to: $userId');
  }

  /// Handle agent assigned event
  void _handleAgentAssigned(SSEEvent event) {
    if (event is! SSEAgentAssignedEvent) return;

    // Don't show if viewing this conversation
    if (event.conversationId == _currentConversationId) return;

    showAssignmentNotification(
      conversationId: event.conversationId ?? 0,
      agentName: event.agentName,
    );
  }

  /// Handle new conversation event
  void _handleNewConversation(SSEEvent event) {
    if (event is! SSENewConversationEvent) return;

    showNewConversationNotification(
      conversationId: event.conversationId ?? 0,
      userName: event.userName,
    );
  }

  /// Handle user message event
  void _handleUserMessage(SSEEvent event) {
    debugPrint('[NotificationService] _handleUserMessage called');

    if (event is! SSEUserMessageEvent) return;

    final conversationId = event.conversationId;
    debugPrint('[NotificationService] User message for conversation $conversationId, agent_id: ${event.agentId}, current user: $_currentUserId');

    // Only show notification if the message is for the current agent (assigned to them)
    // This mirrors the web frontend logic in useMessageSound.ts
    if (event.agentId != _currentUserId) {
      debugPrint('[NotificationService] Skipping notification - message not for current user (agent_id: ${event.agentId} != $_currentUserId)');
      return;
    }

    // Don't show if viewing this conversation
    if (conversationId == _currentConversationId) {
      debugPrint('[NotificationService] Skipping notification - viewing this conversation');
      return;
    }

    debugPrint('[NotificationService] Showing notification for message: ${event.message.substring(0, event.message.length > 30 ? 30 : event.message.length)}...');
    showMessageNotification(
      conversationId: conversationId ?? 0,
      message: event.message,
      senderName: 'Customer', // Could be enriched with actual name
    );
  }

  /// Show a message notification
  Future<void> showMessageNotification({
    required int conversationId,
    required String message,
    required String senderName,
  }) async {
    debugPrint('[NotificationService] showMessageNotification called');

    if (!_preferences.enabled || !_preferences.showMessageNotifications) {
      debugPrint('[NotificationService] Notifications disabled in preferences');
      return;
    }

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _messageChannelId,
        _messageChannelName,
        channelDescription: _messageChannelDescription,
        importance: Importance.max,
        priority: Priority.max,
        playSound: _preferences.soundEnabled,
        enableVibration: _preferences.vibrationEnabled,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.message,
        visibility: NotificationVisibility.public,
        ticker: 'New message',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: _preferences.soundEnabled,
      ),
    );

    try {
      debugPrint('[NotificationService] Calling _notifications.show...');
      await _notifications.show(
        _messageNotificationId + conversationId,
        'New message from $senderName',
        message.length > 100 ? '${message.substring(0, 100)}...' : message,
        notificationDetails,
        payload: conversationId.toString(),
      );
      debugPrint('[NotificationService] Notification shown successfully');
    } catch (e, stackTrace) {
      debugPrint('[NotificationService] Error showing notification: $e');
      debugPrint('[NotificationService] Stack trace: $stackTrace');
    }

    AppLogger.debug(
      '[NotificationService] Showed message notification for conversation $conversationId',
      tag: 'Notifications',
    );
  }

  /// Show an assignment notification
  Future<void> showAssignmentNotification({
    required int conversationId,
    required String agentName,
  }) async {
    if (!_preferences.enabled || !_preferences.showAssignmentNotifications) {
      return;
    }

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _assignmentChannelId,
        _assignmentChannelName,
        channelDescription: _assignmentChannelDescription,
        importance: Importance.max,
        priority: Priority.max,
        playSound: _preferences.soundEnabled,
        enableVibration: _preferences.vibrationEnabled,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.message,
        visibility: NotificationVisibility.public,
        ticker: 'New assignment',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: _preferences.soundEnabled,
      ),
    );

    await _notifications.show(
      _assignmentNotificationId + conversationId,
      'New assignment',
      'You have been assigned to a conversation',
      notificationDetails,
      payload: conversationId.toString(),
    );

    AppLogger.debug(
      '[NotificationService] Showed assignment notification for conversation $conversationId',
      tag: 'Notifications',
    );
  }

  /// Show a new conversation notification
  Future<void> showNewConversationNotification({
    required int conversationId,
    required String userName,
  }) async {
    if (!_preferences.enabled ||
        !_preferences.showNewConversationNotifications) {
      return;
    }

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _conversationChannelId,
        _conversationChannelName,
        channelDescription: _conversationChannelDescription,
        importance: Importance.max,
        priority: Priority.max,
        playSound: _preferences.soundEnabled,
        enableVibration: _preferences.vibrationEnabled,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.message,
        visibility: NotificationVisibility.public,
        ticker: 'New conversation',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: _preferences.soundEnabled,
      ),
    );

    await _notifications.show(
      _newConversationNotificationId + conversationId,
      'New conversation',
      userName.isNotEmpty ? 'New conversation from $userName' : 'New conversation started',
      notificationDetails,
      payload: conversationId.toString(),
    );

    AppLogger.debug(
      '[NotificationService] Showed new conversation notification for $conversationId',
      tag: 'Notifications',
    );
  }

  /// Update notification preferences
  Future<void> updatePreferences(NotificationPreferences newPreferences) async {
    _preferences = newPreferences;
    await _prefsRepository.save(newPreferences);

    // Restart listening with new preferences
    stopListening();
    if (newPreferences.enabled) {
      startListening();
    }

    AppLogger.info(
      '[NotificationService] Preferences updated: $newPreferences',
      tag: 'Notifications',
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel notification for a specific conversation
  Future<void> cancelForConversation(int conversationId) async {
    await _notifications.cancel(_messageNotificationId + conversationId);
    await _notifications.cancel(_assignmentNotificationId + conversationId);
    await _notifications.cancel(_newConversationNotificationId + conversationId);
  }

  /// Dispose the service
  Future<void> dispose() async {
    stopListening();
    await cancelAll();
    _instance = null;
  }
}
