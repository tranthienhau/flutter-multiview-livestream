import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../models/stream_source.dart';
import '../models/stream_status.dart';

/// Immersive fullscreen player for a single stream.
class FullscreenPlayerScreen extends StatefulWidget {
  final StreamSource source;
  final VideoPlayerController? controller;
  final StreamStatus status;

  const FullscreenPlayerScreen({
    super.key,
    required this.source,
    this.controller,
    this.status = StreamStatus.idle,
  });

  @override
  State<FullscreenPlayerScreen> createState() => _FullscreenPlayerScreenState();
}

class _FullscreenPlayerScreenState extends State<FullscreenPlayerScreen> {
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 300) {
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            // Video
            if (widget.controller != null &&
                widget.controller!.value.isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: widget.controller!.value.aspectRatio,
                  child: VideoPlayer(widget.controller!),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            // Controls overlay
            if (_showControls) _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Column(
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: SafeArea(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 28,
                ),
              ),
            ),
          ),
          const Spacer(),
          // Bottom info bar
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  _buildStatusIndicator(),
                  const SizedBox(width: 8),
                  Text(
                    widget.source.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    switch (widget.status) {
      case StreamStatus.playing:
        return Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        );
      case StreamStatus.buffering:
      case StreamStatus.loading:
        return const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Colors.white,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
