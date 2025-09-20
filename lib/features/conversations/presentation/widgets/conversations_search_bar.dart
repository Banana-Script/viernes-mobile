import 'package:flutter/material.dart';

class ConversationsSearchBar extends StatefulWidget {
  final String? hint;
  final Function(String) onSearchChanged;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilters;

  const ConversationsSearchBar({
    super.key,
    this.hint,
    required this.onSearchChanged,
    this.onFilterTap,
    this.hasActiveFilters = false,
  });

  @override
  State<ConversationsSearchBar> createState() => _ConversationsSearchBarState();
}

class _ConversationsSearchBarState extends State<ConversationsSearchBar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.hint ?? 'Search conversations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha:0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha:0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              onChanged: widget.onSearchChanged,
            ),
          ),
          if (widget.onFilterTap != null) ...[
            const SizedBox(width: 12),
            Stack(
              children: [
                IconButton.filled(
                  onPressed: widget.onFilterTap,
                  style: IconButton.styleFrom(
                    backgroundColor: widget.hasActiveFilters
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: widget.hasActiveFilters
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  icon: const Icon(Icons.filter_list),
                ),
                if (widget.hasActiveFilters)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}