import 'package:flutter/material.dart';
import 'conversations_list_page.dart';

/// Conversations Page
///
/// Main entry point for the conversations module.
/// This wraps the ConversationsListPage for navigation.
class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConversationsListPage();
  }
}
