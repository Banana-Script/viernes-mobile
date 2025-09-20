import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/app_constants.dart';

// Storage providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Network provider
final dioProvider = Provider((ref) => DioClient.instance.dio);

// Firebase providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs) : super(_loadTheme(_prefs));

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final themeIndex = prefs.getInt(AppConstants.themeKey) ?? 0;
    return ThemeMode.values[themeIndex];
  }

  void setTheme(ThemeMode theme) {
    state = theme;
    _prefs.setInt(AppConstants.themeKey, theme.index);
  }
}

// Language provider
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LanguageNotifier(prefs);
});

class LanguageNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;

  LanguageNotifier(this._prefs) : super(_loadLanguage(_prefs));

  static String _loadLanguage(SharedPreferences prefs) {
    return prefs.getString(AppConstants.languageKey) ?? 'en';
  }

  void setLanguage(String languageCode) {
    state = languageCode;
    _prefs.setString(AppConstants.languageKey, languageCode);
  }
}