import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/conversation.dart';

part 'conversations_state.freezed.dart';

@freezed
class ConversationsState with _$ConversationsState {
  const factory ConversationsState({
    @Default([]) List<Conversation> conversations,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasMore,
    @Default(1) int currentPage,
    @Default(10) int pageSize,
    @Default(0) int totalCount,
    @Default('') String searchQuery,
    @Default('') String filters,
    @Default('all') String viewMode, // 'all', 'my', 'viernes'
    String? error,
  }) = _ConversationsState;

  const ConversationsState._();

  bool get isEmpty => conversations.isEmpty && !isLoading;
  bool get hasConversations => conversations.isNotEmpty;
  bool get isFirstPage => currentPage == 1;
}