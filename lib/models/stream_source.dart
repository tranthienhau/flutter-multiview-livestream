/// Represents a single HLS stream source with metadata.
class StreamSource {
  final String id;
  final String title;
  final String url;
  final String description;

  const StreamSource({
    required this.id,
    required this.title,
    required this.url,
    this.description = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamSource &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
