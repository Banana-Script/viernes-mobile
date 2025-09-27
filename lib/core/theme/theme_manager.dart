import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Theme Manager for Viernes Mobile
///
/// Handles theme switching between light, dark, and system modes.
/// Manages theme persistence and provides utilities for theme-aware development.
class ThemeManager extends ChangeNotifier {
  // static const String _themeKey = 'viernes_theme_mode'; // TODO: Use for SharedPreferences

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Get the current brightness based on theme mode and system settings
  Brightness get currentBrightness {
    switch (_themeMode) {
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
  bool get isSystem => _themeMode == ThemeMode.system;

  /// Set theme to light mode
  void setLightTheme() {
    _setTheme(ThemeMode.light);
  }

  /// Set theme to dark mode
  void setDarkTheme() {
    _setTheme(ThemeMode.dark);
  }

  /// Set theme to follow system
  void setSystemTheme() {
    _setTheme(ThemeMode.system);
  }

  /// Toggle between light and dark (maintains system if currently system)
  void toggleTheme() {
    if (_themeMode == ThemeMode.system) {
      // If system, switch to opposite of current system theme
      final systemBrightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      _setTheme(systemBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
    } else {
      // Toggle between light and dark
      _setTheme(_themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
    }
  }

  /// Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    _setTheme(mode);
  }

  void _setTheme(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _updateSystemUI();
      notifyListeners();
      // Here you would save to SharedPreferences in a real app
      // await _saveThemePreference(mode);
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

  /// Initialize theme manager (call this in main.dart)
  Future<void> initialize() async {
    // Load saved theme preference
    // In a real app, you'd load from SharedPreferences here
    // final savedTheme = await _loadThemePreference();
    // _themeMode = savedTheme;

    _updateSystemUI();

    // Listen to system theme changes
    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      if (_themeMode == ThemeMode.system) {
        _updateSystemUI();
        notifyListeners();
      }
    };
  }

  // Future methods for persistence (implement with SharedPreferences)
  /*
  Future<void> _saveThemePreference(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString());
  }

  Future<ThemeMode> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey);

    switch (themeString) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.system':
      default:
        return ThemeMode.system;
    }
  }
  */

  /// Get theme name as string for UI display
  String get themeDisplayName {
    switch (_themeMode) {
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
    switch (_themeMode) {
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