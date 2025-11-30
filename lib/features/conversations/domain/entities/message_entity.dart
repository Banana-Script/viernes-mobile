/// Message Entity
///
/// Domain entity representing a message in a conversation.
/// Can be text, media, file, or special messages (tool calls, system messages).
class MessageEntity {
  final int id;
  final int conversationId;
  final String? text;
  final String? media;
  final String? mediaType;
  final String? fileName;
  final bool fromUser;
  final bool fromAgent;
  final DateTime createdAt;
  final String? status; // 'sent', 'delivered', 'read', 'failed'
  final MessageType type;
  final int? agentId;
  final String? agentName;
  final Map<String, dynamic>? metadata; // For tool calls, etc

  const MessageEntity({
    required this.id,
    required this.conversationId,
    this.text,
    this.media,
    this.mediaType,
    this.fileName,
    required this.fromUser,
    required this.fromAgent,
    required this.createdAt,
    this.status,
    required this.type,
    this.agentId,
    this.agentName,
    this.metadata,
  });

  /// Check if message is from customer
  bool get isCustomerMessage => fromUser && !fromAgent;

  /// Check if message is from agent
  bool get isAgentMessage => fromAgent;

  /// Check if message is system/automated
  bool get isSystemMessage => !fromUser && !fromAgent;

  /// Check if message has media attachment
  bool get hasMedia => media != null && media!.isNotEmpty;

  /// Check if message has file attachment
  bool get hasFile => fileName != null && fileName!.isNotEmpty;

  /// Check if message has text
  bool get hasText => text != null && text!.isNotEmpty;

  /// Get media file extension
  String? get mediaExtension {
    if (media == null) return null;
    final uri = Uri.tryParse(media!);
    if (uri == null) return null;
    final path = uri.path;
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1) return null;
    return path.substring(lastDot + 1).toLowerCase();
  }

  /// Check if media is an image
  bool get isImage {
    if (mediaType != null) {
      return mediaType!.startsWith('image/');
    }
    final ext = mediaExtension;
    return ext != null && ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  /// Check if media is a video
  bool get isVideo {
    if (mediaType != null) {
      return mediaType!.startsWith('video/');
    }
    final ext = mediaExtension;
    return ext != null && ['mp4', 'mov', 'avi', 'webm'].contains(ext);
  }

  /// Check if media is audio
  bool get isAudio {
    if (mediaType != null) {
      return mediaType!.startsWith('audio/');
    }
    final ext = mediaExtension;
    return ext != null && ['mp3', 'wav', 'ogg', 'm4a'].contains(ext);
  }

  /// Check if media is a document
  bool get isDocument {
    if (mediaType != null) {
      return mediaType!.contains('pdf') ||
             mediaType!.contains('document') ||
             mediaType!.contains('spreadsheet') ||
             mediaType!.contains('presentation');
    }
    final ext = mediaExtension;
    return ext != null && ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].contains(ext);
  }
}

/// Message Type
enum MessageType {
  text,
  media,
  file,
  toolCall,
  system;

  /// Convert from string
  static MessageType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'media':
        return MessageType.media;
      case 'file':
        return MessageType.file;
      case 'tool_call':
      case 'toolcall':
        return MessageType.toolCall;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  /// Convert to string for API
  String toApiString() {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.media:
        return 'media';
      case MessageType.file:
        return 'file';
      case MessageType.toolCall:
        return 'tool_call';
      case MessageType.system:
        return 'system';
    }
  }
}

/// Messages Response for pagination
class MessagesResponse {
  final List<MessageEntity> messages;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const MessagesResponse({
    required this.messages,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  bool get hasMoreMessages => hasNextPage;
}
