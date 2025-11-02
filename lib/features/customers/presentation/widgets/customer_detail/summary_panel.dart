import 'package:flutter/material.dart';

/// Summary Panel Widget
///
/// TODO: Agent 1 to implement
/// This widget should display the customer's summary profile
/// with proper parsing of multilingual JSON data.
///
/// Expected features:
/// - Display 'summary_profile' insight field
/// - Parse multilingual JSON
/// - Support both light and dark themes
/// - Show full paragraph text with good typography
class SummaryPanel extends StatelessWidget {
  final dynamic customer;
  final bool isDark;
  final String languageCode;

  const SummaryPanel({
    super.key,
    required this.customer,
    required this.isDark,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('TODO: Agent 1 - Implement SummaryPanel'),
    );
  }
}
