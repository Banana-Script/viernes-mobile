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
    if (statusLower.contains('open')) return 'OPEN';
    if (statusLower.contains('pending')) return 'PENDING';
    if (statusLower.contains('resolved')) return 'RESOLVED';
    if (statusLower.contains('abandoned')) return 'ABANDONED';
    return status.toUpperCase();
  }

  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('open')) {
      return const Color(0xFF16A34A); // Success green
    } else if (statusLower.contains('pending')) {
      return const Color(0xFFE2A03F); // Warning orange
    } else if (statusLower.contains('resolved')) {
      return const Color(0xFF2196F3); // Info blue
    } else if (statusLower.contains('abandoned')) {
      return const Color(0xFF64748B); // Gray
    } else {
      return const Color(0xFF9CA3AF); // Default gray
    }
  }
}
