import 'package:flutter/material.dart';

/// Viernes Spacing System
///
/// Defines the complete Viernes spacing and sizing system including:
/// - Base spacing scale from 0 to 80px
/// - Border radius values
/// - Shadow definitions
/// - Component sizing standards
/// - Layout spacing constants
class ViernesSpacing {
  // Base Spacing Scale (following 4px grid)
  static const double none = 0;           // 0px
  static const double xs = 4.0;           // 4px - 0.25rem
  static const double sm = 8.0;           // 8px - 0.5rem
  static const double md = 16.0;          // 16px - 1rem (base unit)
  static const double lg = 24.0;          // 24px - 1.5rem
  static const double xl = 32.0;          // 32px - 2rem
  static const double xxl = 48.0;         // 48px - 3rem
  static const double xxxl = 64.0;        // 64px - 4rem
  static const double xxxxl = 80.0;       // 80px - 5rem

  // Extended spacing for special cases
  static const double space3 = 12.0;      // 12px - 0.75rem
  static const double space5 = 20.0;      // 20px - 1.25rem
  static const double space6 = 24.0;      // 24px - 1.5rem (alias for lg)
  static const double space10 = 40.0;     // 40px - 2.5rem
  static const double space12 = 48.0;     // 48px - 3rem (alias for xxl)
  static const double space16 = 64.0;     // 64px - 4rem (alias for xxxl)
  static const double space20 = 80.0;     // 80px - 5rem (alias for xxxxl)

  // Custom spacing for specific use cases
  static const double custom = 18.0;      // 18px - Custom spacing (4.5 equivalent)

  // Border Radius System
  static const double radiusSm = 4.0;     // Small radius
  static const double radiusMd = 6.0;     // Default radius
  static const double radiusLg = 8.0;     // Large radius
  static const double radiusXl = 12.0;    // Extra large radius
  static const double radiusXxl = 16.0;   // 2X large radius
  static const double radiusFull = 50.0;  // Circular/pill shape

  // Component-specific spacing

  // Button spacing
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xs,
  );

  static const EdgeInsets buttonPaddingMedium = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  static const EdgeInsets buttonPaddingLarge = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: space5,
  );

  // Input field spacing
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );

  static const EdgeInsets inputPaddingSmall = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xs,
  );

  static const EdgeInsets inputPaddingLarge = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: space5,
  );

  // Card spacing
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(md);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(xl);
  static const EdgeInsets cardMargin = EdgeInsets.all(sm);

  // Screen/Page spacing
  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets screenPaddingVertical = EdgeInsets.symmetric(vertical: md);

  // Section spacing
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: lg,
  );

  // List item spacing
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  static const EdgeInsets listItemPaddingLarge = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );

  // Common gap sizes
  static const double gapXs = xs;          // 4px gap
  static const double gapSm = sm;          // 8px gap
  static const double gapMd = md;          // 16px gap
  static const double gapLg = lg;          // 24px gap
  static const double gapXl = xl;          // 32px gap

  // Layout constants
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 56.0;
  static const double fabSize = 56.0;
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeLarge = 32.0;

  // Minimum touch target size (Material Design guideline)
  static const double minTouchTarget = 48.0;

  // Shadow definitions following Viernes design system

  /// Default shadow for cards and elevated components
  static const List<BoxShadow> defaultShadow = [
    BoxShadow(
      color: Color(0x75E0E6ED), // rgb(224 230 237 / 46%)
      blurRadius: 2,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x75E0E6ED), // rgb(224 230 237 / 46%)
      blurRadius: 7,
      offset: Offset(1, 6),
    ),
  ];

  /// Primary button shadow (before hover)
  static const List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: Color(0x99374151), // rgba(55, 65, 81, 0.6)
      blurRadius: 20,
      offset: Offset(0, 10),
    ),
  ];

  /// Secondary button shadow (before hover)
  static const List<BoxShadow> secondaryShadow = [
    BoxShadow(
      color: Color(0x99FFE61B), // rgba(255, 230, 27, 0.6)
      blurRadius: 20,
      offset: Offset(0, 10),
    ),
  ];

  /// Light shadow for subtle elevation
  static const List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Medium shadow for cards
  static const List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Color(0x33000000), // 20% black
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// Heavy shadow for modals and overlays
  static const List<BoxShadow> heavyShadow = [
    BoxShadow(
      color: Color(0x4D000000), // 30% black
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  // Helper methods for dynamic spacing

  /// Get horizontal padding with specified size
  static EdgeInsets horizontal(double size) => EdgeInsets.symmetric(horizontal: size);

  /// Get vertical padding with specified size
  static EdgeInsets vertical(double size) => EdgeInsets.symmetric(vertical: size);

  /// Get uniform padding with specified size
  static EdgeInsets all(double size) => EdgeInsets.all(size);

  /// Get padding with different horizontal and vertical values
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  /// Get padding with individual values for each side
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);

  /// Get spacing between widgets in a Column
  static Widget verticalSpace(double height) => SizedBox(height: height);

  /// Get spacing between widgets in a Row
  static Widget horizontalSpace(double width) => SizedBox(width: width);

  // Common spacing widgets for convenience
  static Widget get spaceXs => verticalSpace(xs);
  static Widget get spaceSm => verticalSpace(sm);
  static Widget get spaceMd => verticalSpace(md);
  static Widget get spaceLg => verticalSpace(lg);
  static Widget get spaceXl => verticalSpace(xl);
  static Widget get spaceXxl => verticalSpace(xxl);

  static Widget get hSpaceXs => horizontalSpace(xs);
  static Widget get hSpaceSm => horizontalSpace(sm);
  static Widget get hSpaceMd => horizontalSpace(md);
  static Widget get hSpaceLg => horizontalSpace(lg);
  static Widget get hSpaceXl => horizontalSpace(xl);
  static Widget get hSpaceXxl => horizontalSpace(xxl);

  // Responsive spacing based on screen size
  static double getResponsiveSpacing(BuildContext context, {
    double mobile = md,
    double tablet = lg,
    double desktop = xl,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 768) return mobile;
    if (screenWidth < 1024) return tablet;
    return desktop;
  }

  // Complete spacing map for development reference
  static const Map<String, double> spacingMap = {
    'none': none,
    'xs': xs,
    'sm': sm,
    'md': md,
    'lg': lg,
    'xl': xl,
    'xxl': xxl,
    'xxxl': xxxl,
    'xxxxl': xxxxl,
    'space3': space3,
    'space5': space5,
    'space6': space6,
    'space10': space10,
    'space12': space12,
    'space16': space16,
    'space20': space20,
    'custom': custom,
  };

  static const Map<String, double> radiusMap = {
    'sm': radiusSm,
    'md': radiusMd,
    'lg': radiusLg,
    'xl': radiusXl,
    'xxl': radiusXxl,
    'full': radiusFull,
  };
}