import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../theme/theme_manager.dart';
import '../utils/timezone_utils.dart';

/// Timezone preference options
enum TimezonePreference {
  /// Use organization's timezone (default)
  organization,
  /// Use device's local timezone
  device,
}

/// Timezone state containing all timezone-related data
class TimezoneState {
  final TimezonePreference preference;
  final String? organizationTimezone;
  final String deviceTimezone;
  final bool isLoading;
  final String? error;

  const TimezoneState({
    this.preference = TimezonePreference.organization,
    this.organizationTimezone,
    required this.deviceTimezone,
    this.isLoading = false,
    this.error,
  });

  /// Get the currently active timezone based on preference
  String get currentTimezone {
    if (preference == TimezonePreference.device) {
      return deviceTimezone;
    }
    // Default to organization timezone, fallback to device if not set
    return organizationTimezone ?? deviceTimezone;
  }

  /// Check if organization timezone is available
  bool get hasOrganizationTimezone => organizationTimezone != null;

  /// Copy with support for explicitly clearing organizationTimezone
  TimezoneState copyWith({
    TimezonePreference? preference,
    String? organizationTimezone,
    bool clearOrganizationTimezone = false,
    String? deviceTimezone,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return TimezoneState(
      preference: preference ?? this.preference,
      organizationTimezone: clearOrganizationTimezone
          ? null
          : (organizationTimezone ?? this.organizationTimezone),
      deviceTimezone: deviceTimezone ?? this.deviceTimezone,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Timezone Manager for Viernes Mobile
///
/// Handles timezone switching between organization timezone and device timezone.
/// Manages timezone persistence using Riverpod for state management.
///
/// Features:
/// - Organization timezone from API
/// - Device/local timezone fallback
/// - User preference persistence
/// - Timezone conversion utilities
class TimezoneManager extends StateNotifier<TimezoneState> {
  static const String _preferenceKey = 'viernes_timezone_preference';
  static const String _defaultTimezone = 'America/Bogota';

  final SharedPreferences _prefs;

  TimezoneManager(this._prefs) : super(TimezoneState(
    // Initialize timezones FIRST (via TimezoneUtils), then get device timezone
    deviceTimezone: _initAndGetDeviceTimezone(),
  )) {
    _loadPreference();
  }

  /// Initialize timezones and get device timezone in one call
  /// This ensures initialization happens before we try to detect device timezone
  static String _initAndGetDeviceTimezone() {
    // Use centralized initialization from TimezoneUtils
    TimezoneUtils.initialize();
    return _getDeviceTimezone();
  }

  /// Get device's local timezone
  static String _getDeviceTimezone() {
    try {
      final now = DateTime.now();
      final timeZoneOffset = now.timeZoneOffset;
      return _findIanaTimezone(timeZoneOffset) ?? _defaultTimezone;
    } catch (e) {
      debugPrint('[TimezoneManager] Error getting device timezone: $e');
      return _defaultTimezone;
    }
  }

  /// Find IANA timezone from offset
  /// Extended mapping to cover more common timezones
  static String? _findIanaTimezone(Duration offset) {
    final offsetMinutes = offset.inMinutes;

    // Map by total minutes to handle half-hour offsets
    final commonTimezones = {
      // Americas
      -720: 'Pacific/Fiji',          // UTC-12
      -660: 'Pacific/Midway',        // UTC-11
      -600: 'Pacific/Honolulu',      // UTC-10 (Hawaii)
      -540: 'America/Anchorage',     // UTC-9 (Alaska)
      -480: 'America/Los_Angeles',   // UTC-8 (Pacific)
      -420: 'America/Denver',        // UTC-7 (Mountain)
      -360: 'America/Mexico_City',   // UTC-6 (Central)
      -300: 'America/Bogota',        // UTC-5 (Colombia, Peru, Eastern)
      -240: 'America/Caracas',       // UTC-4 (Venezuela, Atlantic)
      -210: 'America/St_Johns',      // UTC-3:30 (Newfoundland)
      -180: 'America/Sao_Paulo',     // UTC-3 (Brazil, Argentina)
      -120: 'America/Noronha',       // UTC-2
      -60: 'Atlantic/Azores',        // UTC-1

      // Europe/Africa
      0: 'UTC',                       // UTC
      60: 'Europe/Madrid',           // UTC+1 (CET)
      120: 'Europe/Berlin',          // UTC+2 (CEST)
      180: 'Europe/Moscow',          // UTC+3 (Moscow)

      // Asia
      210: 'Asia/Tehran',            // UTC+3:30 (Iran)
      240: 'Asia/Dubai',             // UTC+4 (Gulf)
      270: 'Asia/Kabul',             // UTC+4:30 (Afghanistan)
      300: 'Asia/Karachi',           // UTC+5 (Pakistan)
      330: 'Asia/Kolkata',           // UTC+5:30 (India)
      345: 'Asia/Kathmandu',         // UTC+5:45 (Nepal)
      360: 'Asia/Dhaka',             // UTC+6 (Bangladesh)
      390: 'Asia/Yangon',            // UTC+6:30 (Myanmar)
      420: 'Asia/Bangkok',           // UTC+7 (Thailand)
      480: 'Asia/Shanghai',          // UTC+8 (China)
      540: 'Asia/Tokyo',             // UTC+9 (Japan)
      570: 'Australia/Darwin',       // UTC+9:30 (Australia Central)
      600: 'Australia/Sydney',       // UTC+10 (Australia Eastern)
      660: 'Pacific/Noumea',         // UTC+11
      720: 'Pacific/Auckland',       // UTC+12 (New Zealand)
    };

    return commonTimezones[offsetMinutes];
  }

  /// Load preference from SharedPreferences
  void _loadPreference() {
    final prefString = _prefs.getString(_preferenceKey);
    if (prefString != null) {
      final pref = TimezonePreference.values.firstWhere(
        (e) => e.name == prefString,
        orElse: () => TimezonePreference.organization,
      );
      state = state.copyWith(preference: pref);
    }
  }

  /// Save preference to SharedPreferences
  Future<void> _savePreference(TimezonePreference pref) async {
    await _prefs.setString(_preferenceKey, pref.name);
  }

  /// Set timezone preference
  Future<void> setPreference(TimezonePreference pref) async {
    if (state.preference != pref) {
      state = state.copyWith(preference: pref);
      await _savePreference(pref);
    }
  }

  /// Set to use organization timezone
  Future<void> useOrganizationTimezone() async {
    await setPreference(TimezonePreference.organization);
  }

  /// Set to use device timezone
  Future<void> useDeviceTimezone() async {
    await setPreference(TimezonePreference.device);
  }

  /// Update organization timezone (called after API fetch)
  void setOrganizationTimezone(String timezone) {
    state = state.copyWith(
      organizationTimezone: timezone,
      isLoading: false,
      clearError: true,
    );
  }

  /// Clear organization timezone (called on logout)
  void clearOrganizationTimezone() {
    state = state.copyWith(
      clearOrganizationTimezone: true,
      isLoading: false,
      clearError: true,
    );
  }

  /// Set loading state
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Set error state
  void setError(String? error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  /// Get current timezone string
  String get currentTimezone => state.currentTimezone;

  /// Get organization timezone
  String? get organizationTimezone => state.organizationTimezone;

  /// Get device timezone
  String get deviceTimezone => state.deviceTimezone;

  /// Check if using organization timezone
  bool get isUsingOrganizationTimezone =>
      state.preference == TimezonePreference.organization;

  /// Check if using device timezone
  bool get isUsingDeviceTimezone =>
      state.preference == TimezonePreference.device;

  /// Get timezone location for conversions
  tz.Location getTimezoneLocation([String? timezone]) {
    final tzName = timezone ?? currentTimezone;
    try {
      return tz.getLocation(tzName);
    } catch (e) {
      debugPrint('[TimezoneManager] Unknown timezone: $tzName, using default');
      return tz.getLocation(_defaultTimezone);
    }
  }

  /// Convert UTC DateTime to current timezone
  tz.TZDateTime toCurrentTimezone(DateTime utcDateTime) {
    final location = getTimezoneLocation();
    return tz.TZDateTime.from(utcDateTime.toUtc(), location);
  }

  /// Get current time in the active timezone
  tz.TZDateTime now() {
    final location = getTimezoneLocation();
    return tz.TZDateTime.now(location);
  }

  /// Get display name for timezone
  static String getTimezoneDisplayName(String timezone) {
    return TimezoneUtils.getDisplayName(timezone);
  }

  /// Get UTC offset string for timezone
  static String getTimezoneOffset(String timezone) {
    return TimezoneUtils.getUtcOffset(timezone);
  }

  /// Available timezone options for settings UI
  static List<TimezoneOption> getAvailableOptions(TimezoneState state) {
    return [
      TimezoneOption(
        preference: TimezonePreference.organization,
        name: 'Organization',
        description: state.organizationTimezone != null
            ? '${getTimezoneDisplayName(state.organizationTimezone!)} (${getTimezoneOffset(state.organizationTimezone!)})'
            : 'Not available',
        icon: Icons.business,
        isAvailable: state.organizationTimezone != null,
      ),
      TimezoneOption(
        preference: TimezonePreference.device,
        name: 'Device',
        description: '${getTimezoneDisplayName(state.deviceTimezone)} (${getTimezoneOffset(state.deviceTimezone)})',
        icon: Icons.phone_android,
        isAvailable: true,
      ),
    ];
  }
}

/// Timezone option for UI display
class TimezoneOption {
  final TimezonePreference preference;
  final String name;
  final String description;
  final IconData icon;
  final bool isAvailable;

  const TimezoneOption({
    required this.preference,
    required this.name,
    required this.description,
    required this.icon,
    this.isAvailable = true,
  });
}

/// Provider for TimezoneManager
final timezoneManagerProvider = StateNotifierProvider<TimezoneManager, TimezoneState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TimezoneManager(prefs);
});

/// Provider to get current timezone string
final currentTimezoneProvider = Provider<String>((ref) {
  final state = ref.watch(timezoneManagerProvider);
  return state.currentTimezone;
});

/// Provider to get timezone display info
final timezoneDisplayInfoProvider = Provider<String>((ref) {
  final state = ref.watch(timezoneManagerProvider);
  final tz = state.currentTimezone;
  return '${TimezoneManager.getTimezoneDisplayName(tz)} (${TimezoneManager.getTimezoneOffset(tz)})';
});
