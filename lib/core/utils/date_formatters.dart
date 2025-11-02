import 'package:intl/intl.dart';

/// Date Formatters Utility
///
/// Centralized date formatting patterns used throughout the app.
/// Provides consistent date display formats.
///
/// Usage:
/// ```dart
/// final formatted = DateFormatters.monthYear.format(DateTime.now());
/// // Output: "Nov 2025"
/// ```
class DateFormatters {
  // Private constructor to prevent instantiation
  DateFormatters._();

  // ==================== COMMON DATE FORMATS ====================

  /// Month and year format (e.g., "Nov 2025")
  static final DateFormat monthYear = DateFormat('MMM yyyy');

  /// Full date format (e.g., "Nov 2, 2025")
  static final DateFormat fullDate = DateFormat('MMM d, yyyy');

  /// Month and day format (e.g., "Nov 2")
  static final DateFormat monthDay = DateFormat('MMM d');

  /// Short date format (e.g., "11/02/2025")
  static final DateFormat shortDate = DateFormat('MM/dd/yyyy');

  /// Long date format (e.g., "November 2, 2025")
  static final DateFormat longDate = DateFormat('MMMM d, yyyy');

  /// Time format (e.g., "2:30 PM")
  static final DateFormat time = DateFormat('h:mm a');

  /// Time with seconds (e.g., "2:30:45 PM")
  static final DateFormat timeWithSeconds = DateFormat('h:mm:ss a');

  /// Date and time format (e.g., "Nov 2, 2025 at 2:30 PM")
  static final DateFormat dateTime = DateFormat('MMM d, yyyy \'at\' h:mm a');

  /// ISO 8601 format (e.g., "2025-11-02")
  static final DateFormat iso8601 = DateFormat('yyyy-MM-dd');

  /// Day of week format (e.g., "Monday")
  static final DateFormat dayOfWeek = DateFormat('EEEE');

  /// Short day of week format (e.g., "Mon")
  static final DateFormat shortDayOfWeek = DateFormat('EEE');

  /// Year only (e.g., "2025")
  static final DateFormat year = DateFormat('yyyy');

  /// Month only (e.g., "November")
  static final DateFormat month = DateFormat('MMMM');

  /// Short month only (e.g., "Nov")
  static final DateFormat shortMonth = DateFormat('MMM');

  // ==================== HELPER METHODS ====================

  /// Format a relative date (e.g., "Today", "Yesterday", "2d ago")
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return monthDay.format(date);
    }
  }

  /// Format a date range (e.g., "Nov 1 - Nov 30, 2025")
  static String formatRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      // Same month
      return '${monthDay.format(start)} - ${fullDate.format(end)}';
    } else if (start.year == end.year) {
      // Same year, different month
      return '${monthDay.format(start)} - ${fullDate.format(end)}';
    } else {
      // Different years
      return '${fullDate.format(start)} - ${fullDate.format(end)}';
    }
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if a date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  /// Check if a date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
}
