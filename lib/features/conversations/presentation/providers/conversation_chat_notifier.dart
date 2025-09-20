import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/conversation_message.dart';
import '../../domain/entities/sse_events.dart';
import '../../domain/usecases/get_conversation_messages.dart';
import '../../domain/usecases/get_conversations.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/listen_to_sse_events.dart';
import 'conversation_chat_state.dart';
import 'conversations_providers.dart';

class ConversationChatNotifier extends StateNotifier<ConversationChatState> {
  final GetConversationById _getConversationById;
  final GetConversationMessages _getConversationMessages;
  final SendMessage _sendMessage;
  final ListenToSSEEvents _listenToSSEEvents;

  StreamSubscription<dynamic>? _sseSubscription;

  ConversationChatNotifier(
    this._getConversationById,
    this._getConversationMessages,
    this._sendMessage,
    this._listenToSSEEvents,
  ) : super(const ConversationChatState());

  Future<void> loadConversation(int conversationId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getConversationById(conversationId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (conversation) {
        state = state.copyWith(
          conversation: conversation,
          isLoading: false,
          error: null,
        );
        _loadMessages(conversationId);
        _connectToSSE(conversationId);
      },
    );
  }

  Future<void> _loadMessages(int conversationId) async {
    state = state.copyWith(isLoadingMessages: true);

    final result = await _getConversationMessages(conversationId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingMessages: false,
          error: failure.message,
        );
      },
      (messagesResponse) {
        // Sort messages by creation date
        final sortedMessages = List<ConversationMessage>.from(
          messagesResponse.conversation,
        )..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        state = state.copyWith(
          messages: sortedMessages,
          isLoadingMessages: false,
          error: null,
        );
      },
    );
  }

  Future<void> _connectToSSE(int conversationId) async {
    if (state.conversation == null) return;

    state = state.copyWith(isConnectingSSE: true, sseError: null);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        state = state.copyWith(
          isConnectingSSE: false,
          sseError: 'User not authenticated',
        );
        return;
      }

      final token = await user.getIdToken();
      if (token == null) {
        state = state.copyWith(
          isConnectingSSE: false,
          sseError: 'Failed to get authentication token',
        );
        return;
      }

      _sseSubscription?.cancel();
      _sseSubscription = _listenToSSEEvents(conversationId, token).listen(
        (result) {
          result.fold(
            (failure) {
              state = state.copyWith(
                isConnectedToSSE: false,
                sseError: failure.message,
              );
            },
            (event) {
              if (!state.isConnectedToSSE) {
                state = state.copyWith(
                  isConnectedToSSE: true,
                  isConnectingSSE: false,
                  sseError: null,
                );
              }
              _handleSSEEvent(event);
            },
          );
        },
        onError: (error) {
          state = state.copyWith(
            isConnectedToSSE: false,
            isConnectingSSE: false,
            sseError: error.toString(),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isConnectingSSE: false,
        sseError: e.toString(),
      );
    }
  }

  void _handleSSEEvent(SSEEvent event) {
    event.when(
      userMessage: (data, conversationId, organizationId, platform, timestamp) {
        final message = ConversationMessage(
          id: timestamp,
          parentConversationId: conversationId,
          message: data.message,
          jsonMessage: null,
          createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
          readed: false,
          sessionId: data.sessionId,
          type: ConversationMessageType.user,
        );
        _addMessage(message);
      },
      agentMessage: (data, conversationId, organizationId, platform, timestamp) {
        final message = ConversationMessage(
          id: timestamp,
          parentConversationId: conversationId,
          message: data.message,
          jsonMessage: null,
          createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
          readed: false,
          sessionId: data.sessionId,
          type: ConversationMessageType.gpt,
        );
        _addMessage(message);
      },
      llmResponseStart: (data, conversationId, organizationId, platform, timestamp) {
        state = state.copyWith(
          typingIndicator: const TypingIndicator(isTyping: true, typingBy: TypingBy.ai),
        );
      },
      llmResponseEnd: (data, conversationId, organizationId, platform, timestamp) {
        state = state.copyWith(
          typingIndicator: const TypingIndicator(isTyping: false, typingBy: TypingBy.ai),
        );
        final message = ConversationMessage(
          id: timestamp,
          parentConversationId: conversationId,
          message: data.response,
          jsonMessage: null,
          createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
          readed: false,
          sessionId: '',
          type: ConversationMessageType.gpt,
        );
        _addMessage(message);
      },
      llmResponseError: (data, conversationId, organizationId, platform, timestamp) {
        state = state.copyWith(
          typingIndicator: const TypingIndicator(isTyping: false, typingBy: TypingBy.ai),
          error: 'AI Error: ${data.error}',
        );
      },
      agentAssigned: (data, conversationId, organizationId, platform, timestamp) {
        // Update conversation agent if needed
        if (state.conversation != null) {
          // Could update the agent info here
        }
      },
      conversationStatusChange: (data, conversationId, organizationId, platform, timestamp) {
        // Update conversation status if needed
      },
      typing: (data, conversationId, organizationId, platform, timestamp) {
        state = state.copyWith(
          typingIndicator: TypingIndicator(
            isTyping: data.status == 'typing',
            typingBy: data.typingBy,
          ),
        );
      },
      keepalive: () {
        // Keep connection alive
      },
    );
  }

  void _addMessage(ConversationMessage message) {
    final updatedMessages = [...state.messages, message];
    updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    state = state.copyWith(messages: updatedMessages);
  }

  Future<void> sendMessage(String messageText) async {
    if (messageText.trim().isEmpty || state.conversation == null) return;

    state = state.copyWith(isSendingMessage: true, error: null);

    final request = SendMessageRequest(
      message: messageText.trim(),
      sessionId: state.conversation!.user.sessionId,
    );

    final result = await _sendMessage(request);

    result.fold(
      (failure) {
        state = state.copyWith(
          isSendingMessage: false,
          error: failure.message,
        );
      },
      (response) {
        state = state.copyWith(
          isSendingMessage: false,
          error: null,
        );
        // Message will be added via SSE event
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSSEError() {
    state = state.copyWith(sseError: null);
  }

  @override
  void dispose() {
    _sseSubscription?.cancel();
    super.dispose();
  }
}

final conversationChatNotifierProvider =
    StateNotifierProvider.family<ConversationChatNotifier, ConversationChatState, int>(
  (ref, conversationId) {
    final notifier = ConversationChatNotifier(
      ref.watch(getConversationByIdUseCaseProvider),
      ref.watch(getConversationMessagesUseCaseProvider),
      ref.watch(sendMessageUseCaseProvider),
      ref.watch(listenToSSEEventsUseCaseProvider),
    );

    // Auto-load conversation when provider is created
    notifier.loadConversation(conversationId);

    return notifier;
  },
);