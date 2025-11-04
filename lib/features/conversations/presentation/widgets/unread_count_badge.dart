import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_colors.dart';

/// Unread Count Badge Widget
///
/// Displays unread message count in a cyan pill.
class UnreadCountBadge extends StatelessWidget {
  final int count;
  final double? fontSize;
  final double? minWidth;

  const UnreadCountBadge({
    super.key,
    required this.count,
    this.fontSize,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: BoxConstraints(
        minWidth: minWidth ?? 24,
        minHeight: 20,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: ViernesColors.accent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize ?? 11,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
