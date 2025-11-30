import '../../domain/entities/internal_note_entity.dart';

/// Internal Note Model
///
/// Data model for internal note that extends the domain entity.
/// Handles JSON serialization/deserialization.
class InternalNoteModel extends InternalNoteEntity {
  const InternalNoteModel({
    required super.id,
    required super.conversationId,
    required super.agentId,
    required super.agentName,
    required super.content,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create from JSON
  factory InternalNoteModel.fromJson(Map<String, dynamic> json) {
    return InternalNoteModel(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int,
      agentId: json['agent_id'] as int? ?? json['user_id'] as int? ?? 0,
      agentName: json['agent_name'] as String? ??
          json['user_name'] as String? ??
          json['user']?['fullname'] as String? ??
          'Unknown',
      content: json['content'] as String? ?? json['note'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }

  /// Create from entity
  factory InternalNoteModel.fromEntity(InternalNoteEntity entity) {
    return InternalNoteModel(
      id: entity.id,
      conversationId: entity.conversationId,
      agentId: entity.agentId,
      agentName: entity.agentName,
      content: entity.content,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

/// Internal Notes Response Model
class InternalNotesResponseModel extends InternalNotesResponse {
  const InternalNotesResponseModel({
    required super.notes,
    required super.totalCount,
    required super.currentPage,
    required super.totalPages,
    required super.hasNextPage,
  });

  /// Create from JSON
  factory InternalNotesResponseModel.fromJson(Map<String, dynamic> json) {
    final notesList = (json['data'] as List?)
            ?.map((n) => InternalNoteModel.fromJson(n as Map<String, dynamic>))
            .toList() ??
        (json['notes'] as List?)
            ?.map((n) => InternalNoteModel.fromJson(n as Map<String, dynamic>))
            .toList() ??
        [];

    return InternalNotesResponseModel(
      notes: notesList,
      totalCount: json['total'] as int? ?? notesList.length,
      currentPage: json['current_page'] as int? ?? json['page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? json['pages'] as int? ?? 1,
      hasNextPage: json['has_next_page'] as bool? ??
          (json['current_page'] as int? ?? 1) < (json['total_pages'] as int? ?? 1),
    );
  }
}
