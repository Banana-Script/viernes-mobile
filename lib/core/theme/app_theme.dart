import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'viernes_colors.dart';
import 'viernes_text_styles.dart';
import 'viernes_spacing.dart';

/// Viernes Application Theme Configuration
///
/// Implements the complete Viernes design system with:
/// - Brand colors (Dark Gray #374151 & Bright Yellow #FFE61B)
/// - Nunito typography with proper hierarchy
/// - Consistent spacing system
/// - Comprehensive light/dark mode support
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      colorScheme: _lightColorScheme,
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: _buildAppBarTheme(Brightness.light),
      elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.light),
      outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.light),
      textButtonTheme: _buildTextButtonTheme(Brightness.light),
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.light),
      cardTheme: _buildCardTheme(Brightness.light),
      scaffoldBackgroundColor: ViernesColors.backgroundLight,
      dividerColor: ViernesColors.primaryLight.withValues(alpha: 0.2),
      bottomNavigationBarTheme: _buildBottomNavTheme(Brightness.light),
      navigationBarTheme: _buildNavigationBarTheme(Brightness.light),
      floatingActionButtonTheme: _buildFABTheme(Brightness.light),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      colorScheme: _darkColorScheme,
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: _buildAppBarTheme(Brightness.dark),
      elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.dark),
      outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.dark),
      textButtonTheme: _buildTextButtonTheme(Brightness.dark),
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.dark),
      cardTheme: _buildCardTheme(Brightness.dark),
      scaffoldBackgroundColor: ViernesColors.backgroundDark,
      dividerColor: ViernesColors.secondary.withValues(alpha: 0.2),
      bottomNavigationBarTheme: _buildBottomNavTheme(Brightness.dark),
      navigationBarTheme: _buildNavigationBarTheme(Brightness.dark),
      floatingActionButtonTheme: _buildFABTheme(Brightness.dark),
    );
  }

  // Light Color Scheme
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: ViernesColors.primary,
    onPrimary: Colors.white,
    secondary: ViernesColors.secondary,
    onSecondary: Colors.black,
    tertiary: ViernesColors.accent,
    onTertiary: Colors.black,
    error: ViernesColors.danger,
    onError: Colors.white,
    surface: ViernesColors.panelLight,
    onSurface: ViernesColors.primary,
    surfaceContainerHighest: ViernesColors.backgroundLight,
    outline: ViernesColors.primaryLight,
    outlineVariant: ViernesColors.primaryDarkLight,
  );

  // Dark Color Scheme
  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: ViernesColors.secondary, // Yellow primary in dark mode
    onPrimary: Colors.black,
    secondary: ViernesColors.primary,
    onSecondary: Colors.white,
    tertiary: ViernesColors.accent,
    onTertiary: Colors.black,
    error: ViernesColors.danger,
    onError: Colors.white,
    surface: ViernesColors.panelDark,
    onSurface: Colors.white,
    surfaceContainerHighest: ViernesColors.backgroundDark,
    outline: ViernesColors.primaryLight,
    outlineVariant: ViernesColors.primaryDarkLight,
  );

  // Text Theme using Nunito
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseTheme = GoogleFonts.nunitoTextTheme();
    final color = brightness == Brightness.light ? ViernesColors.primary : Colors.white;

    return baseTheme.copyWith(
      displayLarge: ViernesTextStyles.h1.copyWith(color: color),
      displayMedium: ViernesTextStyles.h2.copyWith(color: color),
      displaySmall: ViernesTextStyles.h3.copyWith(color: color),
      headlineLarge: ViernesTextStyles.h4.copyWith(color: color),
      headlineMedium: ViernesTextStyles.h5.copyWith(color: color),
      headlineSmall: ViernesTextStyles.h6.copyWith(color: color),
      titleLarge: ViernesTextStyles.bodyLarge.copyWith(color: color, fontWeight: FontWeight.w600),
      titleMedium: ViernesTextStyles.bodyText.copyWith(color: color, fontWeight: FontWeight.w600),
      titleSmall: ViernesTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.w600),
      bodyLarge: ViernesTextStyles.bodyLarge.copyWith(color: color),
      bodyMedium: ViernesTextStyles.bodyText.copyWith(color: color),
      bodySmall: ViernesTextStyles.bodySmall.copyWith(color: color),
      labelLarge: ViernesTextStyles.bodyText.copyWith(color: color, fontWeight: FontWeight.w600),
      labelMedium: ViernesTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.w600),
      labelSmall: ViernesTextStyles.bodySmall.copyWith(color: color, fontSize: 10),
    );
  }

  // App Bar Theme
  static AppBarTheme _buildAppBarTheme(Brightness brightness) {
    return AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: brightness == Brightness.light
          ? ViernesColors.backgroundLight
          : ViernesColors.backgroundDark,
      foregroundColor: brightness == Brightness.light
          ? ViernesColors.primary
          : Colors.white,
      titleTextStyle: ViernesTextStyles.h5.copyWith(
        color: brightness == Brightness.light ? ViernesColors.primary : Colors.white,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(
        color: brightness == Brightness.light ? ViernesColors.primary : Colors.white,
      ),
    );
  }

  // Elevated Button Theme
  static ElevatedButtonThemeData _buildElevatedButtonTheme(Brightness brightness) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brightness == Brightness.light
            ? ViernesColors.primary
            : ViernesColors.secondary,
        foregroundColor: brightness == Brightness.light
            ? Colors.white
            : Colors.black,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: ViernesSpacing.lg,
          vertical: ViernesSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
        ),
        elevation: 2,
        shadowColor: brightness == Brightness.light
            ? ViernesColors.primary.withValues(alpha: 0.3)
            : ViernesColors.secondary.withValues(alpha: 0.3),
        textStyle: ViernesTextStyles.bodyText.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  // Outlined Button Theme
  static OutlinedButtonThemeData _buildOutlinedButtonTheme(Brightness brightness) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: brightness == Brightness.light
            ? ViernesColors.primary
            : ViernesColors.secondary,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: ViernesSpacing.lg,
          vertical: ViernesSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
        ),
        side: BorderSide(
          color: brightness == Brightness.light
              ? ViernesColors.primary
              : ViernesColors.secondary,
          width: 1.5,
        ),
        textStyle: ViernesTextStyles.bodyText.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  // Text Button Theme
  static TextButtonThemeData _buildTextButtonTheme(Brightness brightness) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: brightness == Brightness.light
            ? ViernesColors.primary
            : ViernesColors.secondary,
        textStyle: ViernesTextStyles.bodyText.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Input Decoration Theme
  static InputDecorationTheme _buildInputDecorationTheme(Brightness brightness) {
    return InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.light
          ? Colors.white
          : ViernesColors.panelDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
        borderSide: BorderSide(
          color: brightness == Brightness.light
              ? ViernesColors.primaryLight
              : ViernesColors.primaryLight.withValues(alpha: 0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
        borderSide: BorderSide(
          color: brightness == Brightness.light
              ? ViernesColors.primaryLight
              : ViernesColors.primaryLight.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
        borderSide: BorderSide(
          color: brightness == Brightness.light
              ? ViernesColors.primary
              : ViernesColors.secondary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
        borderSide: const BorderSide(
          color: ViernesColors.danger,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
        borderSide: const BorderSide(
          color: ViernesColors.danger,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.md,
        vertical: ViernesSpacing.md,
      ),
      labelStyle: ViernesTextStyles.bodyText.copyWith(
        color: brightness == Brightness.light
            ? ViernesColors.primary.withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.7),
      ),
      hintStyle: ViernesTextStyles.bodyText.copyWith(
        color: brightness == Brightness.light
            ? ViernesColors.primaryLight
            : Colors.white.withValues(alpha: 0.5),
      ),
    );
  }

  // Card Theme
  static CardThemeData _buildCardTheme(Brightness brightness) {
    return CardThemeData(
      color: brightness == Brightness.light
          ? ViernesColors.panelLight
          : ViernesColors.panelDark,
      shadowColor: ViernesColors.primary.withValues(alpha: 0.1),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusLg),
      ),
      margin: const EdgeInsets.all(ViernesSpacing.sm),
    );
  }

  // Bottom Navigation Bar Theme
  static BottomNavigationBarThemeData _buildBottomNavTheme(Brightness brightness) {
    return BottomNavigationBarThemeData(
      backgroundColor: brightness == Brightness.light
          ? ViernesColors.panelLight
          : ViernesColors.panelDark,
      selectedItemColor: brightness == Brightness.light
          ? ViernesColors.primary
          : ViernesColors.secondary,
      unselectedItemColor: ViernesColors.primaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: ViernesTextStyles.bodySmall.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: ViernesTextStyles.bodySmall,
    );
  }

  // Navigation Bar Theme (Material 3)
  static NavigationBarThemeData _buildNavigationBarTheme(Brightness brightness) {
    return NavigationBarThemeData(
      backgroundColor: brightness == Brightness.light
          ? ViernesColors.panelLight
          : ViernesColors.panelDark,
      indicatorColor: brightness == Brightness.light
          ? ViernesColors.primary.withValues(alpha: 0.1)
          : ViernesColors.secondary.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ViernesTextStyles.bodySmall.copyWith(
            color: brightness == Brightness.light
                ? ViernesColors.primary
                : ViernesColors.secondary,
            fontWeight: FontWeight.w600,
          );
        }
        return ViernesTextStyles.bodySmall.copyWith(
          color: ViernesColors.primaryLight,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(
            color: brightness == Brightness.light
                ? ViernesColors.primary
                : ViernesColors.secondary,
          );
        }
        return const IconThemeData(
          color: ViernesColors.primaryLight,
        );
      }),
    );
  }

  // Floating Action Button Theme
  static FloatingActionButtonThemeData _buildFABTheme(Brightness brightness) {
    return FloatingActionButtonThemeData(
      backgroundColor: brightness == Brightness.light
          ? ViernesColors.secondary
          : ViernesColors.secondary,
      foregroundColor: Colors.black,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusFull),
      ),
    );
  }
}