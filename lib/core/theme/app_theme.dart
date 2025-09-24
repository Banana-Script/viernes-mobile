import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

/// Application theme configuration following Viernes design system
class AppTheme {
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme),

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: ViernesColors.primary,
        primaryContainer: ViernesColors.primaryLight,
        secondary: ViernesColors.secondary,
        secondaryContainer: ViernesColors.secondaryLight,
        tertiary: ViernesColors.accent,
        surface: ViernesColors.panelLight,
        surfaceContainer: ViernesColors.bgLight,
        error: ViernesColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: ViernesColors.primary,
        onError: Colors.white,
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: ViernesColors.panelLight,
        foregroundColor: ViernesColors.primary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: ViernesTextStyles.h5.copyWith(
          color: ViernesColors.primary,
        ),
        iconTheme: const IconThemeData(
          color: ViernesColors.primary,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        color: ViernesColors.panelLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ViernesRadius.md),
        ),
        shadowColor: ViernesColors.primary.withValues(alpha: 0.1),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ViernesColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: ViernesColors.primary.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(
            horizontal: ViernesSpacing.space5,
            vertical: ViernesSpacing.space2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ViernesRadius.md),
          ),
          textStyle: ViernesTextStyles.buttonText,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ViernesColors.primary,
          side: const BorderSide(color: ViernesColors.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: ViernesSpacing.space5,
            vertical: ViernesSpacing.space2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ViernesRadius.md),
          ),
          textStyle: ViernesTextStyles.buttonText,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ViernesColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: ViernesSpacing.space4,
            vertical: ViernesSpacing.space2,
          ),
          textStyle: ViernesTextStyles.buttonText,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ViernesColors.panelLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ViernesSpacing.space4,
          vertical: ViernesSpacing.space2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ViernesRadius.md),
          borderSide: const BorderSide(color: ViernesColors.whiteLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ViernesRadius.md),
          borderSide: const BorderSide(color: ViernesColors.whiteLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ViernesRadius.md),
          borderSide: const BorderSide(color: ViernesColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ViernesRadius.md),
          borderSide: const BorderSide(color: ViernesColors.danger),
        ),
        hintStyle: ViernesTextStyles.bodyBase.copyWith(
          color: ViernesColors.textGray,
        ),
        labelStyle: ViernesTextStyles.bodyBase.copyWith(
          color: ViernesColors.textGray,
        ),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ViernesColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: ViernesColors.whiteLight, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ViernesRadius.sm),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ViernesColors.panelLight,
        selectedItemColor: ViernesColors.primary,
        unselectedItemColor: ViernesColors.textGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Tab bar theme
      tabBarTheme: TabBarThemeData(
        labelColor: ViernesColors.primary,
        unselectedLabelColor: ViernesColors.textGray,
        indicatorColor: ViernesColors.secondary,
        labelStyle: ViernesTextStyles.buttonText,
        unselectedLabelStyle: ViernesTextStyles.bodyBase,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: ViernesColors.panelLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ViernesRadius.lg),
        ),
        elevation: 8,
      ),

      // Drawer theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: ViernesColors.panelLight,
        surfaceTintColor: Colors.transparent,
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ViernesSpacing.space4,
          vertical: ViernesSpacing.space1,
        ),
        titleTextStyle: ViernesTextStyles.bodyBase.copyWith(
          color: ViernesColors.primary,
        ),
        subtitleTextStyle: ViernesTextStyles.bodySmall.copyWith(
          color: ViernesColors.textGray,
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: ViernesColors.whiteLight,
        thickness: 1,
        space: 1,
      ),

      // Text theme handled by GoogleFonts above
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: ViernesColors.secondary, // Yellow primary in dark mode
        primaryContainer: ViernesColors.secondaryDark,
        secondary: ViernesColors.primary,
        secondaryContainer: ViernesColors.primaryLight,
        tertiary: ViernesColors.accent,
        surface: ViernesColors.panelDark,
        surfaceContainer: ViernesColors.bgDark,
        error: ViernesColors.danger,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: ViernesColors.panelDark,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: ViernesTextStyles.h5.copyWith(
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        color: ViernesColors.panelDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ViernesRadius.md),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ViernesColors.primaryLight, // Gray in dark mode
          foregroundColor: Colors.black,
          elevation: 2,
          shadowColor: ViernesColors.primaryLight.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(
            horizontal: ViernesSpacing.space5,
            vertical: ViernesSpacing.space2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ViernesRadius.md),
          ),
          textStyle: ViernesTextStyles.buttonText,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ViernesColors.darkPanel,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ViernesSpacing.space4,
          vertical: ViernesSpacing.space2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ViernesRadius.md),
          borderSide: const BorderSide(color: ViernesColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ViernesRadius.md),
          borderSide: const BorderSide(color: ViernesColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ViernesRadius.md),
          borderSide: const BorderSide(color: ViernesColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ViernesRadius.md),
          borderSide: const BorderSide(color: ViernesColors.danger),
        ),
        hintStyle: ViernesTextStyles.bodyBase.copyWith(
          color: ViernesColors.textGray,
        ),
        labelStyle: ViernesTextStyles.bodyBase.copyWith(
          color: ViernesColors.textGray,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ViernesColors.panelDark,
        selectedItemColor: ViernesColors.secondary,
        unselectedItemColor: ViernesColors.textGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Tab bar theme
      tabBarTheme: TabBarThemeData(
        labelColor: ViernesColors.secondary,
        unselectedLabelColor: ViernesColors.textGray,
        indicatorColor: ViernesColors.secondary,
        labelStyle: ViernesTextStyles.buttonText,
        unselectedLabelStyle: ViernesTextStyles.bodyBase,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: ViernesColors.panelDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ViernesRadius.lg),
        ),
        elevation: 8,
      ),

      // Drawer theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: ViernesColors.panelDark,
        surfaceTintColor: Colors.transparent,
      ),

      // Text theme handled by GoogleFonts above
    );
  }

}

/// Custom button styles following Viernes design system
class ViernesButtonStyles {
  ViernesButtonStyles._();

  /// Primary button with Viernes gradient
  static ButtonStyle get viernesGradient => ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(
      horizontal: ViernesSpacing.space6,
      vertical: ViernesSpacing.space3,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ViernesRadius.lg),
    ),
    elevation: 0,
    shadowColor: Colors.transparent,
  ).copyWith(
    backgroundColor: WidgetStateProperty.all(Colors.transparent),
  );

  /// Secondary button (yellow)
  static ButtonStyle get secondary => ElevatedButton.styleFrom(
    backgroundColor: ViernesColors.secondary,
    foregroundColor: Colors.black,
    elevation: 2,
    shadowColor: ViernesColors.secondary.withValues(alpha: 0.6),
    padding: const EdgeInsets.symmetric(
      horizontal: ViernesSpacing.space5,
      vertical: ViernesSpacing.space2,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ViernesRadius.md),
    ),
    textStyle: ViernesTextStyles.buttonText,
  );

  /// Accent button (cyan)
  static ButtonStyle get accent => ElevatedButton.styleFrom(
    backgroundColor: ViernesColors.accent,
    foregroundColor: Colors.black,
    elevation: 2,
    shadowColor: ViernesColors.accent.withValues(alpha: 0.6),
    padding: const EdgeInsets.symmetric(
      horizontal: ViernesSpacing.space5,
      vertical: ViernesSpacing.space2,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ViernesRadius.md),
    ),
    textStyle: ViernesTextStyles.buttonText,
  );
}

/// Custom decoration utilities
class ViernesDecorations {
  ViernesDecorations._();

  /// Viernes gradient decoration
  static const LinearGradient viernesGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ViernesColors.primary, ViernesColors.secondary],
  );

  /// Panel decoration for light theme
  static BoxDecoration get panelLight => BoxDecoration(
    color: ViernesColors.panelLight,
    borderRadius: BorderRadius.circular(ViernesRadius.md),
    boxShadow: [ViernesShadows.cardShadow],
  );

  /// Panel decoration for dark theme
  static BoxDecoration get panelDark => BoxDecoration(
    color: ViernesColors.panelDark,
    borderRadius: BorderRadius.circular(ViernesRadius.md),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        offset: const Offset(0, 2),
        blurRadius: 8,
        spreadRadius: 1,
      ),
    ],
  );
}