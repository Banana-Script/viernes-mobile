import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/config/environment.dart';
import '../../core/constants/app_constants.dart';

/// Provider for theme mode (light/dark/system)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Theme mode notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    state = mode;
    // TODO: Persist to storage
  }

  void toggleTheme() {
    switch (state) {
      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.system:
        setThemeMode(ThemeMode.light);
        break;
    }
  }
}

/// Provider for connectivity status
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((List<ConnectivityResult> results) {
    // Return the first result, or none if empty
    return results.isNotEmpty ? results.first : ConnectivityResult.none;
  });
});

/// Provider for checking if device is online
final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (result) => result != ConnectivityResult.none,
    loading: () => true, // Assume online while loading
    error: (_, __) => false,
  );
});

/// Provider for locale/language
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Locale notifier
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  void setLocale(Locale locale) {
    state = locale;
    // TODO: Persist to storage
  }
}

/// Provider for app lifecycle state
final appLifecycleProvider = StateNotifierProvider<AppLifecycleNotifier, AppLifecycleState>((ref) {
  return AppLifecycleNotifier();
});

/// App lifecycle notifier
class AppLifecycleNotifier extends StateNotifier<AppLifecycleState> with WidgetsBindingObserver {
  AppLifecycleNotifier() : super(AppLifecycleState.resumed) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    this.state = state;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

/// Provider for app version info
final appVersionProvider = Provider<String>((ref) {
  return AppConstants.appVersion;
});

/// Provider for environment info
final environmentProvider = Provider<Environment>((ref) {
  return AppConfig.instance.environment;
});

/// Provider for debug mode status
final isDebugModeProvider = Provider<bool>((ref) {
  return AppConfig.instance.debugMode;
});

/// Provider for feature flags
final featureFlagsProvider = Provider<FeatureFlagsNotifier>((ref) {
  return FeatureFlagsNotifier();
});

/// Feature flags notifier
class FeatureFlagsNotifier {
  bool get biometricAuth => FeatureFlags.biometricAuth;
  bool get pushNotifications => FeatureFlags.pushNotifications;
  bool get offlineMode => FeatureFlags.offlineMode;
  bool get voiceCalls => FeatureFlags.voiceCalls;
  bool get videoCalls => FeatureFlags.videoCalls;
  bool get fileSharing => FeatureFlags.fileSharing;
  bool get darkMode => FeatureFlags.darkMode;
  bool get analytics => FeatureFlags.analytics;
  bool get crashReporting => FeatureFlags.crashReporting;
}

/// Global loading state provider
final globalLoadingProvider = StateNotifierProvider<GlobalLoadingNotifier, bool>((ref) {
  return GlobalLoadingNotifier();
});

/// Global loading notifier
class GlobalLoadingNotifier extends StateNotifier<bool> {
  GlobalLoadingNotifier() : super(false);

  void setLoading(bool isLoading) {
    state = isLoading;
  }

  void show() => setLoading(true);
  void hide() => setLoading(false);
}

/// Global error state provider
final globalErrorProvider = StateNotifierProvider<GlobalErrorNotifier, String?>((ref) {
  return GlobalErrorNotifier();
});

/// Global error notifier
class GlobalErrorNotifier extends StateNotifier<String?> {
  GlobalErrorNotifier() : super(null);

  void setError(String? error) {
    state = error;
  }

  void showError(String error) => setError(error);
  void clearError() => setError(null);
}