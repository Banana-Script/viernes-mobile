import 'package:flutter/material.dart';

/// Viernes Color System
///
/// Defines the complete Viernes brand color palette following the design system.
/// Based on the brand guidelines:
/// - Primary: Dark Gray (#374151) representing professionalism and reliability
/// - Secondary: Bright Yellow (#FFE61B) representing innovation and energy
/// - Accent: Cyan (#51f5f8) for interactive elements and highlights
class ViernesColors {
  // Brand Primary Colors (Gray Scale)
  static const Color primary = Color(0xFF374151);           // Main dark gray
  static const Color primaryLight = Color(0xFF9CA3AF);       // Light gray
  static const Color primaryDarkLight = Color(0x26374151);   // Light overlay (15% opacity)

  // Brand Secondary Colors (Yellow Scale)
  static const Color secondary = Color(0xFFFFE61B);          // Main yellow
  static const Color secondaryLight = Color(0xFFFFF04D);     // Light yellow
  static const Color secondaryDark = Color(0xFFE6CF00);      // Dark yellow

  // Brand Accent Colors (Cyan Scale)
  static const Color accent = Color(0xFF51F5F8);             // Main cyan
  static const Color accentLight = Color(0xFF7DF8FC);        // Light cyan

  // Semantic Colors (Status Indicators)
  static const Color success = Color(0xFF16A34A);            // Green
  static const Color successLight = Color(0xFFDCFCE7);       // Light green background
  static const Color successDark = Color(0xFF15803D);        // Dark green

  static const Color danger = Color(0xFFE7515A);             // Red
  static const Color dangerLight = Color(0xFFFFF5F5);        // Light red background

  static const Color warning = Color(0xFFE2A03F);            // Orange
  static const Color warningLight = Color(0xFFFFF9ED);       // Light orange background

  static const Color info = Color(0xFF2196F3);               // Blue
  static const Color infoLight = Color(0xFFE7F7FF);          // Light blue background

  // Background Colors
  // Light Theme Backgrounds
  static const Color backgroundLight = Color(0xFFFAFAFA);    // Page background
  static const Color panelLight = Color(0xFFFFFFFF);         // Panel/card background

  // Dark Theme Backgrounds
  static const Color backgroundDark = Color(0xFF060818);     // Page background
  static const Color panelDark = Color(0xFF000000);          // Panel/card background

  // Gradient Colors
  /// Viernes brand gradient: from dark gray to bright yellow
  static const LinearGradient viernesGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
    colors: [primary, secondary],
  );

  // Shadow Colors
  static const Color shadowPrimary = Color(0x99374151);      // Primary shadow (60% opacity)
  static const Color shadowSecondary = Color(0x99FFE61B);    // Secondary shadow (60% opacity)

  // Helper methods for dynamic colors based on theme
  static Color getControlBackground(bool isDark) {
    return isDark ? panelDark : panelLight;
  }

  static Color getTextColor(bool isDark) {
    return isDark ? const Color(0xFFE0E6ED) : primary;
  }

  static Color getBorderColor(bool isDark) {
    return isDark ? const Color(0xFF253E5C) : primaryLight;
  }

  static Color getThemePrimary(bool isDark) {
    return isDark ? secondary : primary;
  }

  static Color getThemeSecondary(bool isDark) {
    return isDark ? primary : secondary;
  }

  // Color palette for development reference
  static const Map<String, Color> palette = {
    // Primary colors
    'primary': primary,
    'primaryLight': primaryLight,
    'primaryDarkLight': primaryDarkLight,

    // Secondary colors
    'secondary': secondary,
    'secondaryLight': secondaryLight,
    'secondaryDark': secondaryDark,

    // Accent colors
    'accent': accent,
    'accentLight': accentLight,

    // Status colors
    'success': success,
    'successLight': successLight,
    'successDark': successDark,
    'danger': danger,
    'dangerLight': dangerLight,
    'warning': warning,
    'warningLight': warningLight,
    'info': info,
    'infoLight': infoLight,

    // Background colors
    'backgroundLight': backgroundLight,
    'panelLight': panelLight,
    'backgroundDark': backgroundDark,
    'panelDark': panelDark,

    // Shadow colors
    'shadowPrimary': shadowPrimary,
    'shadowSecondary': shadowSecondary,
  };
}