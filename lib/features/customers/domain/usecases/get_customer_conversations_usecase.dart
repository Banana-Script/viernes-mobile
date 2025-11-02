import '../entities/conversation_entity.dart';
import '../repositories/customer_repository.dart';

/// Get Customer Conversations Use Case
///
/// Fetches conversation history for a specific customer.
/// Returns paginated list of conversations (CHAT and CALL).
class GetCustomerConversationsUseCase {
  final CustomerRepository _repository;

  GetCustomerConversationsUseCase(this._repository);

  /// Execute use case
  ///
  /// Parameters:
  /// - [userId]: The customer's user ID
  /// - [page]: Page number (default: 1)
  /// - [pageSize]: Number of items per page (default: 10)
  ///
  /// Returns paginated conversations response
  Future<ConversationsResponse> call({
    required int userId,
    int page = 1,
    int pageSize = 10,
  }) async {
    return await _repository.getCustomerConversations(
      userId: userId,
      page: page,
      pageSize: pageSize,
    );
  }
}

/// Conversations Response
///
/// Response model for paginated conversations
class ConversationsResponse {
  final List<ConversationEntity> conversations;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  const ConversationsResponse({
    required this.conversations,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  bool get hasMorePages => currentPage < totalPages;
}
