import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_multiview_livestream/models/stream_source.dart';
import 'package:flutter_multiview_livestream/models/stream_status.dart';
import 'package:flutter_multiview_livestream/services/stream_player_manager.dart';
import 'package:flutter_multiview_livestream/services/stream_provider.dart';

/// Mock stream provider for testing.
class MockStreamProvider implements StreamProviding {
  final List<StreamSource> streams;
  const MockStreamProvider(this.streams);

  @override
  List<StreamSource> availableStreams() => streams;
}

void main() {
  late StreamPlayerManager manager;
  late MockStreamProvider mockProvider;

  setUp(() {
    manager = StreamPlayerManager();
    mockProvider = const MockStreamProvider([
      StreamSource(
          id: '1', title: 'Stream 1', url: 'https://example.com/1.m3u8'),
      StreamSource(
          id: '2', title: 'Stream 2', url: 'https://example.com/2.m3u8'),
      StreamSource(
          id: '3', title: 'Stream 3', url: 'https://example.com/3.m3u8'),
      StreamSource(
          id: '4', title: 'Stream 4', url: 'https://example.com/4.m3u8'),
    ]);
  });

  tearDown(() {
    manager.dispose();
  });

  group('StreamPlayerManager', () {
    test('loadStreams populates sources and statuses', () {
      manager.loadStreams(mockProvider);

      expect(manager.activeStreams.length, 4);
      expect(manager.statuses.length, 4);

      for (final source in manager.activeStreams) {
        expect(manager.statusFor(source.id), StreamStatus.idle);
      }
    });

    test('loadStreams limits to maxConcurrentStreams', () {
      final manyStreams = List.generate(
        10,
        (i) => StreamSource(
          id: 'stream-$i',
          title: 'Stream $i',
          url: 'https://example.com/$i.m3u8',
        ),
      );
      final bigProvider = MockStreamProvider(manyStreams);

      manager.loadStreams(bigProvider);

      expect(manager.activeStreams.length, maxConcurrentStreams);
    });

    test('primaryStreamId is first stream after load', () {
      manager.loadStreams(mockProvider);

      expect(manager.primaryStreamId, manager.activeStreams.first.id);
    });

    test('stopAll clears everything', () async {
      manager.loadStreams(mockProvider);

      await manager.stopAll();

      expect(manager.controllers, isEmpty);
      expect(manager.activeStreams, isEmpty);
      expect(manager.primaryStreamId, isNull);
    });

    test('controllerFor returns null for unknown id', () {
      manager.loadStreams(mockProvider);

      expect(manager.controllerFor('nonexistent'), isNull);
    });

    test('statusFor returns idle for unknown id', () {
      expect(manager.statusFor('nonexistent'), StreamStatus.idle);
    });

    test('promoteToPrimary updates primary id', () async {
      manager.loadStreams(mockProvider);

      await manager.promoteToPrimary('2');

      expect(manager.primaryStreamId, '2');
    });

    test('promoteToPrimary ignores unknown stream', () async {
      manager.loadStreams(mockProvider);
      final originalPrimary = manager.primaryStreamId;

      await manager.promoteToPrimary('nonexistent');

      expect(manager.primaryStreamId, originalPrimary);
    });
  });
}
