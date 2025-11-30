/// Internal Note Entity
///
/// Domain entity representing an internal note in a conversation.
/// Internal notes are visible only to agents, not to customers.
class InternalNoteEntity {
  final int id;
  final int conversationId;
  final int agentId;
  final String agentName;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const InternalNoteEntity({
    required this.id,
    required this.conversationId,
    required this.agentId,
    required this.agentName,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if note was edited
  bool get wasEdited => updatedAt != null && updatedAt != createdAt;

  /// Copy with new values
  InternalNoteEntity copyWith({
    int? id,
    int? conversationId,
    int? agentId,
    String? agentName,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InternalNoteEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Internal Notes Response for pagination
class InternalNotesResponse {
  final List<InternalNoteEntity> notes;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;

  const InternalNotesResponse({
    required this.notes,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
  });
}
