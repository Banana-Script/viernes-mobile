import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Manager for Viernes Mobile
///
/// Handles theme switching between light, dark, and system modes.
/// Manages theme persistence and provides utilities for theme-aware development.
/// Now using Riverpod for state management.
class ThemeManager extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'viernes_theme_mode';
  final SharedPreferences _prefs;

  ThemeManager(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
    _updateSystemUI();
    _listenToSystemChanges();
  }

  ThemeMode get themeMode => state;

  /// Get the current brightness based on theme mode and system settings
  Brightness get currentBrightness {
    switch (state) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return SchedulerBinding.instance.platformDispatcher.platformBrightness;
    }
  }

  /// Check if the current theme is dark
  bool get isDark => currentBrightness == Brightness.dark;

  /// Check if the current theme is light
  bool get isLight => currentBrightness == Brightness.light;

  /// Check if the theme is set to follow system
  bool get isSystem => state == ThemeMode.system;

  /// Load theme from SharedPreferences
  void _loadTheme() {
    final themeString = _prefs.getString(_themeKey);
    if (themeString != null) {
      switch (themeString) {
        case 'ThemeMode.light':
          state = ThemeMode.light;
          break;
        case 'ThemeMode.dark':
          state = ThemeMode.dark;
          break;
        case 'ThemeMode.system':
        default:
          state = ThemeMode.system;
          break;
      }
    }
  }

  /// Save theme to SharedPreferences
  Future<void> _saveTheme(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.toString());
  }

  /// Listen to system theme changes
  void _listenToSystemChanges() {
    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      if (state == ThemeMode.system) {
        _updateSystemUI();
        // Trigger rebuild without changing state
        state = state;
      }
    };
  }

  /// Set theme to light mode
  Future<void> setLightTheme() async {
    await _setTheme(ThemeMode.light);
  }

  /// Set theme to dark mode
  Future<void> setDarkTheme() async {
    await _setTheme(ThemeMode.dark);
  }

  /// Set theme to follow system
  Future<void> setSystemTheme() async {
    await _setTheme(ThemeMode.system);
  }

  /// Toggle between light and dark (maintains system if currently system)
  Future<void> toggleTheme() async {
    if (state == ThemeMode.system) {
      // If system, switch to opposite of current system theme
      final systemBrightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      await _setTheme(systemBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
    } else {
      // Toggle between light and dark
      await _setTheme(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
    }
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    await _setTheme(mode);
  }

  Future<void> _setTheme(ThemeMode mode) async {
    if (state != mode) {
      state = mode;
      _updateSystemUI();
      await _saveTheme(mode);
    }
  }

  /// Update system UI overlay style based on current theme
  void _updateSystemUI() {
    final brightness = currentBrightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: brightness,
        systemNavigationBarColor: brightness == Brightness.dark
            ? const Color(0xFF000000)
            : const Color(0xFFFFFFFF),
        systemNavigationBarIconBrightness: brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }


  /// Get theme name as string for UI display
  String get themeDisplayName {
    switch (state) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Get current theme icon
  IconData get themeIcon {
    switch (state) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  /// Get all available theme options for settings UI
  static const List<ThemeMode> availableThemes = [
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark,
  ];

  /// Get display name for any theme mode
  static String getThemeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Get icon for any theme mode
  static IconData getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

/// Provider for ThemeManager
final themeManagerProvider = StateNotifierProvider<ThemeManager, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeManager(prefs);
});

/// Provider for current brightness
final currentBrightnessProvider = Provider<Brightness>((ref) {
  ref.watch(themeManagerProvider);
  final themeManager = ref.read(themeManagerProvider.notifier);
  return themeManager.currentBrightness;
});

/// Provider to check if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  final brightness = ref.watch(currentBrightnessProvider);
  return brightness == Brightness.dark;
});

/// Provider to check if light mode is active
final isLightModeProvider = Provider<bool>((ref) {
  final brightness = ref.watch(currentBrightnessProvider);
  return brightness == Brightness.light;
});