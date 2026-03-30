import 'package:flutter/material.dart';

import '../../services/performance_monitor.dart';

/// Displays real-time FPS with color-coded indicator.
class PerformanceOverlayWidget extends StatelessWidget {
  final double fps;

  const PerformanceOverlayWidget({
    super.key,
    required this.fps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _fpsColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${fps.toInt()} FPS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color get _fpsColor {
    if (fps >= fpsGreenThreshold) return Colors.green;
    if (fps >= fpsYellowThreshold) return Colors.yellow;
    return Colors.red;
  }
}
