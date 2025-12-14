import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';

/// Status Badge Widget
///
/// Displays conversation status with appropriate color coding.
class StatusBadge extends StatelessWidget {
  final String status;
  final Color? customColor;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.customColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final color = customColor ?? _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.sm,
        vertical: ViernesSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusLg),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusLabel(status).toUpperCase(),
        style: ViernesTextStyles.labelSmall.copyWith(
          color: color,
          fontSize: fontSize ?? 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    final statusLower = status.toLowerCase();
    // Started / Open
    if (statusLower.contains('started') || statusLower.contains('open')) {
      return 'STARTED';
    }
    // In progress / Pending
    if (statusLower.contains('progress') || statusLower.contains('pending')) {
      return 'IN PROGRESS';
    }
    // Completed / Resolved (successful)
    if (statusLower == 'completed' || statusLower.contains('resolved')) {
      return 'COMPLETED';
    }
    // Completed Unsuccessfully / Abandoned
    if (statusLower.contains('unsuccessfully') || statusLower.contains('abandoned')) {
      return 'CLOSED';
    }
    return status.toUpperCase();
  }

  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    // Started / Open - Cyan (needs attention, new conversation)
    if (statusLower.contains('started') || statusLower.contains('open')) {
      return const Color(0xFF51F5F8); // Accent cyan
    }
    // In progress / Pending - Orange (active work)
    else if (statusLower.contains('progress') || statusLower.contains('pending')) {
      return const Color(0xFFE2A03F); // Warning orange
    }
    // Completed / Resolved (successful) - Green (success)
    else if (statusLower == 'completed' || statusLower.contains('resolved')) {
      return const Color(0xFF16A34A); // Success green
    }
    // Completed Unsuccessfully / Abandoned - Red (negative outcome)
    else if (statusLower.contains('unsuccessfully') || statusLower.contains('abandoned')) {
      return const Color(0xFFE7515A); // Danger red
    }
    // Default
    else {
      return const Color(0xFF9CA3AF); // Default gray
    }
  }
}
