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
    // Extract author info - API returns author object with id and fullname
    final author = json['author'] as Map<String, dynamic>?;

    return InternalNoteModel(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int,
      agentId: json['user_id'] as int? ?? author?['id'] as int? ?? 0,
      agentName: author?['fullname'] as String? ?? 'Unknown',
      content: json['note'] as String? ?? json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'note': content,
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

    // API returns pagination object with page, page_size, total, total_pages
    final pagination = json['pagination'] as Map<String, dynamic>?;
    final currentPage = pagination?['page'] as int? ?? json['page'] as int? ?? 1;
    final totalPages = pagination?['total_pages'] as int? ?? json['total_pages'] as int? ?? 1;
    final total = pagination?['total'] as int? ?? json['total'] as int? ?? notesList.length;

    return InternalNotesResponseModel(
      notes: notesList,
      totalCount: total,
      currentPage: currentPage,
      totalPages: totalPages,
      hasNextPage: currentPage < totalPages,
    );
  }
}
