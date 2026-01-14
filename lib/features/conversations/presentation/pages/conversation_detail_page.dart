import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/models/sse_events.dart';
import '../../../../core/timezone/timezone_manager.dart';
import '../../../../core/services/conversation_sse_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/utils/logger.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/conversation_provider.dart';
import '../../domain/repositories/conversation_repository.dart' show ConversationStatusOption;
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
import '../../../../core/di/dependency_injection.dart';

/// Conversation Detail Page
///
/// Chat interface for viewing and sending messages in a conversation.
class ConversationDetailPage extends ConsumerStatefulWidget {
  final int conversationId;
  final bool allowDirectChat;

  const ConversationDetailPage({
    super.key,
    required this.conversationId,
    this.allowDirectChat = false,
  });

  @override
  ConsumerState<ConversationDetailPage> createState() => _ConversationDetailPageState();
}

class _ConversationDetailPageState extends ConsumerState<ConversationDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showToolCalls = true;

  // SSE for real-time updates
  ConversationSSEService? _sseService;
  bool _isTyping = false;
  String _typingBy = '';

  @override
  void initState() {
    super.initState();
    _loadToolCallsPreference();

    // Load conversation and messages
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = provider_pkg.Provider.of<ConversationProvider>(context, listen: false);
      await provider.selectConversation(widget.conversationId);

      // Auto-assign if coming from customer detail and conversation has no agent
      if (widget.allowDirectChat && mounted) {
        final conversation = provider.selectedConversation;
        if (conversation != null && conversation.agentId == null) {
          await provider.assignConversationToMe(widget.conversationId);
        }
      }

      // Connect to conversation SSE
      _connectSSE();
    });

    // Setup scroll listener for loading older messages
    _scrollController.addListener(_onScroll);

    // Track current conversation for notification service
    NotificationService.instance.setCurrentConversation(widget.conversationId);
  }

  @override
  void dispose() {
    _disconnectSSE();
    _scrollController.dispose();

    // Clear current conversation from notification service
    NotificationService.instance.setCurrentConversation(null);

    super.dispose();
  }

  /// Connect to conversation-level SSE
  void _connectSSE() {
    _sseService = ConversationSSEService(conversationId: widget.conversationId);

    // Set up callbacks
    _sseService!.onUserMessage = _handleUserMessage;
    _sseService!.onAgentMessage = _handleAgentMessage;
    _sseService!.onLLMResponse = _handleLLMResponse;
    _sseService!.onTyping = _handleTyping;
    _sseService!.onAgentAssigned = _handleAgentAssigned;
    _sseService!.onStatusChange = _handleStatusChange;
    _sseService!.onError = _handleSSEError;

    // Connect
    _sseService!.connect().then((_) {
      AppLogger.info(
        'Connected to conversation SSE for ${widget.conversationId}',
        tag: 'ConversationDetail',
      );
    }).catchError((e) {
      AppLogger.error(
        'Error connecting to conversation SSE: $e',
        tag: 'ConversationDetail',
      );
    });
  }

  /// Disconnect from conversation-level SSE
  Future<void> _disconnectSSE() async {
    await _sseService?.dispose();
    _sseService = null;
  }

  /// Handle incoming user message from SSE
  void _handleUserMessage(SSEUserMessageEvent event) {
    if (!mounted) return;

    AppLogger.debug(
      'SSE: User message received',
      tag: 'ConversationDetail',
    );

    // The provider will handle adding the message
    // Provider already subscribed to org-level SSE for this
  }

  /// Handle incoming agent message from SSE
  void _handleAgentMessage(SSEAgentMessageEvent event) {
    if (!mounted) return;

    AppLogger.debug(
      'SSE: Agent message received',
      tag: 'ConversationDetail',
    );

    // Add message to provider
    final provider = provider_pkg.Provider.of<ConversationProvider>(context, listen: false);
    provider.addAgentMessageFromSSE(event);
  }

  /// Handle LLM response from SSE
  void _handleLLMResponse(SSELLMResponseEndEvent event) {
    if (!mounted) return;

    AppLogger.debug(
      'SSE: LLM response received',
      tag: 'ConversationDetail',
    );

    // Create agent message event from LLM response
    final agentEvent = SSEAgentMessageEvent(
      message: event.message,
      messageType: event.messageType,
      conversationId: event.conversationId,
      organizationId: event.organizationId,
      platform: event.platform,
      timestamp: event.timestamp,
      metadata: const {},
    );

    final provider = provider_pkg.Provider.of<ConversationProvider>(context, listen: false);
    provider.addAgentMessageFromSSE(agentEvent);
  }

  /// Handle typing indicator from SSE
  void _handleTyping(bool isTyping, String typingBy) {
    if (!mounted) return;

    setState(() {
      _isTyping = isTyping;
      _typingBy = typingBy;
    });
  }

  /// Handle agent assigned from SSE
  void _handleAgentAssigned(SSEAgentAssignedEvent event) {
    if (!mounted) return;

    AppLogger.debug(
      'SSE: Agent assigned - ${event.agentName}',
      tag: 'ConversationDetail',
    );

    // Reload conversation to get updated assignment
    final provider = provider_pkg.Provider.of<ConversationProvider>(context, listen: false);
    provider.selectConversation(widget.conversationId);
  }

  /// Handle status change from SSE
  void _handleStatusChange(SSEConversationStatusChangeEvent event) {
    if (!mounted) return;

    AppLogger.debug(
      'SSE: Status changed - ${event.oldStatus} -> ${event.newStatus}',
      tag: 'ConversationDetail',
    );

    // Reload conversation to get updated status
    final provider = provider_pkg.Provider.of<ConversationProvider>(context, listen: false);
    provider.selectConversation(widget.conversationId);
  }

  /// Handle SSE error
  void _handleSSEError(String error) {
    if (!mounted) return;

    AppLogger.error(
      'SSE Error: $error',
      tag: 'ConversationDetail',
    );
  }

  void _onScroll() {
    // Load more messages when scrolling to top (older messages)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = provider_pkg.Provider.of<ConversationProvider>(context, listen: false);
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
    final provider = provider_pkg.Provider.of<ConversationProvider>(context, listen: false);
    final authProvider = provider_pkg.Provider.of<AuthProvider>(context, listen: false);
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
      final l10n = AppLocalizations.of(context);
      final provider = provider_pkg.Provider.of<ConversationProvider>(context, listen: false);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      // Get organizationId from the selected conversation
      final conversation = provider.selectedConversation;
      if (conversation == null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(l10n?.errorConversationNotLoaded ?? 'Error: Conversation not loaded'),
            backgroundColor: ViernesColors.danger,
          ),
        );
        return;
      }

      // Check if status options are loaded
      if (provider.availableStatuses.isEmpty) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(l10n?.errorStatusesNotLoaded ?? 'Error: Status options not loaded. Please try again.'),
            backgroundColor: ViernesColors.danger,
          ),
        );
        return;
      }

      // Lookup status ID from availableStatuses by value_definition
      // Status 030 = Completed Successfully, 040 = Completed Unsuccessfully
      const statusCompletedSuccessfully = '030';
      const statusCompletedUnsuccessfully = '040';
      final statusValue = isSuccessful ? statusCompletedSuccessfully : statusCompletedUnsuccessfully;

      final statusOption = provider.availableStatuses.cast<ConversationStatusOption?>().firstWhere(
        (s) => s?.value == statusValue,
        orElse: () => null,
      );

      if (statusOption == null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(l10n?.errorStatusNotFound(statusValue) ?? 'Error: Status $statusValue not found'),
            backgroundColor: ViernesColors.danger,
          ),
        );
        return;
      }

      final success = await provider.updateConversationStatus(
        widget.conversationId,
        statusOption.id,
        conversation.organizationId,
      );

      if (mounted) {
        if (success) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                isSuccessful
                    ? l10n?.conversationCompletedSuccessfully ?? 'Conversation completed successfully'
                    : l10n?.conversationCompletedUnsuccessfully ?? 'Conversation completed unsuccessfully',
              ),
              backgroundColor: isSuccessful ? ViernesColors.success : ViernesColors.warning,
            ),
          );
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? l10n?.errorUpdatingStatus ?? 'Error updating status'),
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
    final authProvider = provider_pkg.Provider.of<AuthProvider>(context, listen: false);
    final notesProvider = DependencyInjection.internalNotesProvider;

    // Load notes when opening the panel
    notesProvider.loadNotes(conversation.id, resetPage: true);

    // Show the panel - pass provider for internal selective rebuilding
    // DO NOT wrap with ListenableBuilder - it resets panel's internal state!
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (sheetContext, scrollController) => InternalNotesPanel(
          conversationId: conversation.id,
          currentUserId: authProvider.user?.databaseId,
          // Pass provider for internal selective rebuilding of list only
          notesProvider: notesProvider,
          getNotesFromProvider: () => notesProvider.notes,
          isProviderLoading: () => notesProvider.isLoading || notesProvider.isLoadingMore,
          providerHasMore: () => notesProvider.hasMore,
          getProviderError: () => notesProvider.errorMessage,
          onRefresh: () async {
            await notesProvider.loadNotes(conversation.id, resetPage: true);
          },
          onLoadMore: () async {
            await notesProvider.loadMoreNotes();
          },
          onCreateNote: (content) async {
            return await notesProvider.createNote(conversation.id, content);
          },
          onUpdateNote: (noteId, content) async {
            return await notesProvider.updateNote(conversation.id, noteId, content);
          },
          onDeleteNote: (noteId) async {
            return await notesProvider.deleteNote(conversation.id, noteId);
          },
        ),
      ),
    );
  }

  Future<void> _showReassignModal(
    BuildContext context,
    ConversationEntity conversation,
  ) async {
    final l10n = AppLocalizations.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final provider = provider_pkg.Provider.of<ConversationProvider>(context, listen: false);

    // Load organization agents
    await provider.loadOrganizationAgents();

    if (!mounted) return;

    if (provider.organizationAgents.isEmpty) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n?.noAgentsAvailable ?? 'No agents available for reassignment'),
          backgroundColor: ViernesColors.warning,
        ),
      );
      return;
    }

    // Convert AgentOption to ReassignAgentOption
    final agents = provider.organizationAgents.map((agent) => ReassignAgentOption(
      id: agent.id,
      fullname: agent.name,
      email: agent.email,
    )).toList();

    if (!mounted) return;

    ReassignAgentModal.show(
      context: context,
      agents: agents,
      currentAgentId: conversation.agentId,
      onReassign: (agentId) async {
        final success = await provider.reassignConversation(conversation.id, agentId);
        if (success && mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(l10n?.reassignSuccess ?? 'Conversation reassigned successfully'),
              backgroundColor: ViernesColors.success,
            ),
          );
        } else if (!success && mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? l10n?.reassignError ?? 'Error reassigning conversation'),
              backgroundColor: ViernesColors.danger,
            ),
          );
        }
        return success;
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
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: ViernesColors.getTextColor(isDark),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: provider_pkg.Consumer<ConversationProvider>(
        builder: (context, provider, _) {
          final l10n = AppLocalizations.of(context);
          final conversation = provider.selectedConversation;
          if (conversation == null) {
            return _buildAppBarSkeleton(isDark);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                conversation.user?.fullname ?? l10n?.unknownCustomer ?? 'Unknown Customer',
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
    return provider_pkg.Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        final l10n = AppLocalizations.of(context);
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
                  l10n?.assignedToAgent(conversation.agent!.fullname) ?? 'Assigned: ${conversation.agent!.fullname}',
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
    return provider_pkg.Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        // Loading state
        if (provider.messageStatus == MessageStatus.loading &&
            provider.messages.isEmpty) {
          return const ConversationDetailSkeleton();
        }

        // Error state
        if (provider.messageStatus == MessageStatus.error &&
            provider.messages.isEmpty) {
          final l10n = AppLocalizations.of(context);
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
                  l10n?.errorLoadingMessages ?? 'Error loading messages',
                  style: ViernesTextStyles.h6.copyWith(
                    color: ViernesColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: ViernesSpacing.sm),
                Text(
                  provider.messageErrorMessage ?? l10n?.unknownError ?? 'Unknown error',
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
                  child: Text(l10n?.retry ?? 'Retry'),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (provider.messages.isEmpty) {
          final l10n = AppLocalizations.of(context);
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
                  l10n?.noMessagesYet ?? 'No messages yet',
                  style: ViernesTextStyles.h6.copyWith(
                    color: ViernesColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: ViernesSpacing.sm),
                Text(
                  l10n?.startTheConversation ?? 'Start the conversation',
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

        // Calculate item count (typing indicator + messages + loading indicator)
        final hasTyping = _isTyping;
        final itemCount = filteredMessages.length +
            (hasTyping ? 1 : 0) +
            (provider.isLoadingMoreMessages ? 1 : 0);

        // Messages list (reversed to show newest at bottom)
        return ListView.builder(
          controller: _scrollController,
          reverse: true, // Newest messages at bottom
          padding: const EdgeInsets.symmetric(
            vertical: ViernesSpacing.lg,
            horizontal: ViernesSpacing.md,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            // Typing indicator at the bottom (index 0 when reversed)
            if (hasTyping && index == 0) {
              return _buildTypingIndicator(isDark);
            }

            // Adjust index for typing indicator
            final adjustedIndex = hasTyping ? index - 1 : index;

            // Loading indicator at top (for older messages)
            if (adjustedIndex >= filteredMessages.length) {
              return const Padding(
                padding: EdgeInsets.all(ViernesSpacing.md),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Messages are reversed, so we need to access them in reverse order
            final message = filteredMessages[adjustedIndex];
            final timezone = ref.watch(currentTimezoneProvider);
            return MessageBubble(
              message: message,
              isDark: isDark,
              timezone: timezone,
            );
          },
        );
      },
    );
  }

  /// Build typing indicator widget
  Widget _buildTypingIndicator(bool isDark) {
    final l10n = AppLocalizations.of(context);
    final typingLabel = _typingBy == 'ai'
        ? l10n?.aiIsThinking ?? 'AI is thinking...'
        : _typingBy.isNotEmpty
            ? l10n?.userIsTyping(_typingBy) ?? '$_typingBy is typing...'
            : l10n?.typing ?? 'Typing...';

    return Padding(
      padding: const EdgeInsets.only(
        left: ViernesSpacing.xl * 2,
        right: ViernesSpacing.md,
        bottom: ViernesSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ViernesSpacing.md,
              vertical: ViernesSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: ViernesColors.getControlBackground(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDots(isDark),
                const SizedBox(width: ViernesSpacing.sm),
                Text(
                  typingLabel,
                  style: ViernesTextStyles.caption.copyWith(
                    color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build animated typing dots
  Widget _buildTypingDots(bool isDark) {
    return SizedBox(
      width: 24,
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.3, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 150)),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: ViernesColors.primary.withValues(alpha: value),
                  shape: BoxShape.circle,
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    return provider_pkg.Consumer2<ConversationProvider, AuthProvider>(
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
                  content: Text(conversationProvider.messageErrorMessage ?? (l10n?.sendMessageError ?? 'Failed to send message')),
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
                SnackBar(
                  content: Text(l10n?.assignedSuccessfully ?? 'Conversation assigned successfully'),
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
