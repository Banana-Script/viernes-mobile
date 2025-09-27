import 'package:flutter/material.dart';

/// Viernes Typography System
///
/// Defines the complete Viernes typography hierarchy using Nunito font family.
/// Based on the design system specifications:
/// - Font Family: Nunito (Google Fonts)
/// - Complete hierarchy from h1 (40px) to body small (12px)
/// - Consistent line heights and font weights
class ViernesTextStyles {
  // Font family constant
  static const String fontFamily = 'Nunito';

  // Font weight constants
  static const FontWeight fontNormal = FontWeight.w400;
  static const FontWeight fontSemibold = FontWeight.w600;
  static const FontWeight fontBold = FontWeight.w700;

  // Line height constants
  static const double leadingTight = 1.25;
  static const double leadingNormal = 1.5;
  static const double leadingRelaxed = 1.625;

  // Heading Styles
  /// Large titles (40px, bold, tight line height)
  static const TextStyle h1 = TextStyle(
    fontSize: 40,
    fontWeight: fontBold,
    height: leadingTight,
    fontFamily: fontFamily,
    letterSpacing: -0.5,
  );

  /// Section headers (32px, semibold, tight line height)
  static const TextStyle h2 = TextStyle(
    fontSize: 32,
    fontWeight: fontSemibold,
    height: leadingTight,
    fontFamily: fontFamily,
    letterSpacing: -0.25,
  );

  /// Subsection headers (28px, semibold, tight line height)
  static const TextStyle h3 = TextStyle(
    fontSize: 28,
    fontWeight: fontSemibold,
    height: leadingTight,
    fontFamily: fontFamily,
  );

  /// Component titles (24px, semibold, tight line height)
  static const TextStyle h4 = TextStyle(
    fontSize: 24,
    fontWeight: fontSemibold,
    height: leadingTight,
    fontFamily: fontFamily,
  );

  /// Small headers (20px, semibold, normal line height)
  static const TextStyle h5 = TextStyle(
    fontSize: 20,
    fontWeight: fontSemibold,
    height: leadingNormal,
    fontFamily: fontFamily,
  );

  /// Captions (16px, semibold, normal line height)
  static const TextStyle h6 = TextStyle(
    fontSize: 16,
    fontWeight: fontSemibold,
    height: leadingNormal,
    fontFamily: fontFamily,
  );

  // Body Text Styles
  /// Large body text (16px, normal weight, normal line height)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: fontNormal,
    height: leadingNormal,
    fontFamily: fontFamily,
  );

  /// Default body text (14px, normal weight, normal line height)
  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    fontWeight: fontNormal,
    height: leadingNormal,
    fontFamily: fontFamily,
  );

  /// Small text (12px, normal weight, normal line height)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: fontNormal,
    height: leadingNormal,
    fontFamily: fontFamily,
  );

  // Button Text Styles
  /// Primary button text (16px, semibold)
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: fontSemibold,
    fontFamily: fontFamily,
    letterSpacing: 0.5,
  );

  /// Default button text (14px, semibold)
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: fontSemibold,
    fontFamily: fontFamily,
    letterSpacing: 0.25,
  );

  /// Small button text (12px, semibold)
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: fontSemibold,
    fontFamily: fontFamily,
    letterSpacing: 0.25,
  );

  // Label Styles
  /// Form labels (14px, semibold)
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: fontSemibold,
    fontFamily: fontFamily,
  );

  /// Small labels (12px, semibold)
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: fontSemibold,
    fontFamily: fontFamily,
  );

  // Caption and Helper Text
  /// Caption text (12px, normal weight, relaxed line height)
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: fontNormal,
    height: leadingRelaxed,
    fontFamily: fontFamily,
  );

  /// Helper text (11px, normal weight)
  static const TextStyle helper = TextStyle(
    fontSize: 11,
    fontWeight: fontNormal,
    fontFamily: fontFamily,
  );

  // Special Styles
  /// Overline text (11px, semibold, uppercase)
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: fontSemibold,
    fontFamily: fontFamily,
    letterSpacing: 1.5,
  );

  /// Code/monospace text (14px, normal weight)
  static const TextStyle code = TextStyle(
    fontSize: 14,
    fontWeight: fontNormal,
    fontFamily: 'Courier',
    height: leadingNormal,
  );

  // Navigation Styles
  /// Navigation item text (14px, semibold)
  static const TextStyle navigation = TextStyle(
    fontSize: 14,
    fontWeight: fontSemibold,
    fontFamily: fontFamily,
  );

  /// Tab text (14px, semibold)
  static const TextStyle tab = TextStyle(
    fontSize: 14,
    fontWeight: fontSemibold,
    fontFamily: fontFamily,
    letterSpacing: 0.25,
  );

  // Utility methods for color variants
  static TextStyle getHeadingStyle(int level, {Color? color}) {
    final styles = [h1, h2, h3, h4, h5, h6];
    final style = styles[level.clamp(0, 5)];
    return color != null ? style.copyWith(color: color) : style;
  }

  static TextStyle getBodyStyle(String size, {Color? color}) {
    final TextStyle style;
    switch (size.toLowerCase()) {
      case 'large':
        style = bodyLarge;
        break;
      case 'small':
        style = bodySmall;
        break;
      default:
        style = bodyText;
    }
    return color != null ? style.copyWith(color: color) : style;
  }

  // Text style variants for different themes
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  // Common text style combinations
  static TextStyle get errorText => bodyText.copyWith(color: const Color(0xFFE7515A));
  static TextStyle get successText => bodyText.copyWith(color: const Color(0xFF16A34A));
  static TextStyle get warningText => bodyText.copyWith(color: const Color(0xFFE2A03F));
  static TextStyle get infoText => bodyText.copyWith(color: const Color(0xFF2196F3));

  // Complete style map for development reference
  static const Map<String, TextStyle> styles = {
    'h1': h1,
    'h2': h2,
    'h3': h3,
    'h4': h4,
    'h5': h5,
    'h6': h6,
    'bodyLarge': bodyLarge,
    'bodyText': bodyText,
    'bodySmall': bodySmall,
    'buttonLarge': buttonLarge,
    'buttonMedium': buttonMedium,
    'buttonSmall': buttonSmall,
    'label': label,
    'labelSmall': labelSmall,
    'caption': caption,
    'helper': helper,
    'overline': overline,
    'code': code,
    'navigation': navigation,
    'tab': tab,
  };
}