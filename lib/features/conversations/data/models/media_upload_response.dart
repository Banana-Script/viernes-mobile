/// Response model for media upload to S3
class MediaUploadResponse {
  final String mediaId;
  final String fileUrl;
  final String? originalFilename;

  MediaUploadResponse({
    required this.mediaId,
    required this.fileUrl,
    this.originalFilename,
  });

  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) {
    return MediaUploadResponse(
      mediaId: json['media_id'] as String,
      fileUrl: json['s3_file_path'] as String,
      originalFilename: json['original_filename'] as String?,
    );
  }
}
