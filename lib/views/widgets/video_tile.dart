import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/stream_source.dart';
import '../../models/stream_status.dart';

/// A single video tile displaying a stream with overlay info.
class VideoTile extends StatelessWidget {
  final StreamSource source;
  final VideoPlayerController? controller;
  final StreamStatus status;
  final bool isPrimary;
  final VoidCallback? onTap;

  const VideoTile({
    super.key,
    required this.source,
    this.controller,
    this.status = StreamStatus.idle,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isPrimary ? 12 : 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: isPrimary ? 8 : 4,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Video layer
              _buildVideoLayer(),
              // Bottom overlay
              _buildOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoLayer() {
    if (controller != null && controller!.value.isInitialized) {
      return Positioned.fill(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller!.value.size.width,
            height: controller!.value.size.height,
            child: VideoPlayer(controller!),
          ),
        ),
      );
    }
    return const Positioned.fill(
      child: ColoredBox(color: Colors.black),
    );
  }

  Widget _buildOverlay() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black54],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            _buildStatusBadge(),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                source.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isPrimary ? 14 : 11,
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isPrimary)
              const Icon(
                Icons.volume_up,
                color: Colors.white,
                size: 14,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    switch (status) {
      case StreamStatus.playing:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 3,
                backgroundColor: Colors.red,
              ),
              SizedBox(width: 4),
              Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      case StreamStatus.loading:
      case StreamStatus.buffering:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Colors.white,
          ),
        );
      case StreamStatus.error:
        return const Icon(
          Icons.warning_amber,
          color: Colors.yellow,
          size: 14,
        );
      case StreamStatus.paused:
        return Icon(
          Icons.pause_circle_filled,
          color: Colors.white.withValues(alpha: 0.7),
          size: 14,
        );
      case StreamStatus.idle:
        return const SizedBox.shrink();
    }
  }
}
