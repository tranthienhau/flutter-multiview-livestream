# Multi-View Live Stream Viewer (Flutter)

A cross-platform Flutter POC demonstrating multi-stream live video playback, inspired by platforms like Klic.gg. Built with Flutter + video_player + Riverpod.

## Features

- **Multi-stream playback** - 4 simultaneous HLS streams in a 2x2 grid
- **Dynamic layouts** - Grid (2x2), Primary + Thumbnails, Side-by-Side
- **Animated transitions** - Smooth layout changes with AnimatedPositioned
- **Tap-to-promote** - Tap any tile to make it the primary stream
- **Fullscreen mode** - Tap primary stream for immersive single-stream viewing
- **Layout toolbar** - Icon-based switcher for quick layout changes
- **LIVE badge** - Red capsule badge on playing streams
- **Performance monitoring** - Real-time FPS overlay, toggleable from menu
- **Dark theme** - Full dark UI matching the Klic.gg aesthetic
- **Swipe to dismiss** - Swipe down in fullscreen to return

## Architecture

```
MVVM + Riverpod State Management

lib/
  main.dart                  App entry point with ProviderScope

  models/
    stream_source.dart       Stream metadata (id, title, url, description)
    stream_layout.dart       Layout enum with geometry calculations
    stream_status.dart       Player status enum (idle, loading, playing, etc.)

  services/
    stream_provider.dart     StreamProviding interface + HLS test stream URLs
    stream_player_manager.dart  Manages multiple VideoPlayerController instances
    performance_monitor.dart FPS tracking via Ticker

  views/
    home_screen.dart         Main screen with grid + controls
    fullscreen_player_screen.dart  Immersive single-stream viewer
    widgets/
      video_tile.dart        Video tile with overlay (title, status badge)
      multi_stream_grid.dart AnimatedPositioned multi-layout grid
      layout_toolbar.dart    Layout selector toolbar
      performance_overlay.dart  Color-coded FPS display
```

## Requirements

- Flutter 3.x
- Dart 3.x
- iOS 12+ / Android API 21+

## Build & Run

```bash
# Get dependencies
cd poc_next/flutter_multiview_livestream
flutter pub get

# Run on connected device or simulator
flutter run

# Run on iOS simulator
flutter run -d iPhone

# Run on Android emulator
flutter run -d android
```

## Test Streams

Uses free public Apple HLS test streams:

| Stream | Format |
|--------|--------|
| Main Stage | Advanced fMP4 |
| Backstage Cam | H.265/HEVC |
| Fan Cam | Dolby Vision + Atmos |
| Interview Room | Basic 16:9 H.264 |

## Run Tests

```bash
flutter test
```

## Key Dependencies

- `video_player` - HLS video playback (native AVPlayer on iOS, ExoPlayer on Android)
- `flutter_riverpod` - State management with provider pattern
