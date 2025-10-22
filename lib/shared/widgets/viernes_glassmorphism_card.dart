import 'package:flutter/material.dart';

/// Viernes Glassmorphism Card
///
/// A card widget with glassmorphism effect matching the auth page aesthetic.
/// Features semi-transparent background, subtle borders, and prominent shadows.
///
/// Automatically handles dark/light mode theming.
///
/// Usage:
/// ```dart
/// ViernesGlassmorphismCard(
///   borderRadius: 24,  // For content cards
///   child: // your content
/// )
///
/// ViernesGlassmorphismCard(
///   borderRadius: 14,  // For stats cards
///   padding: EdgeInsets.all(16),
///   child: // your content
/// )
/// ```
class ViernesGlassmorphismCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const ViernesGlassmorphismCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        // Semi-transparent background (95% opacity)
        color: isDark
            ? const Color(0xFF1a1a1a).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),

        borderRadius: BorderRadius.circular(borderRadius),

        // Subtle border (50% opacity)
        border: Border.all(
          color: isDark
              ? const Color(0xFF2d2d2d).withValues(alpha: 0.5)
              : const Color(0xFFe5e7eb).withValues(alpha: 0.5),
          width: 1,
        ),

        // Prominent shadow
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
  }
}
