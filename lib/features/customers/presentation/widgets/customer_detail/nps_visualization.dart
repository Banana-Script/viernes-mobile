import 'package:flutter/material.dart';

/// NPS Visualization Widget
///
/// TODO: Agent 2 to implement
/// This widget should display the Net Promoter Score with visual scale.
///
/// Expected features:
/// - Large number display (1-10 scale)
/// - Visual scale with gradient (red -> yellow -> green)
/// - Labels: Detractors (1-6), Passive (7-8), Promoters (9-10)
/// - Color coding based on score
/// - Support both light and dark themes
class NPSVisualization extends StatelessWidget {
  final int npsScore;
  final bool isDark;

  const NPSVisualization({
    super.key,
    required this.npsScore,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('TODO: Agent 2 - Implement NPSVisualization'),
    );
  }
}
