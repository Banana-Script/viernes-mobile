import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/conversation_provider.dart';
import '../../domain/entities/message_entity.dart';
import '../../../customers/domain/entities/conversation_entity.dart';
import '../widgets/message_bubble.dart';
import '../widgets/status_badge.dart';
import '../widgets/priority_badge.dart';
import '../widgets/message_composer/message_composer.dart';
import '../widgets/conversation_detail_skeleton.dart';
import '../widgets/conversation_actions/conversation_actions_bottom_sheet.dart';
import '../widgets/conversation_actions/complete_conversation_dialog.dart';
import '../widgets/conversation_actions/conversation_info_panel.dart';
import '../widgets/conversation_actions/conversation_report_modal.dart';
import '../widgets/conversation_actions/reassign_agent_modal.dart';
import '../widgets/internal_notes/internal_notes_panel.dart';
import '../../domain/entities/internal_note_entity.dart';

/// Conversation Detail Page
///
/// Chat interface for viewing and sending messages in a conversation.
class ConversationDetailPage extends StatefulWidget {
  final int conversationId;
  final bool allowDirectChat;

  const ConversationDetailPage({
    super.key,
    required this.conversationId,
    this.allowDirectChat = false,
  });

  @override
  State<ConversationDetailPage> createState() => _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<ConversationDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showToolCalls = true;

  @override
  void initState() {
    super.initState();
    _loadToolCallsPreference();

    // Load conversation and messages
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ConversationProvider>(context, listen: false);
      await provider.selectConversation(widget.conversationId);

      // Auto-assign if coming from customer detail and conversation has no agent
      if (widget.allowDirectChat && mounted) {
        final conversation = provider.selectedConversation;
        if (conversation != null && conversation.agentId == null) {
          await provider.assignConversationToMe(widget.conversationId);
        }
      }
    });

    // Setup scroll listener for loading older messages
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more messages when scrolling to top (older messages)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<ConversationProvider>(context, listen: false);
      if (!provider.isLoadingMoreMessages && provider.hasMoreMessages) {
        provider.loadMoreMessages(widget.conversationId);
      }
    }
  }

  Future<void> _loadToolCallsPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showToolCalls = prefs.getBool('show_tool_calls') ?? true;
    });
  }

  Future<void> _toggleToolCalls() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showToolCalls = !_showToolCalls;
    });
    await prefs.setBool('show_tool_calls', _showToolCalls);
  }

  void _showActionsBottomSheet(BuildContext context) {
    final provider = Provider.of<ConversationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final conversation = provider.selectedConversation;

    if (conversation == null) return;

    ConversationActionsBottomSheet.show(
      context: context,
      conversation: conversation,
      currentUser: authProvider.user,
      showToolCalls: _showToolCalls,
      onViewInfo: () {
        ConversationInfoPanel.show(
          context: context,
          conversation: conversation,
        );
      },
      onViewReport: () {
        ConversationReportModal.show(
          context: context,
          conversation: conversation,
        );
      },
      onViewInternalNotes: () => _showInternalNotesPanel(context, conversation),
      onToggleToolCalls: _toggleToolCalls,
      onCompleteSuccessfully: () => _showCompleteDialog(isSuccessful: true),
      onCompleteUnsuccessfully: () => _showCompleteDialog(isSuccessful: false),
      onRequestReassignment: () => _showReassignModal(context, conversation),
    );
  }

  Future<void> _showCompleteDialog({required bool isSuccessful}) async {
    final confirmed = await CompleteConversationDialog.show(
      context: context,
      isSuccessful: isSuccessful,
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<ConversationProvider>(context, listen: false);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      // Status 030 = Completed Successfully, 040 = Completed Unsuccessfully
      final statusId = isSuccessful ? 30 : 40;
      final success = await provider.updateConversationStatus(
        widget.conversationId,
        statusId,
      );

      if (mounted) {
        if (success) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                isSuccessful
                    ? 'Conversación completada exitosamente'
                    : 'Conversación completada sin éxito',
              ),
              backgroundColor: isSuccessful ? ViernesColors.success : ViernesColors.warning,
            ),
          );
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Error al actualizar estado'),
              backgroundColor: ViernesColors.danger,
            ),
          );
        }
      }
    }
  }

  void _showInternalNotesPanel(
    BuildContext context,
    ConversationEntity conversation,
  ) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Show the panel - note: a full implementation would require
    // proper dependency injection for the InternalNotesProvider
    InternalNotesPanel.show(
      context: context,
      conversationId: conversation.id,
      notes: const <InternalNoteEntity>[], // Would be loaded from provider
      currentUserId: authProvider.user?.databaseId,
      onRefresh: () async {
        // Would call provider.loadNotes(conversation.id, resetPage: true)
      },
      onLoadMore: () async {
        // Would call provider.loadMoreNotes()
      },
      onCreateNote: (content) async {
        // Would call provider.createNote(conversation.id, content)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Función de notas internas próximamente disponible'),
              backgroundColor: ViernesColors.info,
            ),
          );
        }
        return false;
      },
      onUpdateNote: (noteId, content) async {
        // Would call provider.updateNote(conversation.id, noteId, content)
        return false;
      },
      onDeleteNote: (noteId) async {
        // Would call provider.deleteNote(conversation.id, noteId)
        return false;
      },
    );
  }

  void _showReassignModal(
    BuildContext context,
    ConversationEntity conversation,
  ) {
    // Note: A full implementation would load agents from the provider
    // For now, we show a placeholder with sample agents
    final sampleAgents = <ReassignAgentOption>[
      // Would be loaded from conversationProvider.availableAgents
    ];

    if (sampleAgents.isEmpty) {
      // Show info message when no agents available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Función de reasignación próximamente disponible'),
          backgroundColor: ViernesColors.info,
        ),
      );
      return;
    }

    ReassignAgentModal.show(
      context: context,
      agents: sampleAgents,
      currentAgentId: conversation.agentId,
      onReassign: (agentId) async {
        // Would call provider.reassignConversation(conversation.id, agentId)
        return false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ViernesColors.getControlBackground(isDark),
      appBar: _buildAppBar(context, isDark),
      body: Column(
        children: [
          _buildStatusBar(context, isDark),
          Expanded(
            child: _buildMessagesList(context, isDark),
          ),
          _buildMessageInput(context, isDark),
        ],
      ),
    );
  }

  Widget _buildAppBarSkeleton(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 140,
          height: 16,
          decoration: BoxDecoration(
            color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 100,
          height: 12,
          decoration: BoxDecoration(
            color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: ViernesColors.getControlBackground(isDark),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: ViernesColors.getTextColor(isDark),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Consumer<ConversationProvider>(
        builder: (context, provider, _) {
          final conversation = provider.selectedConversation;
          if (conversation == null) {
            return _buildAppBarSkeleton(isDark);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                conversation.user?.fullname ?? 'Unknown Customer',
                style: ViernesTextStyles.h6.copyWith(
                  color: ViernesColors.getTextColor(isDark),
                ),
              ),
              Text(
                conversation.user?.email ?? '',
                style: ViernesTextStyles.caption.copyWith(
                  color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: ViernesColors.getTextColor(isDark),
          ),
          onPressed: () => _showActionsBottomSheet(context),
        ),
      ],
    );
  }

  Widget _buildStatusBar(BuildContext context, bool isDark) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        final conversation = provider.selectedConversation;
        if (conversation == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ViernesSpacing.md,
            vertical: ViernesSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: ViernesColors.getControlBackground(isDark),
            border: Border(
              bottom: BorderSide(
                color: ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              if (conversation.status != null)
                StatusBadge(status: conversation.status!.description),
              const SizedBox(width: ViernesSpacing.sm),
              if (conversation.priority != null)
                PriorityBadge(priority: conversation.priority),
              const Spacer(),
              if (conversation.agent != null)
                Text(
                  'Assigned: ${conversation.agent!.fullname}',
                  style: ViernesTextStyles.bodySmall.copyWith(
                    color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessagesList(BuildContext context, bool isDark) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        // Loading state
        if (provider.messageStatus == MessageStatus.loading &&
            provider.messages.isEmpty) {
          return const ConversationDetailSkeleton();
        }

        // Error state
        if (provider.messageStatus == MessageStatus.error &&
            provider.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: ViernesColors.danger.withValues(alpha: 0.5),
                ),
                const SizedBox(height: ViernesSpacing.md),
                Text(
                  'Error loading messages',
                  style: ViernesTextStyles.h6.copyWith(
                    color: ViernesColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: ViernesSpacing.sm),
                Text(
                  provider.messageErrorMessage ?? 'Unknown error',
                  style: ViernesTextStyles.bodySmall.copyWith(
                    color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ViernesSpacing.lg),
                ElevatedButton(
                  onPressed: () => provider.loadMessages(
                    widget.conversationId,
                    resetPage: true,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (provider.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.3),
                ),
                const SizedBox(height: ViernesSpacing.md),
                Text(
                  'No messages yet',
                  style: ViernesTextStyles.h6.copyWith(
                    color: ViernesColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: ViernesSpacing.sm),
                Text(
                  'Start the conversation',
                  style: ViernesTextStyles.bodySmall.copyWith(
                    color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Filter messages based on _showToolCalls preference
        final filteredMessages = _showToolCalls
            ? provider.messages
            : provider.messages
                .where((m) => m.type != MessageType.toolCall)
                .toList();

        // Messages list (reversed to show newest at bottom)
        return ListView.builder(
          controller: _scrollController,
          reverse: true, // Newest messages at bottom
          padding: const EdgeInsets.symmetric(
            vertical: ViernesSpacing.lg,
            horizontal: ViernesSpacing.md,
          ),
          itemCount: filteredMessages.length +
              (provider.isLoadingMoreMessages ? 1 : 0),
          itemBuilder: (context, index) {
            // Loading indicator at top (for older messages)
            if (index >= filteredMessages.length) {
              return const Padding(
                padding: EdgeInsets.all(ViernesSpacing.md),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Messages are reversed, so we need to access them in reverse order
            final message = filteredMessages[index];
            return MessageBubble(
              message: message,
              isDark: isDark,
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput(BuildContext context, bool isDark) {
    return Consumer2<ConversationProvider, AuthProvider>(
      builder: (context, conversationProvider, authProvider, _) {
        return MessageComposer(
          conversationId: widget.conversationId,
          conversation: conversationProvider.selectedConversation,
          currentUser: authProvider.user,
          allowDirectChat: widget.allowDirectChat,
          isSending: conversationProvider.isSendingMessage,
          quickReplies: const [], // TODO: Integrate with quick replies API
          isLoadingQuickReplies: false,
          hasMoreQuickReplies: false,
          onSendMessage: (text) async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            final success = await conversationProvider.sendMessage(widget.conversationId, text);
            if (!success && mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(conversationProvider.messageErrorMessage ?? 'Failed to send message'),
                  backgroundColor: ViernesColors.danger,
                ),
              );
            }
            return success;
          },
          onSendMedia: (attachments, caption) async {
            // TODO: Implement media upload and send
            // For now, just send caption as text if provided
            if (caption != null && caption.isNotEmpty) {
              await conversationProvider.sendMessage(widget.conversationId, caption);
            }
          },
          onSearchQuickReplies: (query) {
            // TODO: Integrate with quick replies API
          },
          onLoadMoreQuickReplies: () {
            // TODO: Integrate with quick replies API
          },
          onAssignToMe: () async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            final success = await conversationProvider.assignConversationToMe(widget.conversationId);
            if (success && mounted) {
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Conversación asignada exitosamente'),
                  backgroundColor: ViernesColors.success,
                ),
              );
            }
            return success;
          },
        );
      },
    );
  }
}
