import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_multiview_livestream/models/stream_layout.dart';

void main() {
  const testSize = Size(400, 600);

  group('Grid 2x2', () {
    test('four items produces 4 frames with positive dimensions', () {
      final frames = StreamLayout.grid2x2.frames(
        size: testSize,
        count: 4,
        primaryIndex: 0,
      );

      expect(frames.length, 4);
      for (final frame in frames) {
        expect(frame.width, greaterThan(0));
        expect(frame.height, greaterThan(0));
      }
    });

    test('tiles do not overlap', () {
      final frames = StreamLayout.grid2x2.frames(
        size: testSize,
        count: 4,
        primaryIndex: 0,
      );

      // Frame 0 is left of frame 1
      expect(frames[0].x + frames[0].width, lessThan(frames[1].x + 1));
      // Frame 0 is above frame 2
      expect(frames[0].y + frames[0].height, lessThan(frames[2].y + 1));
    });

    test('single item takes full size', () {
      final frames = StreamLayout.grid2x2.frames(
        size: testSize,
        count: 1,
        primaryIndex: 0,
      );

      expect(frames.length, 1);
      expect(frames[0].width, testSize.width);
      expect(frames[0].height, testSize.height);
    });

    test('two items are in same row', () {
      final frames = StreamLayout.grid2x2.frames(
        size: testSize,
        count: 2,
        primaryIndex: 0,
      );

      expect(frames.length, 2);
      expect(frames[0].y, frames[1].y);
    });
  });

  group('Primary with Thumbnails', () {
    test('four items produces 4 frames', () {
      final frames = StreamLayout.primaryWithThumbnails.frames(
        size: testSize,
        count: 4,
        primaryIndex: 0,
      );

      expect(frames.length, 4);
    });

    test('primary is larger than thumbnails', () {
      final frames = StreamLayout.primaryWithThumbnails.frames(
        size: testSize,
        count: 4,
        primaryIndex: 0,
      );

      final primaryArea = frames[0].width * frames[0].height;
      for (var i = 1; i < 4; i++) {
        final thumbArea = frames[i].width * frames[i].height;
        expect(primaryArea, greaterThan(thumbArea));
      }
    });

    test('primary spans full width', () {
      final frames = StreamLayout.primaryWithThumbnails.frames(
        size: testSize,
        count: 4,
        primaryIndex: 0,
      );

      expect(frames[0].width, testSize.width);
    });

    test('single item takes full size', () {
      final frames = StreamLayout.primaryWithThumbnails.frames(
        size: testSize,
        count: 1,
        primaryIndex: 0,
      );

      expect(frames.length, 1);
      expect(frames[0].width, testSize.width);
      expect(frames[0].height, testSize.height);
    });

    test('different primary index works', () {
      final frames = StreamLayout.primaryWithThumbnails.frames(
        size: testSize,
        count: 4,
        primaryIndex: 2,
      );

      expect(frames.length, 4);
      expect(frames[2].width, testSize.width);
      expect(frames[2].height, greaterThan(frames[0].height));
    });
  });

  group('Side by Side', () {
    test('two items have same full height', () {
      final frames = StreamLayout.sideBySide.frames(
        size: testSize,
        count: 2,
        primaryIndex: 0,
      );

      expect(frames.length, 2);
      expect(frames[0].height, testSize.height);
      expect(frames[1].height, testSize.height);
    });

    test('items are side by side', () {
      final frames = StreamLayout.sideBySide.frames(
        size: testSize,
        count: 2,
        primaryIndex: 0,
      );

      expect(frames[0].x + frames[0].width, lessThan(frames[1].x + 1));
    });

    test('extra streams are hidden (zero-sized)', () {
      final frames = StreamLayout.sideBySide.frames(
        size: testSize,
        count: 4,
        primaryIndex: 0,
      );

      expect(frames.length, 4);
      expect(frames[2].width, 0);
      expect(frames[2].height, 0);
      expect(frames[3].width, 0);
      expect(frames[3].height, 0);
    });
  });

  group('Edge Cases', () {
    test('empty count returns empty list', () {
      for (final layout in StreamLayout.values) {
        final frames = layout.frames(
          size: testSize,
          count: 0,
          primaryIndex: 0,
        );
        expect(frames, isEmpty);
      }
    });
  });
}
