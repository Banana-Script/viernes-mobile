import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/conversation_message.dart';
import '../../domain/entities/sse_events.dart';

part 'conversation_chat_state.freezed.dart';

@freezed
class ConversationChatState with _$ConversationChatState {
  const factory ConversationChatState({
    Conversation? conversation,
    @Default([]) List<ConversationMessage> messages,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMessages,
    @Default(false) bool isSendingMessage,
    @Default(false) bool isConnectedToSSE,
    @Default(false) bool isConnectingSSE,
    TypingIndicator? typingIndicator,
    String? error,
    String? sseError,
  }) = _ConversationChatState;

  const ConversationChatState._();

  bool get hasMessages => messages.isNotEmpty;
  bool get hasTypingIndicator => typingIndicator?.isTyping == true;
}