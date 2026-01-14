import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/viernes_colors.dart';
import '../../../../../core/theme/viernes_spacing.dart';
import '../../../../../core/theme/viernes_text_styles.dart';

/// Audio Player Widget
///
/// A compact audio player for playing audio messages inline.
/// Features play/pause, progress bar, duration, and download button.
class AudioPlayerWidget extends StatefulWidget {
  final String url;
  final String? fileName;
  final Color? backgroundColor;

  const AudioPlayerWidget({
    super.key,
    required this.url,
    this.fileName,
    this.backgroundColor,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _player;
  bool _isLoading = true;
  bool _hasError = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Store subscriptions to cancel them on dispose
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      // Listen to player state changes
      _subscriptions.add(
        _player.playerStateStream.listen((state) {
          if (mounted) {
            setState(() {});
          }
        }),
      );

      // Listen to duration changes
      _subscriptions.add(
        _player.durationStream.listen((duration) {
          if (mounted && duration != null) {
            setState(() {
              _duration = duration;
            });
          }
        }),
      );

      // Listen to position changes
      _subscriptions.add(
        _player.positionStream.listen((position) {
          if (mounted) {
            setState(() {
              _position = position;
            });
          }
        }),
      );

      // Set the audio source
      await _player.setUrl(widget.url);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[AudioPlayer] Error loading audio: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    // Cancel all subscriptions first
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void _seekTo(double value) {
    final position = Duration(milliseconds: (value * _duration.inMilliseconds).round());
    _player.seek(position);
  }

  Future<void> _downloadAudio() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? ViernesColors.panelDark : Colors.grey.shade100);

    return Container(
      padding: const EdgeInsets.all(ViernesSpacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ViernesColors.getBorderColor(isDark),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Play/Pause button
              _buildPlayButton(isDark),
              const SizedBox(width: ViernesSpacing.sm),

              // Progress and duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress bar
                    _buildProgressBar(isDark),
                    const SizedBox(height: 4),
                    // Duration
                    _buildDurationRow(isDark),
                  ],
                ),
              ),

              const SizedBox(width: ViernesSpacing.sm),

              // Download button
              _buildDownloadButton(isDark),
            ],
          ),

          // File name (if available)
          if (widget.fileName != null) ...[
            const SizedBox(height: ViernesSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.audio_file,
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
      ),
    );
  }

  Widget _buildPlayButton(bool isDark) {
    if (_isLoading) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: ViernesColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_hasError) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: ViernesColors.danger.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.error_outline,
          color: ViernesColors.danger,
          size: 24,
        ),
      );
    }

    final isPlaying = _player.playing;

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: ViernesColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
        activeTrackColor: ViernesColors.primary,
        inactiveTrackColor: ViernesColors.getBorderColor(isDark),
        thumbColor: ViernesColors.primary,
        overlayColor: ViernesColors.primary.withOpacity(0.2),
      ),
      child: Slider(
        value: progress.clamp(0.0, 1.0),
        onChanged: _hasError || _isLoading ? null : _seekTo,
      ),
    );
  }

  Widget _buildDurationRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _formatDuration(_position),
          style: ViernesTextStyles.caption.copyWith(
            color: ViernesColors.getTextColor(isDark).withOpacity(0.7),
            fontSize: 11,
          ),
        ),
        Text(
          _formatDuration(_duration),
          style: ViernesTextStyles.caption.copyWith(
            color: ViernesColors.getTextColor(isDark).withOpacity(0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadButton(bool isDark) {
    return IconButton(
      onPressed: _downloadAudio,
      icon: Icon(
        Icons.download,
        color: ViernesColors.getTextColor(isDark).withOpacity(0.7),
        size: 20,
      ),
      tooltip: 'Download',
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.all(8),
    );
  }
}
