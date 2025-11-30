import 'dart:typed_data';

/// Attachment status during upload/send lifecycle
enum AttachmentStatus {
  pending,    // Selected, not yet uploading
  uploading,  // Upload in progress
  uploaded,   // Upload complete, ready to send
  sending,    // Being sent as message
  sent,       // Successfully sent
  error,      // Upload or send failed
}

/// Attachment type
enum AttachmentType {
  image,
  document,
}

/// Represents a file attachment in the message composer
class AttachmentModel {
  final String id;
  final String path;
  final String fileName;
  final int fileSize;
  final AttachmentType type;
  final String? mimeType;
  final AttachmentStatus status;
  final double uploadProgress;
  final String? errorMessage;
  final String? remoteUrl;
  final String? mediaId;
  final Uint8List? thumbnail;

  const AttachmentModel({
    required this.id,
    required this.path,
    required this.fileName,
    required this.fileSize,
    required this.type,
    this.mimeType,
    this.status = AttachmentStatus.pending,
    this.uploadProgress = 0.0,
    this.errorMessage,
    this.remoteUrl,
    this.mediaId,
    this.thumbnail,
  });

  /// Create a copy with updated fields
  AttachmentModel copyWith({
    String? id,
    String? path,
    String? fileName,
    int? fileSize,
    AttachmentType? type,
    String? mimeType,
    AttachmentStatus? status,
    double? uploadProgress,
    String? errorMessage,
    String? remoteUrl,
    String? mediaId,
    Uint8List? thumbnail,
    bool clearErrorMessage = false,
    bool clearRemoteUrl = false,
    bool clearMediaId = false,
  }) {
    return AttachmentModel(
      id: id ?? this.id,
      path: path ?? this.path,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      status: status ?? this.status,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      remoteUrl: clearRemoteUrl ? null : (remoteUrl ?? this.remoteUrl),
      mediaId: clearMediaId ? null : (mediaId ?? this.mediaId),
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  /// Format file size for display (e.g., "2.3 MB")
  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get file extension
  String get extension => fileName.split('.').last.toLowerCase();

  /// Check if this is an image
  bool get isImage => type == AttachmentType.image;

  /// Check if this is a document
  bool get isDocument => type == AttachmentType.document;

  /// Check if upload is in progress
  bool get isUploading => status == AttachmentStatus.uploading;

  /// Check if ready to send
  bool get isReadyToSend => status == AttachmentStatus.uploaded;

  /// Check if has error
  bool get hasError => status == AttachmentStatus.error;

  /// Max file sizes in bytes
  static const int maxImageSize = 5 * 1024 * 1024;       // 5MB for images
  static const int maxDocumentSize = 100 * 1024 * 1024;  // 100MB for documents
  static const int maxTextFileSize = 1 * 1024 * 1024;    // 1MB for text files

  /// Max message length (WhatsApp limit)
  static const int maxMessageLength = 4096;

  /// Allowed image extensions
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];

  /// Allowed document extensions
  static const List<String> allowedDocumentExtensions = [
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'
  ];

  /// Text file extensions (special 1MB limit)
  static const List<String> textFileExtensions = ['txt'];

  /// Check if extension is a text file
  static bool isTextFile(String extension) {
    return textFileExtensions.contains(extension.toLowerCase());
  }

  /// Validate file size (backwards compatible - uses image size as default)
  static bool isValidSize(int size) => size <= maxImageSize;

  /// Validate file size based on type and extension
  static bool isValidSizeForType(int size, AttachmentType type, String? extension) {
    switch (type) {
      case AttachmentType.image:
        return size <= maxImageSize;
      case AttachmentType.document:
        // Text files have a special 1MB limit
        if (extension != null && isTextFile(extension)) {
          return size <= maxTextFileSize;
        }
        return size <= maxDocumentSize;
    }
  }

  /// Get max size for type and extension
  static int getMaxSizeForType(AttachmentType type, String? extension) {
    switch (type) {
      case AttachmentType.image:
        return maxImageSize;
      case AttachmentType.document:
        if (extension != null && isTextFile(extension)) {
          return maxTextFileSize;
        }
        return maxDocumentSize;
    }
  }

  /// Get formatted max size for type
  static String getFormattedMaxSizeForType(AttachmentType type, String? extension) {
    final maxSize = getMaxSizeForType(type, extension);
    if (maxSize >= 1024 * 1024) {
      return '${maxSize ~/ (1024 * 1024)}MB';
    }
    return '${maxSize ~/ 1024}KB';
  }

  /// Get MIME type from extension
  static String? getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      default:
        return null;
    }
  }
}
