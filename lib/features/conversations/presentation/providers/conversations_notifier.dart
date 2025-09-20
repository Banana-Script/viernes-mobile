import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/usecases/get_conversations.dart';
import 'conversations_state.dart';
import 'conversations_providers.dart';

class ConversationsNotifier extends StateNotifier<ConversationsState> {
  final GetAllConversations _getAllConversations;
  final GetMyConversations _getMyConversations;
  final GetViernesConversations _getViernesConversations;

  Timer? _debounceTimer;

  ConversationsNotifier(
    this._getAllConversations,
    this._getMyConversations,
    this._getViernesConversations,
  ) : super(const ConversationsState());

  Future<void> loadConversations({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        conversations: [],
        currentPage: 1,
        hasMore: true,
        error: null,
      );
    }

    if (state.isLoading || (!state.hasMore && !refresh)) return;

    state = state.copyWith(
      isLoading: state.isFirstPage,
      isLoadingMore: !state.isFirstPage,
      error: null,
    );

    final params = ConversationsParams(
      page: state.currentPage,
      pageSize: state.pageSize,
      searchTerm: state.searchQuery,
      filters: state.filters,
    );

    final result = await _getConversationsForViewMode(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: failure.message,
        );
      },
      (response) {
        final newConversations = state.isFirstPage
            ? response.conversations
            : [...state.conversations, ...response.conversations];

        state = state.copyWith(
          conversations: newConversations,
          isLoading: false,
          isLoadingMore: false,
          currentPage: state.currentPage + 1,
          hasMore: response.conversations.length >= state.pageSize,
          totalCount: response.totalCount,
          error: null,
        );
      },
    );
  }

  Future<void> searchConversations(String query) async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (state.searchQuery != query) {
        state = state.copyWith(
          searchQuery: query,
          currentPage: 1,
          hasMore: true,
        );
        loadConversations(refresh: true);
      }
    });
  }

  void changeViewMode(String viewMode) {
    if (state.viewMode != viewMode) {
      state = state.copyWith(
        viewMode: viewMode,
        currentPage: 1,
        hasMore: true,
      );
      loadConversations(refresh: true);
    }
  }

  void applyFilters(String filters) {
    if (state.filters != filters) {
      state = state.copyWith(
        filters: filters,
        currentPage: 1,
        hasMore: true,
      );
      loadConversations(refresh: true);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<dynamic> _getConversationsForViewMode(ConversationsParams params) async {
    switch (state.viewMode) {
      case 'my':
        // TODO: Get current user agent ID from auth provider
        final agentId = 1; // Replace with actual agent ID
        return await _getMyConversations(agentId, params);
      case 'viernes':
        return await _getViernesConversations(params);
      case 'all':
      default:
        return await _getAllConversations(params);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final conversationsNotifierProvider =
    StateNotifierProvider<ConversationsNotifier, ConversationsState>((ref) {
  return ConversationsNotifier(
    ref.watch(getAllConversationsUseCaseProvider),
    ref.watch(getMyConversationsUseCaseProvider),
    ref.watch(getViernesConversationsUseCaseProvider),
  );
});