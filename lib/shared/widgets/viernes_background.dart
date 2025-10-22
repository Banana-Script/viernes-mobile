import 'package:flutter/material.dart';

/// Viernes Background
///
/// A gradient background widget that provides the standard Viernes
/// background gradient used across auth pages and the dashboard.
///
/// Automatically handles dark/light mode theming.
class ViernesBackground extends StatelessWidget {
  final Widget child;

  const ViernesBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF060818), const Color(0xFF0a0f1e)]
              : [const Color(0xFFfafafa), const Color(0xFFffffff)],
        ),
      ),
      child: child,
    );
  }
}
