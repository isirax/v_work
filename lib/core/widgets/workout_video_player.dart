import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';

class WorkoutVideoPlayer extends StatefulWidget {
  final String assetVideoPath;
  final String onlineVideoUrl;
  final String? exerciseTitle;
  final bool isOnline;
  final bool autoPlay;
  final bool looping;
  final double height;
  final VoidCallback? onToggleOnline;

  const WorkoutVideoPlayer({
    super.key,
    required this.assetVideoPath,
    required this.onlineVideoUrl,
    this.exerciseTitle,
    this.isOnline = false,
    this.autoPlay = true,
    this.looping = true,
    this.height = 230,
    this.onToggleOnline,
  });

  @override
  State<WorkoutVideoPlayer> createState() => _WorkoutVideoPlayerState();
}

class _WorkoutVideoPlayerState extends State<WorkoutVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isUsingFallback = false;
  bool _showControls = true;
  bool _isMuted = true;
  double _playbackSpeed = 1.0;
  bool _isGifPlaying = true;
  BoxFit _gifFit = BoxFit.contain;

  bool get _isGif {
    final path = widget.isOnline ? widget.onlineVideoUrl : widget.assetVideoPath;
    return path.toLowerCase().endsWith('.gif');
  }

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant WorkoutVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOnline != widget.isOnline ||
        oldWidget.assetVideoPath != widget.assetVideoPath ||
        oldWidget.onlineVideoUrl != widget.onlineVideoUrl) {
      _initPlayer();
    }
  }

  Future<void> _initPlayer() async {
    final oldController = _controller;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
        _isUsingFallback = false;
        _isGifPlaying = widget.autoPlay;
      });
    }

    if (oldController != null) {
      try {
        await oldController.dispose();
      } catch (_) {}
      _controller = null;
    }

    // Handle GIF animations (Exercises Dataset)
    if (_isGif) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
          _isUsingFallback = false;
        });
      }
      return;
    }

    // Handle MP4 Video Playback
    try {
      VideoPlayerController controller;

      if (widget.isOnline) {
        // Attempt network stream first
        try {
          final uri = Uri.tryParse(widget.onlineVideoUrl);
          if (uri == null || !uri.hasScheme) {
            throw Exception('Invalid online video URI');
          }
          final netController = VideoPlayerController.networkUrl(
            uri,
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );
          await netController.initialize();
          controller = netController;
          _isUsingFallback = false;
        } catch (_) {
          // If online server/stream is unreachable, fallback to high-res local asset
          final localController = VideoPlayerController.asset(
            widget.assetVideoPath,
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );
          await localController.initialize();
          controller = localController;
          _isUsingFallback = true;
        }
      } else {
        // Local asset playback
        final localController = VideoPlayerController.asset(
          widget.assetVideoPath,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        await localController.initialize();
        controller = localController;
        _isUsingFallback = false;
      }

      await controller.setLooping(widget.looping);
      try {
        await controller.setVolume(_isMuted ? 0.0 : 1.0);
      } catch (_) {}
      try {
        await controller.setPlaybackSpeed(_playbackSpeed);
      } catch (_) {}

      if (widget.autoPlay) {
        try {
          await controller.play();
        } catch (e) {
          debugPrint('[WorkoutVideoPlayer] Autoplay prevented: $e');
        }
      }

      controller.addListener(_controllerListener);

      if (mounted) {
        setState(() {
          _controller = controller;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _controllerListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_controllerListener);
    try {
      _controller?.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _togglePlayPause() {
    if (_isGif) {
      setState(() {
        _isGifPlaying = !_isGifPlaying;
      });
      return;
    }
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    setState(() {});
  }

  void _toggleMute() {
    if (_controller == null) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _toggleGifFit() {
    setState(() {
      _gifFit = _gifFit == BoxFit.contain ? BoxFit.cover : BoxFit.contain;
    });
  }

  void _cyclePlaybackSpeed() {
    if (_controller == null) return;
    final speeds = [0.5, 0.75, 1.0, 1.25];
    final currentIndex = speeds.indexOf(_playbackSpeed);
    final nextSpeed = speeds[(currentIndex + 1) % speeds.length];
    setState(() {
      _playbackSpeed = nextSpeed;
      _controller!.setPlaybackSpeed(_playbackSpeed);
    });
  }

  Future<void> _launchYouTubeTutorial() async {
    final query = widget.exerciseTitle != null
        ? '${widget.exerciseTitle} exercise form tutorial'
        : 'workout exercise form tutorial';
    final url = Uri.parse(
        'https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Fallback to web browser view
      await launchUrl(url, mode: LaunchMode.platformDefault);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildGifSurface() {
    final thumbPath = widget.assetVideoPath
        .replaceAll('.gif', '.jpg')
        .replaceAll('assets/exercises/', 'assets/exercises/thumbs/');

    return GestureDetector(
      onTap: () {
        setState(() => _showControls = !_showControls);
      },
      child: Center(
        child: !_isGifPlaying
            ? Image.asset(
                thumbPath,
                fit: _gifFit,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  widget.assetVideoPath,
                  fit: _gifFit,
                ),
              )
            : (widget.isOnline && !_isUsingFallback
                ? Image.network(
                    widget.onlineVideoUrl,
                    fit: _gifFit,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            widget.assetVideoPath,
                            fit: _gifFit,
                            errorBuilder: (ctx, err, st) => const SizedBox(),
                          ),
                          Container(
                            color: Colors.black26,
                            child: const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryVolt),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to local asset seamlessly
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && !_isUsingFallback) {
                          setState(() => _isUsingFallback = true);
                        }
                      });
                      return Image.asset(
                        widget.assetVideoPath,
                        fit: _gifFit,
                      );
                    },
                  )
                : Image.asset(
                    widget.assetVideoPath,
                    fit: _gifFit,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fitness_center_rounded,
                              size: 40, color: AppColors.primaryVolt),
                          const SizedBox(height: 8),
                          Text(
                            widget.exerciseTitle ?? 'Exercise Animation',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0D14) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Surface (GIF Animation or Video Player)
            if (_isGif)
              _buildGifSurface()
            else if (_controller != null &&
                _controller!.value.isInitialized &&
                !_hasError)
              GestureDetector(
                onTap: () {
                  setState(() => _showControls = !_showControls);
                },
                child: Center(
                  child: AspectRatio(
                    aspectRatio: (_controller!.value.aspectRatio > 0)
                        ? _controller!.value.aspectRatio
                        : 16 / 9,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              )
            else if (_isLoading)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primaryVolt),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.isOnline
                          ? 'Connecting HD video stream...'
                          : 'Loading local exercise video...',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              )
            else if (_hasError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.errorRed, size: 36),
                      const SizedBox(height: 8),
                      const Text(
                        'Unable to load video stream',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _errorMessage,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white60),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryVolt,
                              side: const BorderSide(
                                  color: AppColors.primaryVolt),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: _initPlayer,
                            icon: const Icon(Icons.refresh, size: 14),
                            label: const Text('Retry',
                                style: TextStyle(fontSize: 11)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF0000),
                              foregroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: _launchYouTubeTutorial,
                            icon: const Icon(Icons.play_circle_fill_rounded,
                                size: 14),
                            label: const Text('YouTube',
                                style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // 2. Top Header Bar (Badge Status + Controls: Zoom, Speed, Mute, YouTube)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  // Mode Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.isOnline
                            ? (_isUsingFallback
                                ? AppColors.primaryOrange
                                : AppColors.primaryCyan)
                            : AppColors.primaryVolt,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isOnline
                              ? (_isUsingFallback
                                  ? Icons.cloud_off_rounded
                                  : Icons.cloud_outlined)
                              : (_isGif
                                  ? Icons.animation_rounded
                                  : Icons.play_circle_fill_rounded),
                          size: 13,
                          color: widget.isOnline
                              ? (_isUsingFallback
                                  ? AppColors.primaryOrange
                                  : AppColors.primaryCyan)
                              : AppColors.primaryVolt,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.isOnline
                              ? (_isUsingFallback
                                  ? 'STREAM: LOCAL CACHE'
                                  : (_isGif ? 'ONLINE HD GIF' : 'ONLINE HD STREAM'))
                              : (_isGif
                                  ? 'HD ANIMATION LOOP'
                                  : 'DETAILED VIDEO (MP4)'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: widget.isOnline
                                ? (_isUsingFallback
                                    ? AppColors.primaryOrange
                                    : AppColors.primaryCyan)
                                : AppColors.primaryVolt,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_isGif) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Gym visual',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],

                  const Spacer(),

                  // GIF Fit Mode Toggle
                  if (_isGif)
                    InkWell(
                      onTap: _toggleGifFit,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _gifFit == BoxFit.contain
                              ? Icons.fit_screen_rounded
                              : Icons.fullscreen_exit_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  // Speed Control for Video
                  if (!_isGif &&
                      _controller != null &&
                      _controller!.value.isInitialized)
                    InkWell(
                      onTap: _cyclePlaybackSpeed,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_playbackSpeed}x',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  // Sound / Mute Button for Video
                  if (!_isGif &&
                      _controller != null &&
                      _controller!.value.isInitialized)
                    InkWell(
                      onTap: _toggleMute,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _isMuted
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  // Open in YouTube Button
                  InkWell(
                    onTap: _launchYouTubeTutorial,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0000).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.open_in_new_rounded,
                              size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'YouTube',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Center Play / Pause Indicator
            if (_showControls)
              if (_isGif && !_isGifPlaying)
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 34,
                      color: AppColors.primaryVolt,
                    ),
                  ),
                )
              else if (!_isGif &&
                  _controller != null &&
                  _controller!.value.isInitialized)
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _controller!.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 34,
                      color: AppColors.primaryVolt,
                    ),
                  ),
                ),

            // 4. Fallback banner notification if online failed over to local
            if (_isUsingFallback && widget.isOnline)
              Positioned(
                bottom: 38,
                left: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: AppColors.primaryOrange.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wifi_off_rounded,
                          size: 12, color: AppColors.primaryOrange),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Web stream offline — playing high-speed local animation.',
                          style: TextStyle(fontSize: 10, color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 5. Bottom Overlay
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black87],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: _isGif
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.all_inclusive_rounded,
                                    size: 13, color: AppColors.primaryVolt),
                                SizedBox(width: 5),
                                Text(
                                  'Continuous Form Loop',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: _togglePlayPause,
                              child: Row(
                                children: [
                                  Icon(
                                    _isGifPlaying
                                        ? Icons.pause_circle_outline_rounded
                                        : Icons.play_circle_outline_rounded,
                                    size: 13,
                                    color: AppColors.primaryCyan,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    _isGifPlaying ? 'Pause' : 'Resume',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.primaryCyan,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : (_controller != null && _controller!.value.isInitialized)
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                VideoProgressIndicator(
                                  _controller!,
                                  allowScrubbing: true,
                                  colors: const VideoProgressColors(
                                    playedColor: AppColors.primaryVolt,
                                    bufferedColor: Colors.white30,
                                    backgroundColor: Colors.white12,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 3),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_formatDuration(_controller!.value.position)} / ${_formatDuration(_controller!.value.duration)}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _controller!.seekTo(Duration.zero);
                                        _controller!.play();
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons.replay_rounded,
                                              size: 12,
                                              color: AppColors.primaryCyan),
                                          SizedBox(width: 3),
                                          Text(
                                            'Loop',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.primaryCyan,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
