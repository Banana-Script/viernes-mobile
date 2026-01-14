import 'package:flutter/material.dart';
import '../../../../../core/theme/viernes_colors.dart';
import '../../../../../core/theme/viernes_spacing.dart';
import '../../../../../core/theme/viernes_text_styles.dart';
import '../../../../../gen_l10n/app_localizations.dart';
import '../../../domain/entities/internal_note_entity.dart';
import 'internal_note_card.dart';
import 'internal_note_modal.dart';
import 'delete_note_dialog.dart';

/// Internal Notes Panel
///
/// A bottom sheet panel for viewing and managing internal notes.
class InternalNotesPanel extends StatefulWidget {
  final int conversationId;
  final List<InternalNoteEntity> notes;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final int? currentUserId;
  final Future<void> Function()? onLoadMore;
  final Future<void> Function()? onRefresh;
  final Future<bool> Function(String content)? onCreateNote;
  final Future<bool> Function(int noteId, String content)? onUpdateNote;
  final Future<bool> Function(int noteId)? onDeleteNote;

  const InternalNotesPanel({
    super.key,
    required this.conversationId,
    this.notes = const [],
    this.isLoading = false,
    this.hasMore = false,
    this.errorMessage,
    this.currentUserId,
    this.onLoadMore,
    this.onRefresh,
    this.onCreateNote,
    this.onUpdateNote,
    this.onDeleteNote,
  });

  /// Show the panel as a bottom sheet
  static Future<void> show({
    required BuildContext context,
    required int conversationId,
    required List<InternalNoteEntity> notes,
    bool isLoading = false,
    bool hasMore = false,
    String? errorMessage,
    int? currentUserId,
    Future<void> Function()? onLoadMore,
    Future<void> Function()? onRefresh,
    Future<bool> Function(String content)? onCreateNote,
    Future<bool> Function(int noteId, String content)? onUpdateNote,
    Future<bool> Function(int noteId)? onDeleteNote,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => InternalNotesPanel(
          conversationId: conversationId,
          notes: notes,
          isLoading: isLoading,
          hasMore: hasMore,
          errorMessage: errorMessage,
          currentUserId: currentUserId,
          onLoadMore: onLoadMore,
          onRefresh: onRefresh,
          onCreateNote: onCreateNote,
          onUpdateNote: onUpdateNote,
          onDeleteNote: onDeleteNote,
        ),
      ),
    );
  }

  @override
  State<InternalNotesPanel> createState() => _InternalNotesPanelState();
}

class _InternalNotesPanelState extends State<InternalNotesPanel> {
  final ScrollController _scrollController = ScrollController();
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        widget.hasMore &&
        !widget.isLoading) {
      widget.onLoadMore?.call();
    }
  }

  Future<void> _handleCreateNote() async {
    final l10n = AppLocalizations.of(context);
    final result = await InternalNoteModal.show(
      context: context,
      title: l10n?.newInternalNoteTitle ?? 'New internal note',
    );

    if (result != null && result.isNotEmpty && widget.onCreateNote != null) {
      setState(() => _isCreating = true);
      final success = await widget.onCreateNote!(result);
      if (mounted) {
        setState(() => _isCreating = false);
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.errorCreateNote ?? 'Error creating note'),
              backgroundColor: ViernesColors.danger,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleEditNote(InternalNoteEntity note) async {
    final l10n = AppLocalizations.of(context);
    final result = await InternalNoteModal.show(
      context: context,
      title: l10n?.editInternalNoteTitle ?? 'Edit note',
      initialContent: note.content,
    );

    if (result != null && result.isNotEmpty && widget.onUpdateNote != null) {
      final success = await widget.onUpdateNote!(note.id, result);
      if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.errorUpdateNote ?? 'Error updating note'),
            backgroundColor: ViernesColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteNote(InternalNoteEntity note) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await DeleteNoteDialog.show(context: context);

    if (confirmed == true && widget.onDeleteNote != null) {
      final success = await widget.onDeleteNote!(note.id);
      if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.errorDeleteNote ?? 'Error deleting note'),
            backgroundColor: ViernesColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: ViernesColors.getControlBackground(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: ViernesSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(ViernesSpacing.md),
              child: Row(
                children: [
                  const Icon(
                    Icons.note_alt_outlined,
                    color: ViernesColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: ViernesSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n?.internalNotesTitle ?? 'Internal notes',
                      style: ViernesTextStyles.h6.copyWith(
                        color: ViernesColors.getTextColor(isDark),
                      ),
                    ),
                  ),
                  // Add button
                  IconButton(
                    onPressed: _isCreating ? null : _handleCreateNote,
                    icon: _isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.add_circle_outline,
                            color: ViernesColors.primary,
                          ),
                    tooltip: l10n?.addNoteTooltip ?? 'Add note',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: _buildContent(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    final l10n = AppLocalizations.of(context);

    // Error state
    if (widget.errorMessage != null && widget.notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: ViernesColors.danger.withValues(alpha: 0.5),
            ),
            const SizedBox(height: ViernesSpacing.md),
            Text(
              widget.errorMessage!,
              style: ViernesTextStyles.bodyText.copyWith(
                color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ViernesSpacing.md),
            TextButton(
              onPressed: widget.onRefresh,
              child: Text(l10n?.retry ?? 'Retry'),
            ),
          ],
        ),
      );
    }

    // Loading state (initial)
    if (widget.isLoading && widget.notes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty state
    if (widget.notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.3),
            ),
            const SizedBox(height: ViernesSpacing.md),
            Text(
              l10n?.noInternalNotesTitle ?? 'No internal notes',
              style: ViernesTextStyles.h6.copyWith(
                color: ViernesColors.getTextColor(isDark),
              ),
            ),
            const SizedBox(height: ViernesSpacing.sm),
            Text(
              l10n?.internalNotesAgentsOnly ?? 'Internal notes are only visible to agents',
              style: ViernesTextStyles.bodySmall.copyWith(
                color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ViernesSpacing.lg),
            ElevatedButton.icon(
              onPressed: _handleCreateNote,
              icon: const Icon(Icons.add),
              label: Text(l10n?.addNoteButton ?? 'Add note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ViernesColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Notes list
    return RefreshIndicator(
      onRefresh: () async {
        await widget.onRefresh?.call();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(ViernesSpacing.md),
        itemCount: widget.notes.length + (widget.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= widget.notes.length) {
            return const Padding(
              padding: EdgeInsets.all(ViernesSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final note = widget.notes[index];
          final canEdit = widget.currentUserId == note.agentId;

          return Padding(
            padding: const EdgeInsets.only(bottom: ViernesSpacing.sm),
            child: InternalNoteCard(
              note: note,
              canEdit: canEdit,
              onEdit: () => _handleEditNote(note),
              onDelete: () => _handleDeleteNote(note),
            ),
          );
        },
      ),
    );
  }
}
