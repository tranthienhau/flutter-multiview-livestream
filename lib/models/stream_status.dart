/// Represents the playback status of a single stream.
enum StreamStatus {
  idle,
  loading,
  buffering,
  playing,
  paused,
  error;

  String get displayText {
    switch (this) {
      case StreamStatus.idle:
        return 'Idle';
      case StreamStatus.loading:
        return 'Loading...';
      case StreamStatus.buffering:
        return 'Buffering...';
      case StreamStatus.playing:
        return 'Live';
      case StreamStatus.paused:
        return 'Paused';
      case StreamStatus.error:
        return 'Error';
    }
  }

  bool get isActive {
    switch (this) {
      case StreamStatus.playing:
      case StreamStatus.buffering:
        return true;
      default:
        return false;
    }
  }
}
