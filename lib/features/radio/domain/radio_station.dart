class RadioStation {
  const RadioStation({
    required this.id,
    required this.name,
    required this.streamUrl,
    required this.country,
    required this.countryCode,
    this.faviconUrl,
    this.tags = const [],
    this.codec,
    this.bitrate,
  });

  final String id;
  final String name;
  final String streamUrl;
  final String country;
  final String countryCode;
  final String? faviconUrl;
  final List<String> tags;
  final String? codec;
  final int? bitrate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RadioStation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RadioStation($name, $countryCode, $streamUrl)';
}
