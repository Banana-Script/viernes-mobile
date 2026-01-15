/// Message Content Parser
///
/// Parses message text to detect media content patterns like:
/// - image::url
/// - audio::url
/// - video::url
/// - document::url
/// - location::lat,lng
/// - sticker::url

/// Types of media content that can be parsed from message text
enum MediaContentType {
  text,
  image,
  audio,
  video,
  document,
  location,
  sticker,
}

/// Parsed message content with extracted media information
class ParsedMessageContent {
  final MediaContentType type;
  final String? mediaUrl;
  final String? textContent;
  final double? latitude;
  final double? longitude;
  final String? fileName;

  const ParsedMessageContent({
    required this.type,
    this.mediaUrl,
    this.textContent,
    this.latitude,
    this.longitude,
    this.fileName,
  });

  /// Check if this is a media type (not plain text)
  bool get isMedia => type != MediaContentType.text;

  /// Check if this is a playable media (audio or video)
  bool get isPlayable =>
      type == MediaContentType.audio || type == MediaContentType.video;
}

/// Parser for extracting media content from message text
class MessageContentParser {
  // Regex patterns for different media types
  // Format: type::URL (URL continues until whitespace or end of string)
  static final _imagePattern = RegExp(r'image::(https?://[^\s]+)');
  static final _audioPattern = RegExp(r'audio::(https?://[^\s]+)');
  static final _videoPattern = RegExp(r'video::(https?://[^\s]+)');
  static final _documentPattern = RegExp(r'document::(https?://[^\s]+)');
  static final _stickerPattern = RegExp(r'sticker::(https?://[^\s]+)');
  static final _locationPattern =
      RegExp(r'location::(-?\d+\.?\d*),\s*(-?\d+\.?\d*)');

  // Pattern to detect if text is just a filename (not a real caption)
  static final _filenameOnlyPattern = RegExp(
    r'^(scaled_)?[a-zA-Z0-9_-]+\.(jpg|jpeg|png|gif|webp|mp4|mov|avi|mp3|wav|ogg|pdf|doc|docx|xls|xlsx|ppt|pptx|txt|zip)$',
    caseSensitive: false,
  );

  /// Check if text is just a filename and should not be shown as caption
  static String? _filterFilenameText(String? text, String? mediaUrl) {
    if (text == null || text.isEmpty) return null;

    // Check if the text matches a filename pattern
    if (_filenameOnlyPattern.hasMatch(text)) {
      return null;
    }

    // Check if the text matches the filename from the URL
    if (mediaUrl != null) {
      final urlFileName = _extractFileName(mediaUrl);
      if (urlFileName != null && text == urlFileName) {
        return null;
      }
    }

    return text;
  }

  /// Parse message text and extract media content
  static ParsedMessageContent parse(String? text) {
    if (text == null || text.isEmpty) {
      return const ParsedMessageContent(
        type: MediaContentType.text,
        textContent: '',
      );
    }

    // Check for image pattern
    final imageMatch = _imagePattern.firstMatch(text);
    if (imageMatch != null) {
      final url = imageMatch.group(1);
      final remainingText = text.replaceFirst(_imagePattern, '').trim();
      return ParsedMessageContent(
        type: MediaContentType.image,
        mediaUrl: url,
        textContent: _filterFilenameText(remainingText.isNotEmpty ? remainingText : null, url),
        fileName: _extractFileName(url),
      );
    }

    // Check for audio pattern
    final audioMatch = _audioPattern.firstMatch(text);
    if (audioMatch != null) {
      final url = audioMatch.group(1);
      final remainingText = text.replaceFirst(_audioPattern, '').trim();
      return ParsedMessageContent(
        type: MediaContentType.audio,
        mediaUrl: url,
        textContent: _filterFilenameText(remainingText.isNotEmpty ? remainingText : null, url),
        fileName: _extractFileName(url),
      );
    }

    // Check for video pattern
    final videoMatch = _videoPattern.firstMatch(text);
    if (videoMatch != null) {
      final url = videoMatch.group(1);
      final remainingText = text.replaceFirst(_videoPattern, '').trim();
      return ParsedMessageContent(
        type: MediaContentType.video,
        mediaUrl: url,
        textContent: _filterFilenameText(remainingText.isNotEmpty ? remainingText : null, url),
        fileName: _extractFileName(url),
      );
    }

    // Check for document pattern
    final documentMatch = _documentPattern.firstMatch(text);
    if (documentMatch != null) {
      final url = documentMatch.group(1);
      final remainingText = text.replaceFirst(_documentPattern, '').trim();
      return ParsedMessageContent(
        type: MediaContentType.document,
        mediaUrl: url,
        textContent: _filterFilenameText(remainingText.isNotEmpty ? remainingText : null, url),
        fileName: _extractFileName(url),
      );
    }

    // Check for sticker pattern (treat as image)
    final stickerMatch = _stickerPattern.firstMatch(text);
    if (stickerMatch != null) {
      final url = stickerMatch.group(1);
      return ParsedMessageContent(
        type: MediaContentType.sticker,
        mediaUrl: url,
        fileName: _extractFileName(url),
      );
    }

    // Check for location pattern
    final locationMatch = _locationPattern.firstMatch(text);
    if (locationMatch != null) {
      final lat = double.tryParse(locationMatch.group(1) ?? '');
      final lng = double.tryParse(locationMatch.group(2) ?? '');
      if (lat != null && lng != null) {
        final remainingText = text.replaceFirst(_locationPattern, '').trim();
        return ParsedMessageContent(
          type: MediaContentType.location,
          latitude: lat,
          longitude: lng,
          textContent: _filterFilenameText(remainingText.isNotEmpty ? remainingText : null, null),
        );
      }
    }

    // Default: plain text
    return ParsedMessageContent(
      type: MediaContentType.text,
      textContent: text,
    );
  }

  /// Extract filename from URL
  static String? _extractFileName(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return Uri.decodeComponent(pathSegments.last);
      }
    } catch (_) {
      // Ignore parsing errors
    }
    return null;
  }

  /// Get file extension from URL
  static String? getFileExtension(String? url) {
    final fileName = _extractFileName(url);
    if (fileName == null) return null;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < fileName.length - 1) {
      return fileName.substring(dotIndex + 1).toLowerCase();
    }
    return null;
  }

  /// Check if URL is likely an image
  static bool isImageUrl(String? url) {
    final ext = getFileExtension(url);
    if (ext == null) return false;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }

  /// Check if URL is likely an audio file
  static bool isAudioUrl(String? url) {
    final ext = getFileExtension(url);
    if (ext == null) return false;
    return ['mp3', 'wav', 'ogg', 'm4a', 'aac', 'flac', 'opus'].contains(ext);
  }

  /// Check if URL is likely a video file
  static bool isVideoUrl(String? url) {
    final ext = getFileExtension(url);
    if (ext == null) return false;
    return ['mp4', 'mov', 'avi', 'webm', 'mkv', '3gp'].contains(ext);
  }

  /// Check if URL is likely a document
  static bool isDocumentUrl(String? url) {
    final ext = getFileExtension(url);
    if (ext == null) return false;
    return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt']
        .contains(ext);
  }

  /// Get a preview text for message list (e.g., "📷 Imagen" instead of raw URL)
  /// Returns null if it's plain text (no special preview needed)
  static String? getPreviewText(String? text, {
    String imageLabel = '📷 Imagen',
    String audioLabel = '🎵 Audio',
    String videoLabel = '🎬 Video',
    String documentLabel = '📄 Documento',
    String locationLabel = '📍 Ubicación',
    String stickerLabel = '🎭 Sticker',
  }) {
    if (text == null || text.isEmpty) return null;

    final parsed = parse(text);

    switch (parsed.type) {
      case MediaContentType.image:
        return parsed.textContent != null
            ? '$imageLabel: ${parsed.textContent}'
            : imageLabel;
      case MediaContentType.audio:
        return parsed.textContent != null
            ? '$audioLabel: ${parsed.textContent}'
            : audioLabel;
      case MediaContentType.video:
        return parsed.textContent != null
            ? '$videoLabel: ${parsed.textContent}'
            : videoLabel;
      case MediaContentType.document:
        return parsed.textContent != null
            ? '$documentLabel: ${parsed.textContent}'
            : documentLabel;
      case MediaContentType.location:
        return parsed.textContent != null
            ? '$locationLabel: ${parsed.textContent}'
            : locationLabel;
      case MediaContentType.sticker:
        return stickerLabel;
      case MediaContentType.text:
        return null; // No special preview, use original text
    }
  }
}
