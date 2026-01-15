import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../../../core/theme/viernes_colors.dart';
import '../../../../../core/theme/viernes_spacing.dart';
import '../../../../../core/theme/viernes_text_styles.dart';
import '../../../../../gen_l10n/app_localizations.dart';

/// Video Player Widget
///
/// An inline video player for playing video messages.
/// Uses Chewie for a polished UI with play/pause, progress, and fullscreen.
class VideoPlayerWidget extends StatefulWidget {
  final String url;
  final String? fileName;
  final double? maxHeight;

  const VideoPlayerWidget({
    super.key,
    required this.url,
    this.fileName,
    this.maxHeight = 250,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url));

      await _videoController!.initialize();

      // Check if widget is still mounted after async operation
      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        showControls: true,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: false,
        placeholder: _buildPlaceholder(),
        errorBuilder: (context, errorMessage) {
          final l10n = AppLocalizations.of(context)!;
          return _buildErrorWidget(l10n, errorMessage);
        },
        materialProgressColors: ChewieProgressColors(
          playedColor: ViernesColors.primary,
          handleColor: ViernesColors.primary,
          backgroundColor: Colors.grey.shade300,
          bufferedColor: ViernesColors.primary.withOpacity(0.3),
        ),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[VideoPlayer] Error loading video: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers safely with error handling
    try {
      _chewieController?.dispose();
    } catch (e) {
      debugPrint('[VideoPlayer] Error disposing chewie: $e');
    }
    try {
      _videoController?.dispose();
    } catch (e) {
      debugPrint('[VideoPlayer] Error disposing video: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Video player
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: widget.maxHeight ?? 250,
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildVideoContent(l10n),
          ),
        ),

        // File name (if available)
        if (widget.fileName != null) ...[
          const SizedBox(height: ViernesSpacing.xs),
          Row(
            children: [
              Icon(
                Icons.video_file,
                size: 14,
                color: ViernesColors.getTextColor(isDark).withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.fileName!,
                  style: ViernesTextStyles.caption.copyWith(
                    color: ViernesColors.getTextColor(isDark).withOpacity(0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildVideoContent(AppLocalizations l10n) {
    if (_isLoading) {
      return _buildLoadingWidget(l10n);
    }

    if (_hasError || _chewieController == null) {
      return _buildErrorWidget(l10n, _errorMessage ?? l10n.failedToLoadVideo);
    }

    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }

  Widget _buildLoadingWidget(AppLocalizations l10n) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
              const SizedBox(height: ViernesSpacing.sm),
              Text(
                l10n.loadingVideo,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(
          Icons.play_circle_outline,
          color: Colors.white54,
          size: 64,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(AppLocalizations l10n, String message) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: ViernesColors.danger,
                size: 48,
              ),
              const SizedBox(height: ViernesSpacing.sm),
              Text(
                l10n.failedToLoadVideo,
                style: ViernesTextStyles.bodyText.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: ViernesSpacing.xs),
              TextButton(
                onPressed: () {
                  // Dispose existing controllers before re-init to prevent memory leak
                  try { _chewieController?.dispose(); } catch (_) {}
                  try { _videoController?.dispose(); } catch (_) {}
                  _chewieController = null;
                  _videoController = null;
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  _initPlayer();
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
