import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/stream_layout.dart';
import '../../models/stream_source.dart';
import '../../models/stream_status.dart';
import 'video_tile.dart';

/// Displays multiple streams in a configurable layout with animated transitions.
class MultiStreamGrid extends StatelessWidget {
  final List<StreamSource> sources;
  final Map<String, VideoPlayerController> controllers;
  final Map<String, StreamStatus> statuses;
  final StreamLayout layout;
  final int primaryIndex;
  final void Function(int index) onTileTap;

  const MultiStreamGrid({
    super.key,
    required this.sources,
    required this.controllers,
    required this.statuses,
    required this.layout,
    required this.primaryIndex,
    required this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final frames = layout.frames(
          size: size,
          count: sources.length,
          primaryIndex: primaryIndex,
        );

        return Stack(
          children: [
            for (var i = 0; i < sources.length; i++)
              if (i < frames.length &&
                  frames[i].width > 0 &&
                  frames[i].height > 0)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  left: frames[i].x,
                  top: frames[i].y,
                  width: frames[i].width,
                  height: frames[i].height,
                  child: VideoTile(
                    source: sources[i],
                    controller: controllers[sources[i].id],
                    status: statuses[sources[i].id] ?? StreamStatus.idle,
                    isPrimary:
                        i == primaryIndex &&
                        layout == StreamLayout.primaryWithThumbnails,
                    onTap: () => onTileTap(i),
                  ),
                ),
          ],
        );
      },
    );
  }
}
