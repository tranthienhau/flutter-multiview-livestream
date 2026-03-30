import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/stream_source.dart';
import '../models/stream_status.dart';
import '../models/stream_layout.dart';
import 'stream_provider.dart';

/// Maximum number of concurrent streams.
const int maxConcurrentStreams = 4;

/// Manages multiple VideoPlayerController instances for simultaneous playback.
class StreamPlayerManager extends ChangeNotifier {
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, StreamStatus> _statuses = {};
  List<StreamSource> _sources = [];
  String? _primaryStreamId;

  Map<String, VideoPlayerController> get controllers =>
      Map.unmodifiable(_controllers);
  Map<String, StreamStatus> get statuses => Map.unmodifiable(_statuses);
  List<StreamSource> get activeStreams => List.unmodifiable(_sources);
  String? get primaryStreamId => _primaryStreamId;

  VideoPlayerController? controllerFor(String id) => _controllers[id];
  StreamStatus statusFor(String id) => _statuses[id] ?? StreamStatus.idle;

  /// Load stream sources from a provider.
  void loadStreams(StreamProviding provider) {
    final streams = provider.availableStreams();
    _sources = streams.take(maxConcurrentStreams).toList();
    _primaryStreamId = _sources.isNotEmpty ? _sources.first.id : null;

    for (final source in _sources) {
      _statuses[source.id] = StreamStatus.idle;
    }
    notifyListeners();
  }

  /// Initialize and start a single stream.
  Future<void> startStream(StreamSource source) async {
    if (_controllers.containsKey(source.id)) return;

    _statuses[source.id] = StreamStatus.loading;
    notifyListeners();

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(source.url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controllers[source.id] = controller;

    controller.addListener(() {
      _onPlayerUpdate(source.id, controller);
    });

    try {
      await controller.initialize();
      await controller.setVolume(0);
      await controller.setLooping(true);
      await controller.play();
      _statuses[source.id] = StreamStatus.playing;
      notifyListeners();
    } catch (e) {
      _statuses[source.id] = StreamStatus.error;
      notifyListeners();
    }
  }

  /// Stop and dispose a single stream.
  Future<void> stopStream(String id) async {
    final controller = _controllers.remove(id);
    if (controller != null) {
      await controller.pause();
      await controller.dispose();
    }
    _statuses[id] = StreamStatus.idle;
    notifyListeners();
  }

  /// Stop all streams and clear state.
  Future<void> stopAll() async {
    for (final entry in _controllers.entries.toList()) {
      await entry.value.pause();
      await entry.value.dispose();
    }
    _controllers.clear();
    _statuses.clear();
    _sources.clear();
    _primaryStreamId = null;
    notifyListeners();
  }

  /// Start all loaded streams.
  Future<void> startAllStreams() async {
    final futures = <Future<void>>[];
    for (final source in _sources) {
      if (!_controllers.containsKey(source.id)) {
        futures.add(startStream(source));
      }
    }
    await Future.wait(futures);
    // Unmute primary only
    if (_primaryStreamId != null) {
      await unmuteOnly(_primaryStreamId!);
    }
  }

  /// Promote a stream to primary (adjusts audio).
  Future<void> promoteToPrimary(String id) async {
    if (!_sources.any((s) => s.id == id)) return;
    _primaryStreamId = id;
    await unmuteOnly(id);
    notifyListeners();
  }

  /// Unmute only the specified stream, mute all others.
  Future<void> unmuteOnly(String id) async {
    for (final entry in _controllers.entries) {
      if (entry.key == id) {
        await entry.value.setVolume(1.0);
      } else {
        await entry.value.setVolume(0.0);
      }
    }
  }

  void _onPlayerUpdate(String id, VideoPlayerController controller) {
    if (!_controllers.containsKey(id)) return;

    final value = controller.value;
    StreamStatus newStatus;

    if (value.hasError) {
      newStatus = StreamStatus.error;
    } else if (value.isBuffering) {
      newStatus = StreamStatus.buffering;
    } else if (value.isPlaying) {
      newStatus = StreamStatus.playing;
    } else if (value.isInitialized && !value.isPlaying) {
      newStatus = StreamStatus.paused;
    } else {
      newStatus = StreamStatus.loading;
    }

    if (_statuses[id] != newStatus) {
      _statuses[id] = newStatus;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }
}

/// Riverpod provider for the StreamPlayerManager.
final streamPlayerManagerProvider =
    ChangeNotifierProvider<StreamPlayerManager>((ref) {
  final manager = StreamPlayerManager();
  ref.onDispose(() => manager.dispose());
  return manager;
});

/// Riverpod provider for the current layout.
final currentLayoutProvider =
    StateProvider<StreamLayout>((ref) => StreamLayout.grid2x2);

/// Riverpod provider for the primary stream index.
final primaryStreamIndexProvider = StateProvider<int>((ref) => 0);

/// Riverpod provider for performance overlay visibility.
final showPerformanceOverlayProvider = StateProvider<bool>((ref) => false);
