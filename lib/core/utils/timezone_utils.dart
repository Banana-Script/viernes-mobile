import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../gen_l10n/app_localizations.dart';

/// Timezone-aware date formatting utilities
///
/// Provides functions to format dates considering timezone settings.
/// All dates are converted to the specified timezone before formatting.
///
/// Usage:
/// ```dart
/// final formatted = TimezoneUtils.formatDateTime(
///   date,
///   'America/Bogota',
///   'es',
/// );
/// ```
class TimezoneUtils {
  // Private constructor to prevent instantiation
  TimezoneUtils._();

  static bool _initialized = false;

  /// Initialize timezone database (call once at app startup)
  static void initialize() {
    if (!_initialized) {
      tz_data.initializeTimeZones();
      _initialized = true;
    }
  }

  /// Ensure timezones are initialized
  static void _ensureInitialized() {
    if (!_initialized) {
      initialize();
    }
  }

  /// Validate if a timezone string is a valid IANA timezone
  ///
  /// Returns true if the timezone is valid and can be used for conversions.
  static bool isValidTimezone(String? timezone) {
    if (timezone == null || timezone.isEmpty) return false;
    _ensureInitialized();
    try {
      tz.getLocation(timezone);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get timezone location safely
  ///
  /// Falls back to America/Bogota (default) if timezone is invalid.
  static tz.Location _getLocation(String timezone) {
    _ensureInitialized();
    try {
      return tz.getLocation(timezone);
    } catch (e) {
      debugPrint('[TimezoneUtils] Unknown timezone: $timezone, using America/Bogota');
      return tz.getLocation('America/Bogota');
    }
  }

  /// Convert DateTime to specified timezone
  ///
  /// By default (forceUtc = true), assumes dates from API are UTC even if not marked as such.
  /// This matches the frontend behavior where API dates without timezone suffix are treated as UTC.
  ///
  /// Set forceUtc = false only for dates that are genuinely in local time (e.g., user input).
  ///
  /// @param date The DateTime to convert
  /// @param timezone Target IANA timezone (e.g., "America/Bogota")
  /// @param forceUtc If true (default), treat non-UTC dates as UTC. If false, preserve local interpretation.
  static tz.TZDateTime toTimezone(DateTime date, String timezone, {bool forceUtc = true}) {
    final location = _getLocation(timezone);

    if (date.isUtc) {
      // Date is explicitly UTC, convert to target timezone
      return tz.TZDateTime.from(date, location);
    } else if (forceUtc) {
      // Date not marked as UTC but API sends UTC without 'Z' suffix
      // Force UTC interpretation (same as frontend forceUtcInterpretation)
      final utcDate = DateTime.utc(
        date.year,
        date.month,
        date.day,
        date.hour,
        date.minute,
        date.second,
        date.millisecond,
        date.microsecond,
      );
      return tz.TZDateTime.from(utcDate, location);
    } else {
      // Preserve local time interpretation - create TZDateTime with same values
      return tz.TZDateTime(
        location,
        date.year,
        date.month,
        date.day,
        date.hour,
        date.minute,
        date.second,
        date.millisecond,
        date.microsecond,
      );
    }
  }

  /// Get current time in specified timezone
  static tz.TZDateTime now(String timezone) {
    final location = _getLocation(timezone);
    return tz.TZDateTime.now(location);
  }

  // ==================== FORMAT PRESETS ====================

  /// Format full date and time (e.g., "05/08/2025, 14:57:22")
  static String formatDateTime(DateTime date, String timezone, String locale) {
    final tzDate = toTimezone(date, timezone);
    final formatter = DateFormat('dd/MM/yyyy, HH:mm:ss', locale);
    return formatter.format(tzDate);
  }

  /// Format date only (e.g., "05/08/2025")
  static String formatDateOnly(DateTime date, String timezone, String locale) {
    final tzDate = toTimezone(date, timezone);
    final formatter = DateFormat('dd/MM/yyyy', locale);
    return formatter.format(tzDate);
  }

  /// Format time only (e.g., "14:57")
  static String formatTimeOnly(DateTime date, String timezone, String locale) {
    final tzDate = toTimezone(date, timezone);
    final formatter = DateFormat('HH:mm', locale);
    return formatter.format(tzDate);
  }

  /// Format friendly date (e.g., "5 de agosto de 2025, 2:57 PM")
  static String formatFriendly(DateTime date, String timezone, String locale) {
    final tzDate = toTimezone(date, timezone);
    final formatter = DateFormat('d MMMM yyyy, h:mm a', locale);
    return formatter.format(tzDate);
  }

  /// Format short date (e.g., "05 ago 2025")
  static String formatShort(DateTime date, String timezone, String locale) {
    final tzDate = toTimezone(date, timezone);
    final formatter = DateFormat('dd MMM yyyy', locale);
    return formatter.format(tzDate);
  }

  /// Format month and year (e.g., "Nov 2025" or "nov 2025")
  static String formatMonthYear(DateTime date, String timezone, String locale) {
    final tzDate = toTimezone(date, timezone);
    final formatter = DateFormat('MMM yyyy', locale);
    return formatter.format(tzDate);
  }

  /// Format full date (e.g., "Nov 2, 2025")
  static String formatFullDate(DateTime date, String timezone, String locale) {
    final tzDate = toTimezone(date, timezone);
    final formatter = DateFormat.yMMMd(locale);
    return formatter.format(tzDate);
  }

  /// Format with custom pattern
  static String formatCustom(
    DateTime date,
    String timezone,
    String locale,
    String pattern,
  ) {
    final tzDate = toTimezone(date, timezone);
    final formatter = DateFormat(pattern, locale);
    return formatter.format(tzDate);
  }

  // ==================== RELATIVE TIME ====================

  /// Format relative time with localization support
  ///
  /// Returns strings like "Just now", "5m ago", "2h ago", "Yesterday", etc.
  /// Uses AppLocalizations for translated strings.
  static String formatRelativeTime(
    DateTime date,
    String timezone,
    String locale,
    AppLocalizations? l10n,
  ) {
    final tzDate = toTimezone(date, timezone);
    final tzNow = now(timezone);
    final difference = tzNow.difference(tzDate);

    if (difference.isNegative) {
      // Future date - just show the date
      return formatFullDate(date, timezone, locale);
    }

    if (difference.inMinutes < 1) {
      return l10n?.justNow ?? 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return l10n?.minutesAgo(minutes) ?? '${minutes}m ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return l10n?.hoursAgo(hours) ?? '${hours}h ago';
    } else if (difference.inDays == 1) {
      return l10n?.yesterdayTime ?? 'Yesterday';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return l10n?.daysAgo(days) ?? '${days}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return l10n?.weeksAgo(weeks) ?? '${weeks}w ago';
    } else {
      // More than a month - show the formatted date
      return formatFullDate(date, timezone, locale);
    }
  }

  // ==================== HELPER METHODS ====================

  /// Check if a date is today in the specified timezone
  static bool isToday(DateTime date, String timezone) {
    final tzDate = toTimezone(date, timezone);
    final tzNow = now(timezone);
    return tzDate.year == tzNow.year &&
        tzDate.month == tzNow.month &&
        tzDate.day == tzNow.day;
  }

  /// Check if a date is yesterday in the specified timezone
  static bool isYesterday(DateTime date, String timezone) {
    final tzDate = toTimezone(date, timezone);
    final tzYesterday = now(timezone).subtract(const Duration(days: 1));
    return tzDate.year == tzYesterday.year &&
        tzDate.month == tzYesterday.month &&
        tzDate.day == tzYesterday.day;
  }

  /// Check if a date is this week in the specified timezone
  ///
  /// Week starts on Monday (weekday = 1) and ends on Sunday (weekday = 7).
  static bool isThisWeek(DateTime date, String timezone) {
    final tzDate = toTimezone(date, timezone);
    final tzNow = now(timezone);

    // Normalize to start of day (midnight)
    final startOfToday = tz.TZDateTime(
      tzNow.location,
      tzNow.year,
      tzNow.month,
      tzNow.day,
    );

    // Start of week = Monday at 00:00:00
    final startOfWeek = startOfToday.subtract(Duration(days: tzNow.weekday - 1));
    // End of week = Next Monday at 00:00:00 (exclusive boundary)
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    // Check if date is within [startOfWeek, endOfWeek)
    return !tzDate.isBefore(startOfWeek) && tzDate.isBefore(endOfWeek);
  }

  /// Check if a date is this month in the specified timezone
  static bool isThisMonth(DateTime date, String timezone) {
    final tzDate = toTimezone(date, timezone);
    final tzNow = now(timezone);
    return tzDate.year == tzNow.year && tzDate.month == tzNow.month;
  }

  /// Get UTC offset string for timezone (e.g., "UTC-5", "UTC+2")
  static String getUtcOffset(String timezone) {
    final location = _getLocation(timezone);
    final tzNow = tz.TZDateTime.now(location);
    final offset = tzNow.timeZoneOffset;
    final hours = offset.inHours;
    final minutes = (offset.inMinutes % 60).abs();
    final sign = hours >= 0 ? '+' : '';

    if (minutes > 0) {
      return 'UTC$sign$hours:${minutes.toString().padLeft(2, '0')}';
    }
    return 'UTC$sign$hours';
  }

  /// Get display name for timezone (e.g., "Bogota" from "America/Bogota")
  static String getDisplayName(String timezone) {
    final parts = timezone.split('/');
    if (parts.length > 1) {
      return parts.last.replaceAll('_', ' ');
    }
    return timezone;
  }
}

/// Extension on DateTime for convenient timezone formatting
extension DateTimeTimezoneExtension on DateTime {
  /// Format this date in the specified timezone
  String formatInTimezone(String timezone, String locale, String pattern) {
    return TimezoneUtils.formatCustom(this, timezone, locale, pattern);
  }

  /// Format as relative time in the specified timezone
  String formatRelative(String timezone, String locale, AppLocalizations? l10n) {
    return TimezoneUtils.formatRelativeTime(this, timezone, locale, l10n);
  }
}
