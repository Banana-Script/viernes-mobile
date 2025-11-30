import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_spacing.dart';

/// Viernes Page Header
///
/// A unified page header widget for list pages (Customers, Conversations, etc.)
/// with consistent styling across the app.
///
/// Features:
/// - Centered title with capitalized style
/// - Optional leading and trailing widgets
/// - Theme-aware colors (light/dark mode)
/// - Consistent height and padding
class ViernesPageHeader extends StatelessWidget {
  /// The page title (displayed capitalized, e.g., 'Customers')
  final String title;

  /// Height of the header container (default: 80)
  final double height;

  /// Optional widget on the right side (e.g., filter button)
  final Widget? trailing;

  /// Optional widget on the left side (e.g., back button)
  final Widget? leading;

  /// Custom padding for the header
  final EdgeInsets? padding;

  const ViernesPageHeader({
    super.key,
    required this.title,
    this.height = 80,
    this.trailing,
    this.leading,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      padding: padding ??
          const EdgeInsets.fromLTRB(
            ViernesSpacing.md,
            ViernesSpacing.lg,
            ViernesSpacing.md,
            ViernesSpacing.md,
          ),
      child: Stack(
        children: [
          // Leading widget (left side)
          if (leading != null)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(child: leading!),
            ),

          // Center: Title
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
              ),
            ),
          ),

          // Trailing widget (right side)
          if (trailing != null)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(child: trailing!),
            ),
        ],
      ),
    );
  }
}
