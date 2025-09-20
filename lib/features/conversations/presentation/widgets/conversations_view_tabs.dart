import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class ConversationsViewTabs extends StatelessWidget {
  final String selectedView;
  final Function(String) onViewChanged;

  const ConversationsViewTabs({
    super.key,
    required this.selectedView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              context,
              'all',
              l10n.allConversations,
              Icons.chat_bubble_outline,
              selectedView == 'all',
              theme,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTab(
              context,
              'my',
              l10n.myConversations,
              Icons.person_outline,
              selectedView == 'my',
              theme,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTab(
              context,
              'viernes',
              l10n.viernesConversations,
              Icons.smart_toy_outlined,
              selectedView == 'viernes',
              theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    bool isSelected,
    ThemeData theme,
  ) {
    return Material(
      color: isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onViewChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}