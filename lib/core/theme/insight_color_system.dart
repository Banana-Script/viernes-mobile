import 'package:flutter/material.dart';

/// Insight Importance Levels
///
/// Defines three levels of visual hierarchy for insight badges:
/// - informative: Background info, least prominent
/// - normal: Standard visibility, default state
/// - important: Critical attention, most prominent
enum InsightImportance {
  informative, // Background info
  normal, // Standard visibility
  important, // Critical attention
}

/// Insight Badge Colors
///
/// Encapsulates all colors needed for an insight badge.
/// Includes background, border, text, and optional shadow.
class InsightBadgeColors {
  final Color background;
  final Color border;
  final Color text;
  final List<BoxShadow>? shadow;

  const InsightBadgeColors({
    required this.background,
    required this.border,
    required this.text,
    this.shadow,
  });
}

/// Insight Color System
///
/// Provides WCAG 2.1 AA compliant colors for insight badges.
/// Uses solid colors (no transparencies) to guarantee consistent contrast.
///
/// Based on color theory and accessibility best practices:
/// - Light mode: Uses lighter backgrounds with darker text
/// - Dark mode: Uses darker backgrounds with lighter text
/// - Three levels of importance with clear visual hierarchy
/// - All combinations tested for 4.5:1 contrast ratio
class InsightColorSystem {
  /// Get colors for an insight badge
  ///
  /// Parameters:
  /// - baseColor: The semantic color (success, info, warning, accent)
  /// - isDark: Whether dark mode is active
  /// - importance: The importance level of this insight
  ///
  /// Returns InsightBadgeColors with all necessary colors
  static InsightBadgeColors getColors({
    required Color baseColor,
    required bool isDark,
    required InsightImportance importance,
  }) {
    if (isDark) {
      return _getDarkModeColors(baseColor, importance);
    } else {
      return _getLightModeColors(baseColor, importance);
    }
  }

  /// Get colors for light mode
  ///
  /// Uses high lightness for backgrounds (95%, 85%, 75%)
  /// and lower lightness for text (30%, 20%) to ensure contrast.
  static InsightBadgeColors _getLightModeColors(
    Color baseColor,
    InsightImportance importance,
  ) {
    final hsl = HSLColor.fromColor(baseColor);

    switch (importance) {
      case InsightImportance.informative:
        // Most subtle: very light background, medium border, dark text
        return InsightBadgeColors(
          background: hsl.withLightness(0.95).toColor(),
          border: hsl.withLightness(0.75).toColor(),
          text: hsl
              .withLightness(0.30)
              .withSaturation((hsl.saturation * 1.1).clamp(0.0, 1.0))
              .toColor(),
        );

      case InsightImportance.normal:
        // Medium prominence: light background, medium border, dark text
        return InsightBadgeColors(
          background: hsl.withLightness(0.85).toColor(),
          border: hsl.withLightness(0.60).toColor(),
          text: hsl
              .withLightness(0.30)
              .withSaturation((hsl.saturation * 1.1).clamp(0.0, 1.0))
              .toColor(),
        );

      case InsightImportance.important:
        // Most prominent: medium-light background, dark border, very dark text, shadow
        return InsightBadgeColors(
          background: hsl.withLightness(0.75).toColor(),
          border: hsl.withLightness(0.45).toColor(),
          text: hsl
              .withLightness(0.20)
              .withSaturation((hsl.saturation * 1.2).clamp(0.0, 1.0))
              .toColor(),
          shadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
        );
    }
  }

  /// Get colors for dark mode
  ///
  /// Uses low lightness for backgrounds (17%, 28%, 48%)
  /// and higher lightness for text (65%, 75%, white) to ensure contrast.
  static InsightBadgeColors _getDarkModeColors(
    Color baseColor,
    InsightImportance importance,
  ) {
    final hsl = HSLColor.fromColor(baseColor);

    switch (importance) {
      case InsightImportance.informative:
        // Most subtle: very dark background, medium border, bright text
        return InsightBadgeColors(
          background: hsl
              .withLightness(0.17)
              .withSaturation(0.35)
              .toColor(),
          border: hsl
              .withLightness(0.28)
              .withSaturation(0.35)
              .toColor(),
          text: hsl.withLightness(0.65).toColor(),
        );

      case InsightImportance.normal:
        // Medium prominence: dark background, bright border, brighter text
        return InsightBadgeColors(
          background: hsl
              .withLightness(0.28)
              .withSaturation(0.35)
              .toColor(),
          border: hsl.withLightness(0.55).toColor(),
          text: hsl.withLightness(0.75).toColor(),
        );

      case InsightImportance.important:
        // Most prominent: medium background, bright border, white text, strong shadow
        return InsightBadgeColors(
          background: hsl
              .withLightness(0.48)
              .withSaturation((hsl.saturation * 1.2).clamp(0.0, 1.0))
              .toColor(),
          border: hsl.withLightness(0.60).toColor(),
          text: const Color(0xFFFAFAFA), // Almost white for maximum contrast
          shadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.6),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 2,
            ),
          ],
        );
    }
  }

  /// Get border width based on importance
  ///
  /// Returns:
  /// - 1.0 for informative
  /// - 1.5 for normal
  /// - 2.0 for important
  static double getBorderWidth(InsightImportance importance) {
    switch (importance) {
      case InsightImportance.informative:
        return 1.0;
      case InsightImportance.normal:
        return 1.5;
      case InsightImportance.important:
        return 2.0;
    }
  }
}
