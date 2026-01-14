import 'package:flutter/material.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';

/// Priority Badge Widget
///
/// Displays conversation priority with icon and color coding.
class PriorityBadge extends StatelessWidget {
  final String? priority;
  final double? fontSize;
  final double? iconSize;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.fontSize,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    if (priority == null || priority!.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final config = _getPriorityConfig(priority!);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.sm,
        vertical: ViernesSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusLg),
        border: Border.all(
          color: config.color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: iconSize ?? 10,
            color: config.color,
          ),
          const SizedBox(width: 4),
          Text(
            _getLocalizedPriority(priority!, l10n),
            style: ViernesTextStyles.labelSmall.copyWith(
              color: config.color,
              fontSize: fontSize ?? 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedPriority(String priority, AppLocalizations? l10n) {
    switch (priority.toLowerCase()) {
      case 'high':
        return l10n?.priorityHigh ?? 'HIGH';
      case 'medium':
        return l10n?.priorityMedium ?? 'MEDIUM';
      case 'low':
        return l10n?.priorityLow ?? 'LOW';
      default:
        return priority.toUpperCase();
    }
  }

  _PriorityConfig _getPriorityConfig(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const _PriorityConfig(
          color: Color(0xFFE7515A), // Danger red
          icon: Icons.arrow_upward,
        );
      case 'medium':
        return const _PriorityConfig(
          color: Color(0xFFE2A03F), // Warning orange
          icon: Icons.remove,
        );
      case 'low':
        return const _PriorityConfig(
          color: Color(0xFF2196F3), // Info blue
          icon: Icons.arrow_downward,
        );
      default:
        return const _PriorityConfig(
          color: Color(0xFF9CA3AF), // Gray
          icon: Icons.remove,
        );
    }
  }
}

class _PriorityConfig {
  final Color color;
  final IconData icon;

  const _PriorityConfig({
    required this.color,
    required this.icon,
  });
}
