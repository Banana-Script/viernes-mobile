import '../entities/conversation_filters.dart';
import '../repositories/conversation_repository.dart';

/// Get Conversations Use Case
///
/// Fetches conversations list with pagination and filters.
class GetConversationsUseCase {
  final ConversationRepository _repository;

  GetConversationsUseCase(this._repository);

  /// Execute use case
  ///
  /// Parameters:
  /// - [page]: Page number (default: 1)
  /// - [pageSize]: Number of items per page (default: 20)
  /// - [filters]: Filter criteria
  /// - [searchTerm]: Search query
  /// - [orderBy]: Sort field (default: 'updated_at')
  /// - [orderDirection]: Sort direction (default: 'desc')
  ///
  /// Returns paginated conversations response
  Future<ConversationsListResponse> call({
    int page = 1,
    int pageSize = 20,
    ConversationFilters filters = const ConversationFilters(),
    String searchTerm = '',
    String orderBy = 'updated_at',
    String orderDirection = 'desc',
  }) async {
    return await _repository.getConversations(
      page: page,
      pageSize: pageSize,
      filters: filters,
      searchTerm: searchTerm,
      orderBy: orderBy,
      orderDirection: orderDirection,
    );
  }
}
