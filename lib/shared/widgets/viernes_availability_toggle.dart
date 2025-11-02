import 'package:flutter/material.dart';
import '../../core/theme/viernes_colors.dart';
import '../../core/theme/viernes_spacing.dart';
import '../../core/theme/viernes_text_styles.dart';

/// Viernes Availability Toggle Widget
///
/// A modern availability toggle for agents to mark their availability status.
/// Features glassmorphism design, smooth animations, and clear visual feedback.
///
/// ## States
/// - **Available (010)**: Agent is active and can receive consultations
/// - **Unavailable (020)**: Agent is inactive and cannot receive consultations
/// - **Loading**: Visual feedback while updating status
/// - **Error**: Visual indication when update fails
///
/// ## Design Features
/// - Glassmorphism style consistent with ViernesThemeToggle
/// - Smooth state transitions with animations
/// - Clear visual indicators (icons, colors, text)
/// - Responsive sizing for different screen sizes
/// - Accessibility support with semantic labels
///
/// ## Usage
/// ```dart
/// ViernesAvailabilityToggle(
///   isAvailable: true,
///   isLoading: false,
///   onToggle: (newValue) {
///     // Handle availability change
///     updateAvailability(newValue);
///   },
/// )
///
/// // With label variant
/// ViernesAvailabilityToggle(
///   isAvailable: false,
///   isLoading: false,
///   showLabel: true,
///   onToggle: (newValue) {
///     // Handle availability change
///   },
/// )
/// ```
class ViernesAvailabilityToggle extends StatelessWidget {
  /// Whether the agent is currently available
  final bool isAvailable;

  /// Whether the toggle is in loading state
  final bool isLoading;

  /// Callback when toggle state changes
  final Function(bool)? onToggle;

  /// Whether to show the status label
  final bool showLabel;

  /// Size of the toggle (width)
  final double size;

  /// Optional margin around the toggle
  final EdgeInsets? margin;

  /// Optional error message to display
  final String? errorMessage;

  const ViernesAvailabilityToggle({
    super.key,
    required this.isAvailable,
    this.isLoading = false,
    this.onToggle,
    this.showLabel = false,
    this.size = 56.0,
    this.margin,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          showLabel
              ? _buildWithLabel(context, isDark)
              : _buildToggleOnly(context, isDark),
          if (errorMessage != null) ...[
            const SizedBox(height: ViernesSpacing.sm),
            _buildErrorMessage(context, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleOnly(BuildContext context, bool isDark) {
    final canToggle = !isLoading && onToggle != null;

    return Semantics(
      label: 'Availability toggle',
      value: isAvailable ? 'Available' : 'Unavailable',
      button: true,
      enabled: canToggle,
      child: GestureDetector(
        onTap: canToggle ? () => onToggle!(!isAvailable) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: size,
          height: size * 0.6, // Oval shape matching ViernesThemeToggle
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size / 2),
            color: _getBackgroundColor(isDark),
            border: Border.all(
              color: _getBorderColor(isDark),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _getShadowColor(isDark),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Sliding indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: isAvailable ? Alignment.centerRight : Alignment.centerLeft,
                padding: const EdgeInsets.all(4),
                child: Container(
                  width: size * 0.4,
                  height: size * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _getIndicatorGradient(),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? _buildLoadingIndicator()
                      : Icon(
                          _getStatusIcon(),
                          color: _getIconColor(),
                          size: size * 0.2,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWithLabel(BuildContext context, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToggleOnly(context, isDark),
        const SizedBox(width: ViernesSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Availability',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
              ),
            ),
            Text(
              _getStatusText(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _getStatusTextColor(isDark),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorMessage(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.sm,
        vertical: ViernesSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: ViernesColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusSm),
        border: Border.all(
          color: ViernesColors.danger.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 16,
            color: ViernesColors.danger,
          ),
          const SizedBox(width: ViernesSpacing.xs),
          Flexible(
            child: Text(
              errorMessage!,
              style: ViernesTextStyles.bodySmall.copyWith(
                color: ViernesColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: SizedBox(
        width: size * 0.15,
        height: size * 0.15,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getIconColor()),
        ),
      ),
    );
  }

  // Helper methods for colors and styles

  Color _getBackgroundColor(bool isDark) {
    if (errorMessage != null) {
      return isDark ? ViernesColors.panelDark : ViernesColors.panelLight;
    }
    return isDark ? ViernesColors.panelDark : ViernesColors.panelLight;
  }

  Color _getBorderColor(bool isDark) {
    if (errorMessage != null) {
      return ViernesColors.danger;
    }
    if (isAvailable) {
      return ViernesColors.success;
    }
    return isDark ? ViernesColors.accent.withValues(alpha: 0.5) : ViernesColors.primaryLight;
  }

  Color _getShadowColor(bool isDark) {
    if (errorMessage != null) {
      return ViernesColors.danger.withValues(alpha: 0.3);
    }
    if (isAvailable) {
      return ViernesColors.success.withValues(alpha: 0.3);
    }
    return (isDark ? ViernesColors.accent : ViernesColors.primary).withValues(alpha: 0.2);
  }

  LinearGradient _getIndicatorGradient() {
    if (isAvailable) {
      return LinearGradient(
        colors: [
          ViernesColors.success.withValues(alpha: 0.8),
          ViernesColors.successDark.withValues(alpha: 0.8),
        ],
      );
    } else {
      return LinearGradient(
        colors: [
          ViernesColors.primaryLight.withValues(alpha: 0.8),
          ViernesColors.primary.withValues(alpha: 0.8),
        ],
      );
    }
  }

  IconData _getStatusIcon() {
    if (isAvailable) {
      return Icons.check_circle;
    } else {
      return Icons.cancel;
    }
  }

  Color _getIconColor() {
    if (isAvailable) {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }

  String _getStatusText() {
    if (isLoading) {
      return 'Updating...';
    }
    return isAvailable ? 'Available' : 'Unavailable';
  }

  Color _getStatusTextColor(bool isDark) {
    if (errorMessage != null) {
      return ViernesColors.danger;
    }
    if (isAvailable) {
      return ViernesColors.success;
    }
    return ViernesColors.getTextColor(isDark);
  }
}

/// Availability card widget for use in profile page
///
/// A more comprehensive availability control that combines the toggle
/// with additional context and description in a glassmorphism card.
///
/// Usage:
/// ```dart
/// ViernesAvailabilityCard(
///   isAvailable: true,
///   isLoading: false,
///   onToggle: (newValue) {
///     // Handle availability change
///   },
/// )
/// ```
class ViernesAvailabilityCard extends StatelessWidget {
  /// Whether the agent is currently available
  final bool isAvailable;

  /// Whether the toggle is in loading state
  final bool isLoading;

  /// Callback when toggle state changes
  final Function(bool)? onToggle;

  /// Optional error message to display
  final String? errorMessage;

  const ViernesAvailabilityCard({
    super.key,
    required this.isAvailable,
    this.isLoading = false,
    this.onToggle,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(ViernesSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1a1a1a).withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusXl),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2d2d2d).withValues(alpha: 0.3)
              : const Color(0xFFe5e7eb).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: isAvailable
                  ? LinearGradient(
                      colors: [
                        ViernesColors.success.withValues(alpha: 0.3),
                        ViernesColors.successDark.withValues(alpha: 0.3),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        ViernesColors.primaryLight.withValues(alpha: 0.2),
                        ViernesColors.primary.withValues(alpha: 0.2),
                      ],
                    ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAvailable ? Icons.check_circle : Icons.cancel,
              color: isAvailable ? ViernesColors.success : ViernesColors.primaryLight,
              size: 24,
            ),
          ),
          const SizedBox(width: ViernesSpacing.md),

          // Title and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Availability Status',
                  style: ViernesTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ViernesColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAvailable
                      ? 'You are available to receive consultations'
                      : 'You are not available for consultations',
                  style: ViernesTextStyles.bodySmall.copyWith(
                    color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Toggle
          ViernesAvailabilityToggle(
            isAvailable: isAvailable,
            isLoading: isLoading,
            onToggle: onToggle,
            errorMessage: errorMessage,
          ),
        ],
      ),
    );
  }
}
