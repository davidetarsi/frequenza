import 'radio_station.dart';

abstract interface class RadioRepository {
  /// Fetches candidates for a given country code (or random if null).
  /// Only HTTPS streams are returned.
  Future<List<RadioStation>> getCandidates({
    String? countryCode,
    int limit = 20,
  });

  /// Fetches a single random station from candidates.
  Future<RadioStation?> getRandomStation({String? countryCode});
}
