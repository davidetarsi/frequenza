/// Technical bounds on untrusted catalogue/record metadata, not UI sizes.
abstract final class StationInput {
  static const id = 128;
  static const name = 512;
  static const country = 256;
  static const countryCode = 8;
  static const region = 256;
  static const codec = 64;
  static const tag = 64;
  static const tagsText = 4096;
  static const trackTitle = 4096;
  static const tagsCount = 5;

  static String? text(Object? value, int limit) {
    if (value is! String || value.length > limit) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
