import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import '../../../../../core/theme/viernes_colors.dart';
import '../../../../../core/theme/viernes_spacing.dart';
import '../../../../../core/theme/viernes_text_styles.dart';

/// Image Message Widget
///
/// Displays an image with tap to open fullscreen with zoom capability.
class ImageMessageWidget extends StatelessWidget {
  final String url;
  final String? fileName;
  final String? caption;
  final double? maxWidth;
  final double? maxHeight;

  const ImageMessageWidget({
    super.key,
    required this.url,
    this.fileName,
    this.caption,
    this.maxWidth = 250,
    this.maxHeight = 300,
  });

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenImageView(
          url: url,
          fileName: fileName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image with tap to fullscreen
        GestureDetector(
          onTap: () => _openFullScreen(context),
          child: Hero(
            tag: 'image_$url',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth ?? 250,
                  maxHeight: maxHeight ?? 300,
                ),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 200,
                    height: 150,
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 200,
                    height: 150,
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          color: ViernesColors.getTextColor(isDark).withOpacity(0.5),
                          size: 48,
                        ),
                        const SizedBox(height: ViernesSpacing.xs),
                        Text(
                          'Failed to load image',
                          style: ViernesTextStyles.caption.copyWith(
                            color: ViernesColors.getTextColor(isDark).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Caption (if available)
        if (caption != null && caption!.isNotEmpty) ...[
          const SizedBox(height: ViernesSpacing.xs),
          Text(
            caption!,
            style: ViernesTextStyles.bodyText.copyWith(
              color: ViernesColors.getTextColor(isDark),
            ),
          ),
        ],
      ],
    );
  }
}

/// Fullscreen image view with zoom
class _FullScreenImageView extends StatelessWidget {
  final String url;
  final String? fileName;

  const _FullScreenImageView({
    required this.url,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: fileName != null
            ? Text(
                fileName!,
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Download functionality could be added here
            },
          ),
        ],
      ),
      body: Hero(
        tag: 'image_$url',
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(url),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          loadingBuilder: (context, event) => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          errorBuilder: (context, error, stackTrace) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 64,
                ),
                const SizedBox(height: ViernesSpacing.md),
                Text(
                  'Failed to load image',
                  style: ViernesTextStyles.bodyText.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sticker Message Widget
///
/// Similar to image but without border radius and typically smaller.
class StickerMessageWidget extends StatelessWidget {
  final String url;
  final double size;

  const StickerMessageWidget({
    super.key,
    required this.url,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholder: (context, url) => SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => SizedBox(
        width: size,
        height: size,
        child: Icon(
          Icons.broken_image,
          color: ViernesColors.getTextColor(isDark).withOpacity(0.5),
          size: 48,
        ),
      ),
    );
  }
}
