import 'package:flutter/material.dart';

/// Localization class to hold supported locales and delegate
class L10n {
  L10n._();

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English (US)
    Locale('es', 'ES'), // Spanish (Spain)
  ];

  /// Default locale
  static const Locale defaultLocale = Locale('en', 'US');

  /// Get locale from language code
  static Locale getLocaleFromLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'es':
        return const Locale('es', 'ES');
      case 'en':
      default:
        return const Locale('en', 'US');
    }
  }

  /// Check if locale is supported
  static bool isLocaleSupported(Locale locale) {
    return supportedLocales.any(
      (supportedLocale) =>
          supportedLocale.languageCode == locale.languageCode &&
          supportedLocale.countryCode == locale.countryCode,
    );
  }
}