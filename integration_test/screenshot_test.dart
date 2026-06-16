import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_multiview_livestream/main.dart';
import 'package:flutter_multiview_livestream/views/widgets/video_tile.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture multiview screens', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MultiViewStreamApp()));

    // Let the 4 HLS streams initialize and buffer over the network.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 8));

    await binding.convertFlutterSurfaceToImage();

    // 01 - 2x2 grid (default layout, all four streams live)
    await tester.pump(const Duration(milliseconds: 600));
    await binding.takeScreenshot('01-grid-2x2');

    // Tap a video tile -> promotes it to primary + thumbnails layout
    await tester.tap(find.byType(VideoTile).first);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    await binding.takeScreenshot('02-primary-thumbnails');

    // Switch to side-by-side via the layout toolbar
    await tester.tap(find.text('Side by Side'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    await binding.takeScreenshot('03-side-by-side');

    // Tap a tile in side-by-side -> immersive fullscreen player
    await tester.tap(find.byType(VideoTile).first);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    await binding.takeScreenshot('04-fullscreen');
  });
}
