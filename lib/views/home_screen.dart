import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stream_layout.dart';
import '../services/performance_monitor.dart';
import '../services/stream_player_manager.dart';
import '../services/stream_provider.dart';
import 'fullscreen_player_screen.dart';
import 'widgets/layout_toolbar.dart';
import 'widgets/multi_stream_grid.dart';
import 'widgets/performance_overlay.dart';

/// Main home screen displaying the multi-stream grid with controls.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _provider = HLSStreamProvider();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initStreams();
    });
  }

  Future<void> _initStreams() async {
    if (_initialized) return;
    _initialized = true;
    final manager = ref.read(streamPlayerManagerProvider);
    manager.loadStreams(_provider);
    await manager.startAllStreams();
  }

  @override
  void dispose() {
    final manager = ref.read(streamPlayerManagerProvider);
    manager.stopAll();
    final perfMonitor = ref.read(performanceMonitorProvider);
    perfMonitor.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = ref.watch(streamPlayerManagerProvider);
    final currentLayout = ref.watch(currentLayoutProvider);
    final primaryIndex = ref.watch(primaryStreamIndexProvider);
    final showPerf = ref.watch(showPerformanceOverlayProvider);
    final perfMonitor = ref.watch(performanceMonitorProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Column(
          children: [
            Text(
              'MultiView Stream',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Klic.gg Style Multi-Cam',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            color: Colors.grey[900],
            onSelected: (value) {
              if (value == 'toggle_perf') {
                final current = ref.read(showPerformanceOverlayProvider);
                ref.read(showPerformanceOverlayProvider.notifier).state =
                    !current;
                if (!current) {
                  perfMonitor.start();
                } else {
                  perfMonitor.stop();
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_perf',
                child: Row(
                  children: [
                    const Icon(Icons.speed, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      showPerf ? 'Hide Stats' : 'Show Stats',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Layout toolbar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: LayoutToolbar(
                  currentLayout: currentLayout,
                  onLayoutChanged: (layout) {
                    ref.read(currentLayoutProvider.notifier).state = layout;
                  },
                ),
              ),
              // Stream grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: MultiStreamGrid(
                    sources: manager.activeStreams,
                    controllers: manager.controllers,
                    statuses: manager.statuses,
                    layout: currentLayout,
                    primaryIndex: primaryIndex,
                    onTileTap: (index) => _handleTileTap(index),
                  ),
                ),
              ),
            ],
          ),
          // Performance overlay
          if (showPerf)
            Positioned(
              top: 4,
              right: 12,
              child: PerformanceOverlayWidget(fps: perfMonitor.fps),
            ),
        ],
      ),
    );
  }

  void _handleTileTap(int index) {
    final manager = ref.read(streamPlayerManagerProvider);
    final currentLayout = ref.read(currentLayoutProvider);
    final primaryIndex = ref.read(primaryStreamIndexProvider);
    final streams = manager.activeStreams;

    if (index >= streams.length) return;

    switch (currentLayout) {
      case StreamLayout.grid2x2:
        // Tap promotes to primary + thumbnails
        ref.read(primaryStreamIndexProvider.notifier).state = index;
        ref.read(currentLayoutProvider.notifier).state =
            StreamLayout.primaryWithThumbnails;
        manager.promoteToPrimary(streams[index].id);
        break;

      case StreamLayout.primaryWithThumbnails:
        if (index == primaryIndex) {
          // Tap on primary goes fullscreen
          _openFullscreen(index);
        } else {
          // Tap on thumbnail promotes it
          ref.read(primaryStreamIndexProvider.notifier).state = index;
          manager.promoteToPrimary(streams[index].id);
        }
        break;

      case StreamLayout.sideBySide:
        // Tap to go fullscreen
        _openFullscreen(index);
        break;
    }
  }

  void _openFullscreen(int index) {
    final manager = ref.read(streamPlayerManagerProvider);
    final streams = manager.activeStreams;
    if (index >= streams.length) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenPlayerScreen(
          source: streams[index],
          controller: manager.controllerFor(streams[index].id),
          status: manager.statusFor(streams[index].id),
        ),
      ),
    );
  }
}
