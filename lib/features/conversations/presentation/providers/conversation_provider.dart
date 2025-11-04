import 'package:flutter/foundation.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/conversation_filters.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/get_conversation_detail_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/send_media_usecase.dart';
import '../../domain/usecases/update_conversation_status_usecase.dart';
import '../../domain/usecases/assign_conversation_usecase.dart';
import '../../domain/usecases/get_filter_options_usecase.dart';
import '../../../customers/domain/entities/conversation_entity.dart';

enum ConversationStatus { initial, loading, loaded, loadingMore, error }

enum MessageStatus { initial, loading, loaded, loadingMore, sending, error }

enum ConversationViewMode { all, my }

/// Conversation Provider
///
/// Manages state for conversations list and individual conversation details.
class ConversationProvider extends ChangeNotifier {
  final GetConversationsUseCase _getConversationsUseCase;
  final GetConversationDetailUseCase _getConversationDetailUseCase;
  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final SendMediaUseCase _sendMediaUseCase;
  final UpdateConversationStatusUseCase _updateConversationStatusUseCase;
  final AssignConversationUseCase _assignConversationUseCase;
  final GetFilterOptionsUseCase _getFilterOptionsUseCase;

  // Current user's agent ID (for "My Conversations" filter)
  int? _currentUserAgentId;

  ConversationProvider({
    required GetConversationsUseCase getConversationsUseCase,
    required GetConversationDetailUseCase getConversationDetailUseCase,
    required GetMessagesUseCase getMessagesUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required SendMediaUseCase sendMediaUseCase,
    required UpdateConversationStatusUseCase updateConversationStatusUseCase,
    required AssignConversationUseCase assignConversationUseCase,
    required GetFilterOptionsUseCase getFilterOptionsUseCase,
  })  : _getConversationsUseCase = getConversationsUseCase,
        _getConversationDetailUseCase = getConversationDetailUseCase,
        _getMessagesUseCase = getMessagesUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _sendMediaUseCase = sendMediaUseCase,
        _updateConversationStatusUseCase = updateConversationStatusUseCase,
        _assignConversationUseCase = assignConversationUseCase,
        _getFilterOptionsUseCase = getFilterOptionsUseCase;

  // Conversations list state
  ConversationStatus _status = ConversationStatus.initial;
  String? _errorMessage;
  List<ConversationEntity> _conversations = [];
  int _totalCount = 0;
  int _totalPages = 0;
  int _currentPage = 1;
  final int _pageSize = 20;

  // Filters and search
  ConversationFilters _filters = const ConversationFilters();
  String _searchTerm = '';
  ConversationViewMode _viewMode = ConversationViewMode.all;

  // Filter options
  List<ConversationStatusOption> _availableStatuses = [];
  List<TagOption> _availableTags = [];
  List<AgentOption> _availableAgents = [];

  // Selected conversation (for detail view)
  ConversationEntity? _selectedConversation;

  // Messages state
  MessageStatus _messageStatus = MessageStatus.initial;
  String? _messageErrorMessage;
  List<MessageEntity> _messages = [];
  int _messageTotalCount = 0;
  int _messageTotalPages = 0;
  int _messageCurrentPage = 1;
  final int _messagePageSize = 50;

  // First message cache for conversation cards (lazy loading)
  final Map<int, String?> _firstMessageCache = {};
  final Set<int> _loadingFirstMessages = {};

  // Getters
  ConversationStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<ConversationEntity> get conversations => _conversations;
  int get totalCount => _totalCount;
  int get totalPages => _totalPages;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  ConversationFilters get filters => _filters;
  String get searchTerm => _searchTerm;
  ConversationViewMode get viewMode => _viewMode;
  List<ConversationStatusOption> get availableStatuses => _availableStatuses;
  List<TagOption> get availableTags => _availableTags;
  List<AgentOption> get availableAgents => _availableAgents;
  ConversationEntity? get selectedConversation => _selectedConversation;
  bool get hasMorePages => _currentPage < _totalPages;
  bool get isLoading => _status == ConversationStatus.loading;
  bool get isLoadingMore => _status == ConversationStatus.loadingMore;

  // Message getters
  MessageStatus get messageStatus => _messageStatus;
  String? get messageErrorMessage => _messageErrorMessage;
  List<MessageEntity> get messages => _messages;
  int get messageTotalCount => _messageTotalCount;
  int get messageTotalPages => _messageTotalPages;
  int get messageCurrentPage => _messageCurrentPage;
  bool get hasMoreMessages => _messageCurrentPage < _messageTotalPages;
  bool get isLoadingMessages => _messageStatus == MessageStatus.loading;
  bool get isLoadingMoreMessages => _messageStatus == MessageStatus.loadingMore;
  bool get isSendingMessage => _messageStatus == MessageStatus.sending;

  /// Initialize conversations list
  Future<void> initialize() async {
    if (_status == ConversationStatus.loading) return;

    // Load filter options first
    await _loadFilterOptions();

    // Then load conversations
    await loadConversations(resetPage: true);
  }

  /// Load conversations with current filters
  Future<void> loadConversations({bool resetPage = false}) async {
    if (_status == ConversationStatus.loading) return;

    if (resetPage) {
      _currentPage = 1;
      _conversations = [];
    }

    _status = ConversationStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Apply view mode filter
      ConversationFilters effectiveFilters = _filters;

      // For "My Conversations" mode, add current user's agent ID to filters
      if (_viewMode == ConversationViewMode.my && _currentUserAgentId != null) {
        // Add current user's agent ID if not already in filters
        if (!effectiveFilters.agentIds.contains(_currentUserAgentId)) {
          effectiveFilters = effectiveFilters.copyWith(
            agentIds: [_currentUserAgentId!],
          );
        }
      }

      final response = await _getConversationsUseCase(
        page: _currentPage,
        pageSize: _pageSize,
        filters: effectiveFilters,
        searchTerm: _searchTerm,
        orderBy: 'updated_at',
        orderDirection: 'desc',
      );

      _conversations = response.conversations;
      _totalCount = response.totalCount;
      _totalPages = response.totalPages;
      _currentPage = response.currentPage;

      _status = ConversationStatus.loaded;
    } catch (e, stackTrace) {
      _status = ConversationStatus.error;
      _errorMessage = e.toString();
      AppLogger.error(
        'Error loading conversations: $e',
        tag: 'ConversationProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }

    notifyListeners();
  }

  /// Load more conversations (pagination)
  Future<void> loadMoreConversations() async {
    if (!hasMorePages || _status == ConversationStatus.loadingMore) return;

    _status = ConversationStatus.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;

      // Apply view mode filter
      ConversationFilters effectiveFilters = _filters;

      // For "My Conversations" mode, add current user's agent ID to filters
      if (_viewMode == ConversationViewMode.my && _currentUserAgentId != null) {
        if (!effectiveFilters.agentIds.contains(_currentUserAgentId)) {
          effectiveFilters = effectiveFilters.copyWith(
            agentIds: [_currentUserAgentId!],
          );
        }
      }

      final response = await _getConversationsUseCase(
        page: nextPage,
        pageSize: _pageSize,
        filters: effectiveFilters,
        searchTerm: _searchTerm,
        orderBy: 'updated_at',
        orderDirection: 'desc',
      );

      _conversations.addAll(response.conversations);
      _currentPage = response.currentPage;

      _status = ConversationStatus.loaded;
    } catch (e, stackTrace) {
      _status = ConversationStatus.error;
      _errorMessage = e.toString();
      AppLogger.error(
        'Error loading more conversations: $e',
        tag: 'ConversationProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }

    notifyListeners();
  }

  /// Refresh conversations list
  Future<void> refresh() async {
    await loadConversations(resetPage: true);
  }

  /// Update search term
  void updateSearchTerm(String term) {
    if (_searchTerm == term) return;
    _searchTerm = term;
    notifyListeners();
  }

  /// Apply search (triggers new query)
  Future<void> applySearch() async {
    await loadConversations(resetPage: true);
  }

  /// Set current user's agent ID (for "My Conversations" filter)
  void setCurrentUserAgentId(int? agentId) {
    _currentUserAgentId = agentId;
  }

  /// Set view mode (all conversations or my conversations)
  Future<void> setViewMode(ConversationViewMode mode) async {
    if (_viewMode == mode) return;
    _viewMode = mode;

    // Clear agent filters when switching to 'my' view mode
    // (following web frontend logic)
    if (mode == ConversationViewMode.my && _filters.agentIds.isNotEmpty) {
      _filters = _filters.copyWith(agentIds: []);
    }

    await loadConversations(resetPage: true);
  }

  /// Update filters
  void updateFilters(ConversationFilters newFilters) {
    _filters = newFilters;
    notifyListeners();
  }

  /// Apply filters (triggers new query)
  Future<void> applyFilters(ConversationFilters newFilters) async {
    _filters = newFilters;
    await loadConversations(resetPage: true);
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    _filters = const ConversationFilters();
    _searchTerm = '';
    await loadConversations(resetPage: true);
  }

  /// Remove specific filter
  Future<void> removeFilter(ActiveFilter filter) async {
    switch (filter.type) {
      case FilterType.status:
        final statusIds = List<String>.from(_filters.statusIds);
        statusIds.remove(filter.value);
        _filters = _filters.copyWith(statusIds: statusIds);
        break;
      case FilterType.priority:
        final priorities = List<String>.from(_filters.priorities);
        priorities.remove(filter.value);
        _filters = _filters.copyWith(priorities: priorities);
        break;
      case FilterType.agent:
        _filters = _filters.copyWith(agentIds: []);
        break;
      case FilterType.tag:
        _filters = _filters.copyWith(tagIds: []);
        break;
      case FilterType.dateRange:
        _filters = _filters.copyWith(clearDateFrom: true, clearDateTo: true);
        break;
      case FilterType.unread:
        _filters = _filters.copyWith(clearUnreadOnly: true);
        break;
      case FilterType.type:
        _filters = _filters.copyWith(clearType: true);
        break;
    }

    await loadConversations(resetPage: true);
  }

  /// Load filter options
  Future<void> _loadFilterOptions() async {
    try {
      final results = await Future.wait([
        _getFilterOptionsUseCase.getStatuses(),
        _getFilterOptionsUseCase.getTags(),
        _getFilterOptionsUseCase.getAgents(),
      ]);

      _availableStatuses = results[0] as List<ConversationStatusOption>;
      _availableTags = results[1] as List<TagOption>;
      _availableAgents = results[2] as List<AgentOption>;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error loading filter options: $e',
        tag: 'ConversationProvider',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't throw, allow conversations to load
    }
  }

  /// Select conversation and load details
  Future<void> selectConversation(int conversationId) async {
    try {
      _selectedConversation = await _getConversationDetailUseCase(conversationId);

      // Load messages for this conversation
      await loadMessages(conversationId, resetPage: true);

      notifyListeners();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to load conversation: $e';
      AppLogger.error(
        'Error selecting conversation: $e',
        tag: 'ConversationProvider',
        error: e,
        stackTrace: stackTrace,
      );
      notifyListeners();
    }
  }

  /// Load messages for a conversation
  Future<void> loadMessages(int conversationId, {bool resetPage = false}) async {
    if (_messageStatus == MessageStatus.loading) return;

    if (resetPage) {
      _messageCurrentPage = 1;
      _messages = [];
    }

    _messageStatus = MessageStatus.loading;
    _messageErrorMessage = null;
    notifyListeners();

    try {
      final response = await _getMessagesUseCase(
        conversationId: conversationId,
        page: _messageCurrentPage,
        pageSize: _messagePageSize,
      );

      _messages = response.messages;
      _messageTotalCount = response.totalCount;
      _messageTotalPages = response.totalPages;
      _messageCurrentPage = response.currentPage;

      _messageStatus = MessageStatus.loaded;
    } catch (e, stackTrace) {
      _messageStatus = MessageStatus.error;
      _messageErrorMessage = e.toString();
      AppLogger.error(
        'Error loading messages: $e',
        tag: 'ConversationProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }

    notifyListeners();
  }

  /// Load more messages (pagination - older messages)
  Future<void> loadMoreMessages(int conversationId) async {
    if (!hasMoreMessages || _messageStatus == MessageStatus.loadingMore) return;

    _messageStatus = MessageStatus.loadingMore;
    notifyListeners();

    try {
      final nextPage = _messageCurrentPage + 1;

      final response = await _getMessagesUseCase(
        conversationId: conversationId,
        page: nextPage,
        pageSize: _messagePageSize,
      );

      _messages.addAll(response.messages);
      _messageCurrentPage = response.currentPage;

      _messageStatus = MessageStatus.loaded;
    } catch (e, stackTrace) {
      _messageStatus = MessageStatus.error;
      _messageErrorMessage = e.toString();
      AppLogger.error(
        'Error loading more messages: $e',
        tag: 'ConversationProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }

    notifyListeners();
  }

  /// Get last message for a conversation (lazy loading for cards)
  /// Returns cached value if available, otherwise loads it
  String? getFirstMessage(int conversationId) {
    return _firstMessageCache[conversationId];
  }

  /// Check if last message is currently loading
  bool isLoadingFirstMessage(int conversationId) {
    return _loadingFirstMessages.contains(conversationId);
  }

  /// Load last (most recent) message for a conversation card (lazy loading)
  Future<void> loadFirstMessage(int conversationId) async {
    // Skip if already cached or currently loading
    if (_firstMessageCache.containsKey(conversationId) ||
        _loadingFirstMessages.contains(conversationId)) {
      return;
    }

    _loadingFirstMessages.add(conversationId);
    notifyListeners();

    try {
      // Load first page with just 1 message (the most recent)
      final response = await _getMessagesUseCase(
        conversationId: conversationId,
        page: 1,
        pageSize: 1,
      );

      // Get the most recent message (first in the list)
      // The API returns messages in reverse chronological order (newest first)
      if (response.messages.isNotEmpty) {
        final lastMessage = response.messages.first;
        _firstMessageCache[conversationId] = lastMessage.text ?? 'No message text';
      } else {
        _firstMessageCache[conversationId] = null;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error loading last message for conversation $conversationId: $e',
        tag: 'ConversationProvider',
        error: e,
        stackTrace: stackTrace,
      );
      _firstMessageCache[conversationId] = null;
    } finally {
      _loadingFirstMessages.remove(conversationId);
      notifyListeners();
    }
  }

  /// Send text message
  Future<bool> sendMessage(int conversationId, String text) async {
    _messageStatus = MessageStatus.sending;
    notifyListeners();

    try {
      final message = await _sendMessageUseCase(
        conversationId: conversationId,
        text: text,
      );

      // Add message to list
      _messages.insert(0, message);
      _messageTotalCount++;

      _messageStatus = MessageStatus.loaded;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _messageStatus = MessageStatus.error;
      _messageErrorMessage = 'Failed to send message: $e';
      AppLogger.error(
        'Error sending message: $e',
        tag: 'ConversationProvider',
        error: e,
        stackTrace: stackTrace,
      );
      notifyListeners();
      return false;
    }
  }

  /// Send media message
  Future<bool> sendMediaMessage({
    required int conversationId,
    required String filePath,
    required String fileName,
    String? caption,
  }) async {
    _messageStatus = MessageStatus.sending;
    notifyListeners();

    try {
      final message = await _sendMediaUseCase(
        conversationId: conversationId,
        filePath: filePath,
        fileName: fileName,
        caption: caption,
      );

      // Add message to list
      _messages.insert(0, message);
      _messageTotalCount++;

      _messageStatus = MessageStatus.loaded;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _messageStatus = MessageStatus.error;
      _messageErrorMessage = 'Failed to send media: $e';
      AppLogger.error(
        'Error sending media: $e',
        tag: 'ConversationProvider',
        error: e,
        stackTrace: stackTrace,
      );
      notifyListeners();
      return false;
    }
  }

  /// Update conversation status
  Future<bool> updateConversationStatus(int conversationId, int statusId) async {
    try {
      await _updateConversationStatusUseCase(
        conversationId: conversationId,
        statusId: statusId,
      );

      // Update in list if present
      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        // Reload the conversation to get updated data
        final updated = await _getConversationDetailUseCase(conversationId);
        _conversations[index] = updated;

        if (_selectedConversation?.id == conversationId) {
          _selectedConversation = updated;
        }
      }

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to update status: $e';
      AppLogger.error(
        'Error updating conversation status: $e',
        tag: 'ConversationProvider',
        error: e,
        stackTrace: stackTrace,
      );
      notifyListeners();
      return false;
    }
  }

  /// Assign conversation to agents
  Future<bool> assignConversation(int conversationId, List<int> agentIds) async {
    try {
      await _assignConversationUseCase(
        conversationId: conversationId,
        agentIds: agentIds,
      );

      // Update in list if present
      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        final updated = await _getConversationDetailUseCase(conversationId);
        _conversations[index] = updated;

        if (_selectedConversation?.id == conversationId) {
          _selectedConversation = updated;
        }
      }

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to assign conversation: $e';
      AppLogger.error(
        'Error assigning conversation: $e',
        tag: 'ConversationProvider',
        error: e,
        stackTrace: stackTrace,
      );
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear message error
  void clearMessageError() {
    _messageErrorMessage = null;
    notifyListeners();
  }

  /// Retry loading data
  Future<void> retry() async {
    _status = ConversationStatus.initial;
    _errorMessage = null;
    await loadConversations(resetPage: true);
  }

  /// Clear selected conversation
  void clearSelectedConversation() {
    _selectedConversation = null;
    _messages = [];
    _messageStatus = MessageStatus.initial;
    notifyListeners();
  }
}
