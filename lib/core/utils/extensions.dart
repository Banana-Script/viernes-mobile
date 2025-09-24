import 'package:flutter/material.dart';

/// Extensions for BuildContext
extension BuildContextExtensions on BuildContext {
  /// Get MediaQuery data
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => mediaQuery.size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Check if device is mobile (width < 768)
  bool get isMobile => screenWidth < 768;

  /// Check if device is tablet (width >= 768 && width < 1024)
  bool get isTablet => screenWidth >= 768 && screenWidth < 1024;

  /// Check if device is desktop (width >= 1024)
  bool get isDesktop => screenWidth >= 1024;

  /// Get safe area padding
  EdgeInsets get safeAreaPadding => mediaQuery.padding;

  /// Get theme data
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get navigator
  NavigatorState get navigator => Navigator.of(this);

  /// Get scaffold messenger
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);

  /// Show snack bar
  void showSnackBar(String message, {Color? backgroundColor}) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Show error snack bar
  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: colorScheme.error);
  }

  /// Show success snack bar
  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }
}

/// Extensions for String
extension StringExtensions on String {
  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Check if string is a valid password (at least 8 characters)
  bool get isValidPassword {
    return length >= 8;
  }

  /// Check if string is empty or null
  bool get isNullOrEmpty {
    return isEmpty;
  }

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Convert to title case
  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Remove all whitespace
  String get removeWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Check if string contains only numbers
  bool get isNumeric {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  /// Convert string to int safely
  int? get toIntOrNull {
    return int.tryParse(this);
  }

  /// Convert string to double safely
  double? get toDoubleOrNull {
    return double.tryParse(this);
  }

  /// Truncate string to specified length
  String truncate(int length, {String suffix = '...'}) {
    if (this.length <= length) return this;
    return '${substring(0, length)}$suffix';
  }
}

/// Extensions for DateTime
extension DateTimeExtensions on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Get formatted date string (dd/MM/yyyy)
  String get formattedDate {
    return '$day/${month.toString().padLeft(2, '0')}/$year';
  }

  /// Get formatted time string (HH:mm)
  String get formattedTime {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted date and time string
  String get formattedDateTime {
    return '$formattedDate $formattedTime';
  }

  /// Get relative time string (e.g., "2 minutes ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    }

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }

    if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    }

    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    }

    return 'Just now';
  }
}

/// Extensions for List
extension ListExtensions<T> on List<T> {
  /// Check if list is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Get random element from list
  T? get random {
    if (isEmpty) return null;
    return this[(DateTime.now().millisecondsSinceEpoch % length)];
  }

  /// Add element if it doesn't exist
  void addIfNotExists(T item) {
    if (!contains(item)) {
      add(item);
    }
  }

  /// Remove element if it exists
  void removeIfExists(T item) {
    if (contains(item)) {
      remove(item);
    }
  }
}

/// Extensions for Map
extension MapExtensions<K, V> on Map<K, V> {
  /// Check if map is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Get value by key or return default
  V? getOrDefault(K key, V defaultValue) {
    return containsKey(key) ? this[key] : defaultValue;
  }
}

/// Extensions for Duration
extension DurationExtensions on Duration {
  /// Get formatted duration string (e.g., "2:30")
  String get formattedDuration {
    final minutes = inMinutes;
    final seconds = inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get human readable duration
  String get humanReadable {
    if (inDays > 0) {
      return '$inDays day${inDays == 1 ? '' : 's'}';
    }
    if (inHours > 0) {
      return '$inHours hour${inHours == 1 ? '' : 's'}';
    }
    if (inMinutes > 0) {
      return '$inMinutes minute${inMinutes == 1 ? '' : 's'}';
    }
    return '$inSeconds second${inSeconds == 1 ? '' : 's'}';
  }
}

/// Extensions for Color
extension ColorExtensions on Color {
  /// Convert color to hex string
  String get toHex {
    return '#${(toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }

  /// Get contrasting color (black or white)
  Color get contrastingColor {
    final brightness = ThemeData.estimateBrightnessForColor(this);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  /// Lighten color by percentage
  Color lighten(double percentage) {
    assert(percentage >= 0 && percentage <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + percentage).clamp(0.0, 1.0)).toColor();
  }

  /// Darken color by percentage
  Color darken(double percentage) {
    assert(percentage >= 0 && percentage <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - percentage).clamp(0.0, 1.0)).toColor();
  }
}