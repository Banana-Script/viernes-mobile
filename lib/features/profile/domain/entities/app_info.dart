import 'package:equatable/equatable.dart';

/// Application information entity for the profile screen
class AppInfo extends Equatable {
  final String appName;
  final String version;
  final String buildNumber;
  final String packageName;
  final DateTime? buildDate;
  final Map<String, String> supportLinks;
  final Map<String, String> legalLinks;

  const AppInfo({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.packageName,
    this.buildDate,
    required this.supportLinks,
    required this.legalLinks,
  });

  /// Default app info for Viernes
  factory AppInfo.viernes() {
    return const AppInfo(
      appName: 'Viernes',
      version: '1.0.0',
      buildNumber: '1',
      packageName: 'com.viernes.mobile',
      supportLinks: {
        'help': 'https://viernes.app/help',
        'support': 'https://viernes.app/support',
        'contact': 'mailto:support@viernes.app',
        'website': 'https://viernes.app',
      },
      legalLinks: {
        'terms': 'https://viernes.app/terms',
        'privacy': 'https://viernes.app/privacy',
        'licenses': 'https://viernes.app/licenses',
      },
    );
  }

  AppInfo copyWith({
    String? appName,
    String? version,
    String? buildNumber,
    String? packageName,
    DateTime? buildDate,
    Map<String, String>? supportLinks,
    Map<String, String>? legalLinks,
  }) {
    return AppInfo(
      appName: appName ?? this.appName,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      packageName: packageName ?? this.packageName,
      buildDate: buildDate ?? this.buildDate,
      supportLinks: supportLinks ?? this.supportLinks,
      legalLinks: legalLinks ?? this.legalLinks,
    );
  }

  /// Get formatted version string (e.g., "1.0.0 (1)")
  String get formattedVersion => '$version ($buildNumber)';

  @override
  List<Object?> get props => [
        appName,
        version,
        buildNumber,
        packageName,
        buildDate,
        supportLinks,
        legalLinks,
      ];
}

/// User preferences entity for profile settings
class UserPreferences extends Equatable {
  final String themeMode; // 'light', 'dark', 'system'
  final String language; // 'en', 'es'
  final bool notificationsEnabled;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String timezone;

  const UserPreferences({
    required this.themeMode,
    required this.language,
    required this.notificationsEnabled,
    required this.pushNotificationsEnabled,
    required this.emailNotificationsEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.timezone,
  });

  /// Default preferences
  factory UserPreferences.defaultPreferences() {
    return const UserPreferences(
      themeMode: 'system',
      language: 'en',
      notificationsEnabled: true,
      pushNotificationsEnabled: true,
      emailNotificationsEnabled: true,
      soundEnabled: true,
      vibrationEnabled: true,
      timezone: 'UTC',
    );
  }

  UserPreferences copyWith({
    String? themeMode,
    String? language,
    bool? notificationsEnabled,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? timezone,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      timezone: timezone ?? this.timezone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'timezone': timezone,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      themeMode: json['themeMode'] as String? ?? 'system',
      language: json['language'] as String? ?? 'en',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      pushNotificationsEnabled: json['pushNotificationsEnabled'] as bool? ?? true,
      emailNotificationsEnabled: json['emailNotificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      timezone: json['timezone'] as String? ?? 'UTC',
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        language,
        notificationsEnabled,
        pushNotificationsEnabled,
        emailNotificationsEnabled,
        soundEnabled,
        vibrationEnabled,
        timezone,
      ];
}