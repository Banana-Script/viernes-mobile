import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_manager.dart';

/// Locale Manager for Viernes Mobile
///
/// Handles language switching between English, Spanish, and system locale.
/// Manages locale persistence using Riverpod for state management.
class LocaleManager extends StateNotifier<Locale?> {
  static const String _localeKey = 'viernes_locale';
  final SharedPreferences _prefs;

  // Supported locales
  static const Locale english = Locale('en');
  static const Locale spanish = Locale('es');

  LocaleManager(this._prefs) : super(null) {
    _loadLocale();
  }

  /// Get current locale (null means system default)
  Locale? get currentLocale => state;

  /// Check if using system locale
  bool get isSystemLocale => state == null;

  /// Check if current locale is English
  bool get isEnglish => state?.languageCode == 'en';

  /// Check if current locale is Spanish
  bool get isSpanish => state?.languageCode == 'es';

  /// Get display name for current locale
  String get localeDisplayName {
    if (state == null) return 'System';
    switch (state!.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return state!.languageCode.toUpperCase();
    }
  }

  /// Load locale from SharedPreferences
  void _loadLocale() {
    final localeString = _prefs.getString(_localeKey);
    if (localeString != null && localeString != 'system') {
      state = Locale(localeString);
    }
    // If null or 'system', keep state as null (system default)
  }

  /// Save locale to SharedPreferences
  Future<void> _saveLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.setString(_localeKey, 'system');
    } else {
      await _prefs.setString(_localeKey, locale.languageCode);
    }
  }

  /// Set locale to English
  Future<void> setEnglish() async {
    await _setLocale(english);
  }

  /// Set locale to Spanish
  Future<void> setSpanish() async {
    await _setLocale(spanish);
  }

  /// Set locale to follow system
  Future<void> setSystemLocale() async {
    await _setLocale(null);
  }

  /// Set specific locale
  Future<void> setLocale(Locale? locale) async {
    await _setLocale(locale);
  }

  Future<void> _setLocale(Locale? locale) async {
    if (state != locale) {
      state = locale;
      await _saveLocale(locale);
    }
  }

  /// Get all available locales for settings UI
  static const List<LocaleOption> availableLocales = [
    LocaleOption(locale: null, name: 'System', icon: Icons.language),
    LocaleOption(locale: english, name: 'English', icon: Icons.flag),
    LocaleOption(locale: spanish, name: 'Español', icon: Icons.flag),
  ];

  /// Get display name for any locale
  static String getLocaleDisplayName(Locale? locale) {
    if (locale == null) return 'System';
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  /// Get icon for any locale
  static IconData getLocaleIcon(Locale? locale) {
    if (locale == null) return Icons.language;
    return Icons.flag;
  }

  /// Get system locale
  static Locale getSystemLocale() {
    return PlatformDispatcher.instance.locale;
  }
}

/// Locale option for UI display
class LocaleOption {
  final Locale? locale;
  final String name;
  final IconData icon;

  const LocaleOption({
    required this.locale,
    required this.name,
    required this.icon,
  });
}

/// Provider for LocaleManager
final localeManagerProvider = StateNotifierProvider<LocaleManager, Locale?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleManager(prefs);
});

/// Provider to get current locale display name
final currentLocaleDisplayNameProvider = Provider<String>((ref) {
  final locale = ref.watch(localeManagerProvider);
  return LocaleManager.getLocaleDisplayName(locale);
});
