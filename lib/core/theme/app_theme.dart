import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Viernes Brand Theme - Exact match to web app branding
/// Colors and styling matching the React/Tailwind configuration
class AppTheme {
  // === EXACT VIERNES BRAND COLORS FROM WEB APP ===

  // Primary colors (exact hex matches)
  static const Color viernesGray = Color(0xFF374151);           // #374151 - Primary gray
  static const Color viernesGrayLight = Color(0xFF9CA3AF);      // #9CA3AF - Light gray
  static const Color viernesGrayDark = Color(0xFF1F2937);       // #1F2937 - Dark gray

  static const Color viernesYellow = Color(0xFFFFE61B);         // #FFE61B - Secondary yellow
  static const Color viernesYellowLight = Color(0xFFFFF04D);    // #FFF04D - Light yellow
  static const Color viernesYellowDark = Color(0xFFE6CF00);     // #E6CF00 - Dark yellow

  static const Color viernesGreen = Color(0xFF16A34A);          // #16a34a - System green
  static const Color viernesGreenLight = Color(0xFF22C55E);     // #22c55e
  static const Color viernesGreenDark = Color(0xFF15803D);      // #15803d

  // System colors from web app
  static const Color primary = viernesGray;                     // #374151 (Dark gray)
  static const Color secondary = viernesYellow;                 // #FFE61B (Yellow)
  static const Color accent = Color(0xFF51F5F8);                // #51f5f8 (Cyan)
  static const Color success = viernesGreen;                    // #16a34a (Green)
  static const Color danger = Color(0xFFE7515A);                // #e7515a (Red)
  static const Color warning = Color(0xFFE2A03F);               // #e2a03f (Orange)

  // Gradient colors for the signature Viernes gradient
  static const List<Color> viernesGradientColors = [
    viernesGray,    // #374151 at 0%
    viernesYellow,  // #FFE61B at 100%
  ];

  // Gradient definition (135deg, #374151 0%, #FFE61B 100%)
  static const LinearGradient viernesGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: viernesGradientColors,
    stops: [0.0, 1.0],
  );

  // === LIGHT THEME COLORS ===
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightOnSurface = viernesGrayDark;           // Better contrast with Viernes gray
  static const Color lightOnBackground = viernesGray;            // Primary Viernes gray
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);           // Subtle border color

  // === DARK THEME COLORS ===
  static const Color darkBackground = viernesGrayDark;           // Using Viernes dark gray
  static const Color darkSurface = viernesGray;                 // Using Viernes primary gray
  static const Color darkOnSurface = Color(0xFFF9FAFB);         // High contrast white
  static const Color darkOnBackground = viernesGrayLight;       // Viernes light gray
  static const Color darkCardBackground = viernesGray;
  static const Color darkBorder = Color(0xFF4B5563);            // Darker border for dark mode

  // === NUNITO FONT CONFIGURATION ===
  // Exact match to web app font family: Nunito (sans-serif)
  static TextTheme get _textTheme => GoogleFonts.nunitoTextTheme();

  // Custom text styles matching web app
  static TextStyle get headingBold => GoogleFonts.nunito(
    fontWeight: FontWeight.w700,
    color: viernesGrayDark,
  );

  static TextStyle get bodyRegular => GoogleFonts.nunito(
    fontWeight: FontWeight.w400,
    color: viernesGray,
  );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
    fontWeight: FontWeight.w500,
    color: viernesGray,
  );

  static TextStyle get buttonText => GoogleFonts.nunito(
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // === LIGHT THEME ===
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,                    // Viernes gray (#374151)
        secondary: secondary,                // Viernes yellow (#FFE61B)
        tertiary: success,                   // Viernes green (#16a34a)
        surface: lightSurface,
        onPrimary: Colors.white,
        onSecondary: viernesGrayDark,        // Dark text on yellow
        onTertiary: Colors.white,
        onSurface: lightOnSurface,
        error: danger,
        onError: Colors.white,
        outline: lightBorder,
      ),
      textTheme: _textTheme.apply(
        bodyColor: lightOnBackground,
        displayColor: lightOnSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _textTheme.headlineSmall?.copyWith(
          color: lightOnSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,                    // Viernes gray primary
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: buttonText.copyWith(fontSize: 14),
          elevation: 2,
          shadowColor: primary.withValues(alpha: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: bodyMedium.copyWith(fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        filled: true,
        fillColor: lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // === DARK THEME ===
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: accent,                     // Cyan for dark mode primary
        secondary: secondary,                // Viernes yellow
        tertiary: success,                   // Viernes green
        surface: darkSurface,
        onPrimary: viernesGrayDark,          // Dark text on cyan
        onSecondary: viernesGrayDark,        // Dark text on yellow
        onTertiary: Colors.white,
        onSurface: darkOnSurface,
        error: danger,
        onError: Colors.white,
        outline: darkBorder,
      ),
      textTheme: _textTheme.apply(
        bodyColor: darkOnBackground,
        displayColor: darkOnSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _textTheme.headlineSmall?.copyWith(
          color: darkOnSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,                     // Cyan for dark mode
          foregroundColor: viernesGrayDark,            // Dark text on cyan
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: buttonText.copyWith(
            fontSize: 14,
            color: viernesGrayDark,
          ),
          elevation: 2,
          shadowColor: accent.withValues(alpha: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: const BorderSide(color: accent, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: bodyMedium.copyWith(
            fontSize: 14,
            color: accent,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

/// Viernes Custom Theme Extensions
/// Additional styling components matching the web app
extension ViernesThemeExtension on ThemeData {
  /// Signature Viernes gradient button style
  /// Matches: background: linear-gradient(135deg, #374151 0%, #FFE61B 100%)
  ButtonStyle get viernesGradientButton => ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 4,
    shadowColor: AppTheme.viernesGray.withValues(alpha: 0.4),
  ).copyWith(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return null; // Use gradient
      }
      return null; // Use gradient
    }),
    foregroundColor: WidgetStateProperty.all(Colors.white),
    textStyle: WidgetStateProperty.all(
      AppTheme.buttonText.copyWith(
        fontSize: 14,
        letterSpacing: 0.5,
      ),
    ),
  );

  /// Viernes card style
  BoxDecoration get viernesCard => BoxDecoration(
    color: colorScheme.surface,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: colorScheme.outline.withValues(alpha: 0.2),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: AppTheme.viernesGray.withValues(alpha: 0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Success color variations
  Color get successLight => AppTheme.viernesGreenLight;
  Color get successDark => AppTheme.viernesGreenDark;

  /// Warning color variations
  Color get warningLight => const Color(0xFFFBBF24);
  Color get warningDark => const Color(0xFFD97706);
}

/// Custom Viernes Gradient Button Widget
/// Matches the exact .btn-viernes style from the web app
class ViernesGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool isLoading;

  const ViernesGradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.padding,
    this.width,
    this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 48,
      decoration: BoxDecoration(
        gradient: AppTheme.viernesGradient,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.viernesGray.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isLoading ? null : onPressed,
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      text.toUpperCase(),
                      style: AppTheme.buttonText.copyWith(
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}