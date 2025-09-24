import 'package:flutter/material.dart';

/// Application-wide constants including design tokens, colors, typography, and spacing
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // App Info
  static const String appName = 'Viernes Mobile';
  static const String appVersion = '1.0.0';
}

/// Viernes color palette based on the design system
class ViernesColors {
  ViernesColors._();

  // Primary colors (Gray Scale)
  static const Color primary = Color(0xFF374151);
  static const Color primaryLight = Color(0xFF9CA3AF);
  static const Color primaryDarkLight = Color(0x26374151); // rgba(55,65,81,.15)

  // Secondary colors (Yellow Scale)
  static const Color secondary = Color(0xFFFFE61B);
  static const Color secondaryLight = Color(0xFFFFF04D);
  static const Color secondaryDark = Color(0xFFE6CF00);

  // Accent colors (Cyan Scale)
  static const Color accent = Color(0xFF51F5F8);
  static const Color accentLight = Color(0xFF7DF8FC);

  // Semantic/Status colors
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF15803D);

  static const Color danger = Color(0xFFE7515A);
  static const Color dangerLight = Color(0xFFFFF5F5);

  static const Color warning = Color(0xFFE2A03F);
  static const Color warningLight = Color(0xFFFFF9ED);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE7F7FF);

  // Background colors
  // Light theme
  static const Color bgLight = Color(0xFFFAFAFA);
  static const Color panelLight = Color(0xFFFFFFFF);

  // Dark theme
  static const Color bgDark = Color(0xFF060818);
  static const Color panelDark = Color(0xFF000000);

  // Additional colors
  static const Color whiteLight = Color(0xFFE0E6ED);
  static const Color textGray = Color(0xFF506690);
  static const Color borderGray = Color(0xFF17263C);
  static const Color darkPanel = Color(0xFF121E32);
  static const Color darkBorder = Color(0xFF253B5C);
}

/// Typography scale and styles based on Nunito font family
class ViernesTextStyles {
  ViernesTextStyles._();

  static const String fontFamily = 'Nunito';

  // Font weights
  static const FontWeight fontNormal = FontWeight.w400;
  static const FontWeight fontSemiBold = FontWeight.w600;
  static const FontWeight fontBold = FontWeight.w700;

  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 40,
    fontWeight: fontBold,
    height: 1.25,
    fontFamily: fontFamily,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 32,
    fontWeight: fontBold,
    height: 1.25,
    fontFamily: fontFamily,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 28,
    fontWeight: fontSemiBold,
    height: 1.25,
    fontFamily: fontFamily,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 24,
    fontWeight: fontSemiBold,
    height: 1.25,
    fontFamily: fontFamily,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: 20,
    fontWeight: fontSemiBold,
    height: 1.25,
    fontFamily: fontFamily,
  );

  static const TextStyle h6 = TextStyle(
    fontSize: 16,
    fontWeight: fontSemiBold,
    height: 1.25,
    fontFamily: fontFamily,
  );

  // Body text
  static const TextStyle bodyBase = TextStyle(
    fontSize: 14,
    fontWeight: fontNormal,
    height: 1.5,
    fontFamily: fontFamily,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: fontNormal,
    height: 1.5,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: fontNormal,
    height: 1.5,
    fontFamily: fontFamily,
  );

  // Button text styles
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: fontSemiBold,
    height: 1.25,
    fontFamily: fontFamily,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: fontSemiBold,
    height: 1.25,
    fontFamily: fontFamily,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: fontSemiBold,
    height: 1.25,
    fontFamily: fontFamily,
  );
}

/// Spacing system based on the design system
class ViernesSpacing {
  ViernesSpacing._();

  // Base spacing scale
  static const double space0 = 0;
  static const double space1 = 4.0;   // 0.25rem
  static const double space2 = 8.0;   // 0.5rem
  static const double space3 = 12.0;  // 0.75rem
  static const double space4 = 16.0;  // 1rem
  static const double space5 = 20.0;  // 1.25rem
  static const double space6 = 24.0;  // 1.5rem
  static const double space8 = 32.0;  // 2rem
  static const double space10 = 40.0; // 2.5rem
  static const double space12 = 48.0; // 3rem
  static const double space16 = 64.0; // 4rem
  static const double space20 = 80.0; // 5rem

  // Custom spacing
  static const double space4_5 = 18.0; // Custom spacing for specific use cases

  // Common spacing aliases
  static const double xs = space1;
  static const double sm = space2;
  static const double md = space4;
  static const double lg = space6;
  static const double xl = space8;
  static const double xxl = space12;
}

/// Border radius values
class ViernesRadius {
  ViernesRadius._();

  static const double sm = 4.0;
  static const double md = 6.0;
  static const double lg = 8.0;
  static const double xl = 12.0;
  static const double full = 50.0; // Used for circular shapes
}

/// Animation and transition durations
class ViernesAnimations {
  ViernesAnimations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // Easing curves
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeInOut = Curves.easeInOut;
}

/// Common box shadows
class ViernesShadows {
  ViernesShadows._();

  static const BoxShadow defaultShadow = BoxShadow(
    color: Color(0x75E0E6ED),
    offset: Offset(0, 2),
    blurRadius: 2,
    spreadRadius: 1,
  );

  static BoxShadow primaryShadow = BoxShadow(
    color: ViernesColors.primary.withValues(alpha: 0.6),
    offset: const Offset(0, 10),
    blurRadius: 20,
  );

  static BoxShadow secondaryShadow = BoxShadow(
    color: ViernesColors.secondary.withValues(alpha: 0.6),
    offset: const Offset(0, 10),
    blurRadius: 20,
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x29E0E6ED),
    offset: Offset(0, 2),
    blurRadius: 8,
    spreadRadius: 1,
  );
}

/// Breakpoints for responsive design
class ViernesBreakpoints {
  ViernesBreakpoints._();

  static const double mobile = 640;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1280;
  static const double xlargeDesktop = 1536;
}

/// Asset paths
class ViernesAssets {
  ViernesAssets._();

  // Images
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String fontsPath = 'assets/fonts/';

  // Logo files
  static const String logo = '${imagesPath}viernes-logo.png';
  static const String logoWhite = '${imagesPath}logo-white.png';
  static const String logoNegative = '${imagesPath}viernes-negativo.png';
}