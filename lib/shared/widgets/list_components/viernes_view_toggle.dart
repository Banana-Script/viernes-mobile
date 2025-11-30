import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_text_styles.dart';
import '../../../core/theme/viernes_spacing.dart';

/// Viernes View Toggle Widget
///
/// A two-option toggle switch for switching between views (e.g., All/My).
///
/// Features:
/// - Smooth animation between states
/// - Glassmorphism design
/// - Gradient selection indicator
/// - Theme-aware colors (light/dark mode)
class ViernesViewToggle extends StatelessWidget {
  /// Label for the first option
  final String firstOptionLabel;

  /// Label for the second option
  final String secondOptionLabel;

  /// Whether the first option is currently selected
  final bool isFirstOptionSelected;

  /// Callback when first option is tapped
  final VoidCallback onFirstOptionTap;

  /// Callback when second option is tapped
  final VoidCallback onSecondOptionTap;

  /// Animation duration for selection change
  final Duration animationDuration;

  const ViernesViewToggle({
    super.key,
    required this.firstOptionLabel,
    required this.secondOptionLabel,
    required this.isFirstOptionSelected,
    required this.onFirstOptionTap,
    required this.onSecondOptionTap,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1a1a1a).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2d2d2d).withValues(alpha: 0.5)
              : const Color(0xFFe5e7eb).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildOption(
            label: firstOptionLabel,
            isSelected: isFirstOptionSelected,
            onTap: onFirstOptionTap,
            isDark: isDark,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(ViernesSpacing.radius14 - 1),
              bottomLeft: Radius.circular(ViernesSpacing.radius14 - 1),
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: isDark
                ? const Color(0xFF2d2d2d).withValues(alpha: 0.5)
                : const Color(0xFFe5e7eb).withValues(alpha: 0.5),
          ),
          _buildOption(
            label: secondOptionLabel,
            isSelected: !isFirstOptionSelected,
            onTap: onSecondOptionTap,
            isDark: isDark,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(ViernesSpacing.radius14 - 1),
              bottomRight: Radius.circular(ViernesSpacing.radius14 - 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required BorderRadius borderRadius,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: animationDuration,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    ViernesColors.secondary.withValues(alpha: 0.7),
                    ViernesColors.accent.withValues(alpha: 0.7),
                  ],
                )
              : null,
          borderRadius: borderRadius,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ViernesSpacing.md,
                vertical: ViernesSpacing.space3,
              ),
              child: Text(
                label,
                style: ViernesTextStyles.buttonSmall.copyWith(
                  color: isSelected
                      ? Colors.black
                      : ViernesColors.getTextColor(isDark),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
