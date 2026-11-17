import 'radio_station.dart';

abstract interface class RadioRepository {
  /// Fetches candidates for a given country code (or random if null).
  /// Only HTTPS streams are returned.
  Future<List<RadioStation>> getCandidates({
    String? countryCode,
    int limit = 20,
  });

  /// A random station, among the chosen [countries] when given (one country
  /// is a group of one), preferring stations not in [avoid] (station ids).
  Future<RadioStation?> getRandomStation({
    Set<String>? countries,
    Set<String> avoid = const {},
  });
}
