import '../models/stream_source.dart';

/// Provides the list of available HLS stream sources.
abstract class StreamProviding {
  List<StreamSource> availableStreams();
}

/// Apple HLS test stream provider with 4 public demo streams.
class HLSStreamProvider implements StreamProviding {
  @override
  List<StreamSource> availableStreams() {
    return const [
      StreamSource(
        id: 'main-stage',
        title: 'Main Stage',
        url:
            'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
        description: 'Primary concert view',
      ),
      StreamSource(
        id: 'backstage-cam',
        title: 'Backstage Cam',
        url:
            'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8',
        description: 'Behind the scenes',
      ),
      StreamSource(
        id: 'fan-cam',
        title: 'Fan Cam',
        url:
            'https://devstreaming-cdn.apple.com/videos/streaming/examples/adv_dv_atmos/main.m3u8',
        description: 'Crowd perspective',
      ),
      StreamSource(
        id: 'interview-room',
        title: 'Interview Room',
        url:
            'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8',
        description: 'Artist interviews',
      ),
    ];
  }
}
