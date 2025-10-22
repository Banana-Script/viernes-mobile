import 'package:flutter/material.dart';

/// Viernes Circular Icon Button
///
/// A standardized circular glassmorphism button for icons, matching the
/// auth page theme toggle button aesthetic.
///
/// Automatically handles dark/light mode theming.
///
/// Usage:
/// ```dart
/// ViernesCircularIconButton(
///   onTap: () => doSomething(),
///   child: Icon(
///     Icons.download,
///     color: isDark ? ViernesColors.accent : ViernesColors.primary,
///     size: 20,
///   ),
/// )
/// ```
class ViernesCircularIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double size;

  const ViernesCircularIconButton({
    super.key,
    required this.child,
    required this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1a1a1a).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2d2d2d).withValues(alpha: 0.5)
              : const Color(0xFFe5e7eb).withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 2),
          child: Center(child: child),
        ),
      ),
    );
  }
}
