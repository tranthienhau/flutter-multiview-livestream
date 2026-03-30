import 'dart:ui';

/// Layout modes for the multi-stream grid.
enum StreamLayout {
  grid2x2,
  primaryWithThumbnails,
  sideBySide;

  String get displayName {
    switch (this) {
      case StreamLayout.grid2x2:
        return '2x2 Grid';
      case StreamLayout.primaryWithThumbnails:
        return 'Primary + Thumbnails';
      case StreamLayout.sideBySide:
        return 'Side by Side';
    }
  }

  /// Material icon data value for this layout.
  String get iconName {
    switch (this) {
      case StreamLayout.grid2x2:
        return 'grid_view';
      case StreamLayout.primaryWithThumbnails:
        return 'view_agenda';
      case StreamLayout.sideBySide:
        return 'view_column';
    }
  }

  /// Compute positioned frames for each tile given the container [size],
  /// the number of tiles [count], and which tile is [primaryIndex].
  List<TileFrame> frames({
    required Size size,
    required int count,
    required int primaryIndex,
  }) {
    if (count <= 0) return [];
    const spacing = 4.0;

    switch (this) {
      case StreamLayout.grid2x2:
        return _grid2x2Frames(size, count, spacing);
      case StreamLayout.primaryWithThumbnails:
        return _primaryWithThumbnailsFrames(size, count, primaryIndex, spacing);
      case StreamLayout.sideBySide:
        return _sideBySideFrames(size, count, spacing);
    }
  }

  List<TileFrame> _grid2x2Frames(Size size, int count, double spacing) {
    final cols = count <= 1 ? 1 : 2;
    final rows = count <= 2 ? 1 : 2;
    final tileW = (size.width - spacing * (cols - 1)) / cols;
    final tileH = (size.height - spacing * (rows - 1)) / rows;

    final frames = <TileFrame>[];
    for (var i = 0; i < count; i++) {
      final col = i % 2;
      final row = i ~/ 2;
      frames.add(TileFrame(
        x: col * (tileW + spacing),
        y: row * (tileH + spacing),
        width: tileW,
        height: tileH,
      ));
    }
    return frames;
  }

  List<TileFrame> _primaryWithThumbnailsFrames(
    Size size,
    int count,
    int primaryIndex,
    double spacing,
  ) {
    if (count <= 1) {
      return [TileFrame(x: 0, y: 0, width: size.width, height: size.height)];
    }

    final thumbnailCount = count - 1;
    final thumbnailHeight = (size.height - spacing) * 0.25;
    final primaryHeight = size.height - thumbnailHeight - spacing;
    final thumbnailWidth =
        (size.width - spacing * (thumbnailCount - 1)) / thumbnailCount;

    final frames = List<TileFrame>.filled(
      count,
      const TileFrame(x: 0, y: 0, width: 0, height: 0),
    );

    frames[primaryIndex] = TileFrame(
      x: 0,
      y: 0,
      width: size.width,
      height: primaryHeight,
    );

    var thumbIdx = 0;
    for (var i = 0; i < count; i++) {
      if (i != primaryIndex) {
        frames[i] = TileFrame(
          x: thumbIdx * (thumbnailWidth + spacing),
          y: primaryHeight + spacing,
          width: thumbnailWidth,
          height: thumbnailHeight,
        );
        thumbIdx++;
      }
    }
    return frames;
  }

  List<TileFrame> _sideBySideFrames(Size size, int count, double spacing) {
    final effectiveCount = count < 2 ? count : 2;
    final tileW = (size.width - spacing * (effectiveCount - 1)) / effectiveCount;

    final frames = <TileFrame>[];
    for (var i = 0; i < count; i++) {
      if (i < 2) {
        frames.add(TileFrame(
          x: i * (tileW + spacing),
          y: 0,
          width: tileW,
          height: size.height,
        ));
      } else {
        // Extra streams hidden in side-by-side
        frames.add(const TileFrame(x: 0, y: 0, width: 0, height: 0));
      }
    }
    return frames;
  }
}

/// Describes the position and size of a single tile in the layout.
class TileFrame {
  final double x;
  final double y;
  final double width;
  final double height;

  const TileFrame({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileFrame &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => Object.hash(x, y, width, height);

  @override
  String toString() =>
      'TileFrame(x: $x, y: $y, width: $width, height: $height)';
}
