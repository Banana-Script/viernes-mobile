import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Notification Preferences Model
///
/// Stores user preferences for notifications.
/// Persisted in SharedPreferences.
class NotificationPreferences {
  /// Whether notifications are enabled
  final bool enabled;

  /// Whether sound is enabled for notifications
  final bool soundEnabled;

  /// Whether vibration is enabled for notifications
  final bool vibrationEnabled;

  /// Whether to show notifications for new messages
  final bool showMessageNotifications;

  /// Whether to show notifications for new assignments
  final bool showAssignmentNotifications;

  /// Whether to show notifications for new conversations
  final bool showNewConversationNotifications;

  const NotificationPreferences({
    this.enabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.showMessageNotifications = true,
    this.showAssignmentNotifications = true,
    this.showNewConversationNotifications = false, // Off by default
  });

  /// Default preferences
  static const NotificationPreferences defaultPreferences =
      NotificationPreferences();

  /// Create from JSON
  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      enabled: json['enabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      showMessageNotifications:
          json['showMessageNotifications'] as bool? ?? true,
      showAssignmentNotifications:
          json['showAssignmentNotifications'] as bool? ?? true,
      showNewConversationNotifications:
          json['showNewConversationNotifications'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'showMessageNotifications': showMessageNotifications,
      'showAssignmentNotifications': showAssignmentNotifications,
      'showNewConversationNotifications': showNewConversationNotifications,
    };
  }

  /// Copy with new values
  NotificationPreferences copyWith({
    bool? enabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showMessageNotifications,
    bool? showAssignmentNotifications,
    bool? showNewConversationNotifications,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showMessageNotifications:
          showMessageNotifications ?? this.showMessageNotifications,
      showAssignmentNotifications:
          showAssignmentNotifications ?? this.showAssignmentNotifications,
      showNewConversationNotifications: showNewConversationNotifications ??
          this.showNewConversationNotifications,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationPreferences &&
        other.enabled == enabled &&
        other.soundEnabled == soundEnabled &&
        other.vibrationEnabled == vibrationEnabled &&
        other.showMessageNotifications == showMessageNotifications &&
        other.showAssignmentNotifications == showAssignmentNotifications &&
        other.showNewConversationNotifications ==
            showNewConversationNotifications;
  }

  @override
  int get hashCode {
    return Object.hash(
      enabled,
      soundEnabled,
      vibrationEnabled,
      showMessageNotifications,
      showAssignmentNotifications,
      showNewConversationNotifications,
    );
  }

  @override
  String toString() {
    return 'NotificationPreferences(enabled: $enabled, sound: $soundEnabled, vibration: $vibrationEnabled)';
  }
}

/// Notification Preferences Repository
///
/// Handles persistence of notification preferences using SharedPreferences.
class NotificationPreferencesRepository {
  static const String _key = 'notification_preferences';

  final SharedPreferences _prefs;

  NotificationPreferencesRepository(this._prefs);

  /// Load preferences from storage
  NotificationPreferences load() {
    final jsonString = _prefs.getString(_key);
    if (jsonString == null) {
      return NotificationPreferences.defaultPreferences;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return NotificationPreferences.fromJson(json);
    } catch (e) {
      return NotificationPreferences.defaultPreferences;
    }
  }

  /// Save preferences to storage
  Future<bool> save(NotificationPreferences preferences) async {
    final jsonString = jsonEncode(preferences.toJson());
    return _prefs.setString(_key, jsonString);
  }

  /// Clear preferences
  Future<bool> clear() async {
    return _prefs.remove(_key);
  }
}
