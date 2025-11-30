import 'package:flutter/material.dart';

/// LED Edge Indicator Variant Types
enum LedIndicatorVariant {
  /// Dual vertical bars on left and right edges (default)
  dualVertical,

  /// Single vertical bar on left edge only
  singleAccent,

  /// Horizontal bars on top and bottom edges
  horizontalBars,

  /// Full frame with corner emphasis
  fullFrame,
}

/// LED Edge Indicator Configuration
class LedIndicatorConfig {
  /// Width of the LED edge bars (in pixels)
  final double edgeWidth;

  /// Whether to enable breathing animation
  final bool enableAnimation;

  /// Duration of the breathing animation
  final Duration animationDuration;

  /// Minimum opacity during breathing animation
  final double minOpacity;

  /// Maximum opacity during breathing animation
  final double maxOpacity;

  /// Blur radius for the LED glow effect (first layer)
  final double glowBlurRadius;

  /// Blur radius for extended diffusion (second layer)
  final double diffusionBlurRadius;

  /// Spread radius for the glow effect
  final double glowSpreadRadius;

  const LedIndicatorConfig({
    this.edgeWidth = 4.0,
    this.enableAnimation = true,
    this.animationDuration = const Duration(seconds: 3),
    this.minOpacity = 0.4,
    this.maxOpacity = 0.8,
    this.glowBlurRadius = 16.0,
    this.diffusionBlurRadius = 32.0,
    this.glowSpreadRadius = 3.0,
  });

  /// Default configuration with ultra-thin edges and breathing animation
  static const defaultConfig = LedIndicatorConfig();

  /// Minimal configuration with no animation
  static const minimalConfig = LedIndicatorConfig(
    edgeWidth: 2.0,
    enableAnimation: false,
  );

  /// Prominent configuration with thicker edges and stronger glow
  static const prominentConfig = LedIndicatorConfig(
    edgeWidth: 6.0,
    glowBlurRadius: 16.0,
    diffusionBlurRadius: 32.0,
    glowSpreadRadius: 3.0,
  );
}

/// LED Indicator Colors for Active/Inactive States
class LedIndicatorColors {
  /// Active state color for light mode
  static const Color activeLightMode = Color(0xFF16A34A); // ViernesColors.success

  /// Active state color for dark mode (brighter for visibility)
  static const Color activeDarkMode = Color(0xFF22C55E);

  /// Inactive state color for light mode
  static const Color inactiveLightMode = Color(0xFFE7515A); // ViernesColors.danger

  /// Inactive state color for dark mode (brighter for visibility)
  static const Color inactiveDarkMode = Color(0xFFF87171);

  /// Get the appropriate LED color based on theme and state
  static Color getLedColor(BuildContext context, bool isActive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isActive) {
      return isDark ? activeDarkMode : activeLightMode;
    } else {
      return isDark ? inactiveDarkMode : inactiveLightMode;
    }
  }
}
