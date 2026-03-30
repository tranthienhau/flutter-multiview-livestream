import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FPS thresholds for color coding.
const double fpsGreenThreshold = 55.0;
const double fpsYellowThreshold = 30.0;

/// Tracks frames-per-second using the Scheduler ticker.
class PerformanceMonitor extends ChangeNotifier {
  double _fps = 0;
  int _frameCount = 0;
  Duration _lastTimestamp = Duration.zero;
  Ticker? _ticker;

  double get fps => _fps;

  void start() {
    stop();
    _frameCount = 0;
    _lastTimestamp = Duration.zero;
    _ticker = Ticker(_onTick);
    _ticker!.start();
  }

  void stop() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
  }

  void _onTick(Duration elapsed) {
    if (_lastTimestamp == Duration.zero) {
      _lastTimestamp = elapsed;
      return;
    }

    _frameCount++;
    final diff = elapsed - _lastTimestamp;

    if (diff.inMilliseconds >= 1000) {
      _fps = _frameCount / (diff.inMilliseconds / 1000.0);
      _frameCount = 0;
      _lastTimestamp = elapsed;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

/// Riverpod provider for the PerformanceMonitor.
final performanceMonitorProvider =
    ChangeNotifierProvider<PerformanceMonitor>((ref) {
  final monitor = PerformanceMonitor();
  ref.onDispose(() => monitor.dispose());
  return monitor;
});
