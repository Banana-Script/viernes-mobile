import 'package:flutter/material.dart';

/// Main Interest Panel Widget
///
/// TODO: Agent 2 to implement
/// This widget should display main interest and other topics.
///
/// Expected features:
/// - Large highlighted badge for main interest
/// - Multiple badges for other topics (comma-separated)
/// - Parse multilingual JSON
/// - Support both light and dark themes
/// - Includes NPS visualization
class MainInterestPanel extends StatelessWidget {
  final dynamic customer;
  final bool isDark;
  final String languageCode;

  const MainInterestPanel({
    super.key,
    required this.customer,
    required this.isDark,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('TODO: Agent 2 - Implement MainInterestPanel'),
    );
  }
}
