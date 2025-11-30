import '../entities/conversation_filters.dart';
import '../entities/message_entity.dart';
import '../../../customers/domain/entities/conversation_entity.dart';

/// Conversation Repository
///
/// Repository interface for conversation operations.
/// This is in the domain layer and defines the contract that
/// the data layer must implement.
abstract class ConversationRepository {
  /// Get conversations list with pagination and filters
  Future<ConversationsListResponse> getConversations({
    required int page,
    required int pageSize,
    required ConversationFilters filters,
    String searchTerm = '',
    String orderBy = 'updated_at',
    String orderDirection = 'desc',
  });

  /// Get conversation by ID with full details
  Future<ConversationEntity> getConversationById(int conversationId);

  /// Get messages for a conversation with pagination
  Future<MessagesResponse> getMessages({
    required int conversationId,
    required int page,
    required int pageSize,
  });

  /// Send a text message
  Future<MessageEntity> sendMessage({
    required int conversationId,
    required String text,
  });

  /// Upload and send media/file
  Future<MessageEntity> sendMediaMessage({
    required int conversationId,
    required String filePath,
    required String fileName,
    String? caption,
  });

  /// Update conversation status
  Future<void> updateConversationStatus({
    required int conversationId,
    required int statusId,
  });

  /// Update conversation priority
  Future<void> updateConversationPriority({
    required int conversationId,
    required String priority,
  });

  /// Assign conversation to agent(s)
  Future<void> assignConversation({
    required int conversationId,
    required List<int> agentIds,
  });

  /// Add tags to conversation
  Future<void> addTags({
    required int conversationId,
    required List<int> tagIds,
  });

  /// Remove tags from conversation
  Future<void> removeTags({
    required int conversationId,
    required List<int> tagIds,
  });

  /// Mark conversation as read
  Future<void> markAsRead(int conversationId);

  /// Get available statuses for filtering
  Future<List<ConversationStatusOption>> getStatuses();

  /// Get available tags for filtering
  Future<List<TagOption>> getTags();

  /// Get available agents for filtering
  Future<List<AgentOption>> getAgents();
}

/// Conversations List Response
class ConversationsListResponse {
  final List<ConversationEntity> conversations;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  const ConversationsListResponse({
    required this.conversations,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  bool get hasMorePages => currentPage < totalPages;
}

/// Status Option for filter dropdown
class ConversationStatusOption {
  final int id;
  final String value;
  final String label;
  final String description;

  const ConversationStatusOption({
    required this.id,
    required this.value,
    required this.label,
    required this.description,
  });
}

/// Tag Option for filter dropdown
class TagOption {
  final int id;
  final String name;
  final String description;

  const TagOption({
    required this.id,
    required this.name,
    required this.description,
  });
}

/// Agent Option for filter dropdown
class AgentOption {
  final int id;
  final String name;
  final String email;

  const AgentOption({
    required this.id,
    required this.name,
    required this.email,
  });
}
