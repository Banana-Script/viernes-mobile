import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';

/// Agents Badge Widget
///
/// Displays number of assigned agents.
class AgentsBadge extends StatelessWidget {
  final int count;
  final double? fontSize;

  const AgentsBadge({
    super.key,
    required this.count,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.sm,
        vertical: ViernesSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: ViernesColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusLg),
        border: Border.all(
          color: ViernesColors.accent.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.person,
            size: 10,
            color: ViernesColors.accent,
          ),
          const SizedBox(width: 4),
          Text(
            '+$count',
            style: ViernesTextStyles.labelSmall.copyWith(
              color: ViernesColors.accent,
              fontSize: fontSize ?? 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
