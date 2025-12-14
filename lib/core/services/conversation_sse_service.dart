import 'dart:async';

import '../models/sse_events.dart';
import '../utils/logger.dart';
import 'sse_service.dart';

/// Conversation SSE Service
///
/// Service for managing SSE connection to a specific conversation.
/// Handles real-time messages, typing indicators, and status changes.
///
/// Usage:
/// ```dart
/// final service = ConversationSSEService(conversationId: 123);
///
/// // Set callbacks
/// service.onNewMessage = (event) => print('New message: ${event.message}');
/// service.onTyping = (isTyping, by) => print('Typing: $isTyping by $by');
///
/// // Connect
/// await service.connect();
///
/// // When done
/// await service.dispose();
/// ```
class ConversationSSEService extends SSEService {
  final int conversationId;

  // Callbacks
  void Function(SSEUserMessageEvent event)? onUserMessage;
  void Function(SSEAgentMessageEvent event)? onAgentMessage;
  void Function(SSELLMResponseEndEvent event)? onLLMResponse;
  void Function(SSELLMResponseErrorEvent event)? onLLMError;
  void Function(bool isTyping, String typingBy)? onTyping;
  void Function(SSEAgentAssignedEvent event)? onAgentAssigned;
  void Function(SSEConversationStatusChangeEvent event)? onStatusChange;
  void Function(String error)? onError;

  // Stream subscription for internal event handling
  StreamSubscription<SSEEvent>? _eventSubscription;

  // Typing state
  bool _isTyping = false;
  String _typingBy = '';

  ConversationSSEService({
    required this.conversationId,
  }) : super(tag: 'ConversationSSE:$conversationId');

  /// Whether someone is typing
  bool get isTyping => _isTyping;

  /// Who is typing
  String get typingBy => _typingBy;

  @override
  String getEndpoint() {
    return '/sse/conversation/$conversationId';
  }

  @override
  Future<void> connect() async {
    // Set up internal event handling before connecting
    _eventSubscription?.cancel();
    _eventSubscription = events.listen(_handleEvent);

    await super.connect();
  }

  @override
  Future<void> disconnect() async {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    _isTyping = false;
    _typingBy = '';
    await super.disconnect();
  }

  /// Handle incoming events
  void _handleEvent(SSEEvent event) {
    AppLogger.debug(
      '[ConversationSSE:$conversationId] Handling event: ${event.type.value}',
      tag: 'ConversationSSE',
    );

    switch (event.type) {
      case SSEEventType.userMessage:
      case SSEEventType.newMessage:
      case SSEEventType.messageReceived:
        if (event is SSEUserMessageEvent) {
          _handleUserMessage(event);
        }
        break;

      case SSEEventType.agentMessage:
        if (event is SSEAgentMessageEvent) {
          _handleAgentMessage(event);
        }
        break;

      case SSEEventType.llmResponseStart:
        _handleTypingStart('ai');
        break;

      case SSEEventType.llmResponseEnd:
        if (event is SSELLMResponseEndEvent) {
          _handleLLMResponseEnd(event);
        }
        break;

      case SSEEventType.llmResponseError:
        if (event is SSELLMResponseErrorEvent) {
          _handleLLMError(event);
        }
        break;

      case SSEEventType.typingStart:
        if (event is SSETypingEvent) {
          _handleTypingStart(event.typingBy);
        }
        break;

      case SSEEventType.typingEnd:
        _handleTypingEnd();
        break;

      case SSEEventType.agentAssigned:
        if (event is SSEAgentAssignedEvent) {
          _handleAgentAssigned(event);
        }
        break;

      case SSEEventType.conversationStatusChange:
        if (event is SSEConversationStatusChangeEvent) {
          _handleStatusChange(event);
        }
        break;

      default:
        AppLogger.debug(
          '[ConversationSSE:$conversationId] Unhandled event type: ${event.type.value}',
          tag: 'ConversationSSE',
        );
    }
  }

  void _handleUserMessage(SSEUserMessageEvent event) {
    AppLogger.info(
      '[ConversationSSE:$conversationId] User message received',
      tag: 'ConversationSSE',
    );
    onUserMessage?.call(event);
  }

  void _handleAgentMessage(SSEAgentMessageEvent event) {
    AppLogger.info(
      '[ConversationSSE:$conversationId] Agent message received',
      tag: 'ConversationSSE',
    );

    // Stop typing indicator when message arrives
    _handleTypingEnd();

    onAgentMessage?.call(event);
  }

  void _handleLLMResponseEnd(SSELLMResponseEndEvent event) {
    AppLogger.info(
      '[ConversationSSE:$conversationId] LLM response received',
      tag: 'ConversationSSE',
    );

    // Stop typing indicator
    _handleTypingEnd();

    onLLMResponse?.call(event);
  }

  void _handleLLMError(SSELLMResponseErrorEvent event) {
    AppLogger.error(
      '[ConversationSSE:$conversationId] LLM error: ${event.error}',
      tag: 'ConversationSSE',
    );

    // Stop typing indicator
    _handleTypingEnd();

    onLLMError?.call(event);
    onError?.call(event.error);
  }

  void _handleTypingStart(String by) {
    if (!_isTyping || _typingBy != by) {
      _isTyping = true;
      _typingBy = by;
      onTyping?.call(true, by);
    }
  }

  void _handleTypingEnd() {
    if (_isTyping) {
      _isTyping = false;
      _typingBy = '';
      onTyping?.call(false, '');
    }
  }

  void _handleAgentAssigned(SSEAgentAssignedEvent event) {
    AppLogger.info(
      '[ConversationSSE:$conversationId] Agent assigned: ${event.agentName}',
      tag: 'ConversationSSE',
    );
    onAgentAssigned?.call(event);
  }

  void _handleStatusChange(SSEConversationStatusChangeEvent event) {
    AppLogger.info(
      '[ConversationSSE:$conversationId] Status changed: ${event.oldStatus} -> ${event.newStatus}',
      tag: 'ConversationSSE',
    );
    onStatusChange?.call(event);
  }

  @override
  Future<void> dispose() async {
    onUserMessage = null;
    onAgentMessage = null;
    onLLMResponse = null;
    onLLMError = null;
    onTyping = null;
    onAgentAssigned = null;
    onStatusChange = null;
    onError = null;
    await super.dispose();
  }
}
