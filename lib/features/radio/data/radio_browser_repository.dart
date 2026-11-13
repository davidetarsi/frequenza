import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../journey/domain/geo_point.dart';
import '../domain/radio_repository.dart';
import '../domain/radio_station.dart';

class RadioBrowserRepository implements RadioRepository {
  RadioBrowserRepository({
    http.Client? client,
    List<String>? mirrors,
    this.timeout = const Duration(seconds: 8),
    this.userAgent = 'Frequenza/0.1.0 (it.davidetarsi.frequenza)',
  }) : _client = client ?? http.Client(),
       _mirrors = mirrors ?? _defaultMirrors;

  static const List<String> _defaultMirrors = [
    'https://de1.api.radio-browser.info',
    'https://nl1.api.radio-browser.info',
    'https://at1.api.radio-browser.info',
  ];

  final http.Client _client;
  final List<String> _mirrors;
  final Duration timeout;
  final String userAgent;

  int _currentMirrorIndex = 0;

  @override
  Future<List<RadioStation>> getCandidates({
    String? countryCode,
    int limit = 20,
  }) async {
    final clampedLimit = limit.clamp(1, 50);
    final queryParams = <String, String>{
      'limit': clampedLimit.toString(),
      'hidebroken': 'true',
      'order': 'clickcount',
      'reverse': 'true',
    };

    if (countryCode != null && countryCode.trim().isNotEmpty) {
      queryParams['countrycode'] = countryCode.trim().toUpperCase();
    }

    final data = await _fetchJsonWithFallback(
      '/json/stations/search',
      queryParams,
    );
    if (data is! List) return const [];

    final stations = <RadioStation>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final station = _parseStation(raw);
      if (station != null) {
        stations.add(station);
      }
    }
    return stations;
  }

  @override
  Future<RadioStation?> getRandomStation({String? countryCode}) async {
    final queryParams = <String, String>{
      'limit': '30',
      'hidebroken': 'true',
      'order': 'random',
    };

    if (countryCode != null && countryCode.trim().isNotEmpty) {
      queryParams['countrycode'] = countryCode.trim().toUpperCase();
    }

    final data = await _fetchJsonWithFallback(
      '/json/stations/search',
      queryParams,
    );
    if (data is! List || data.isEmpty) return null;

    final candidates = <RadioStation>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final station = _parseStation(raw);
      if (station != null) {
        candidates.add(station);
      }
    }

    if (candidates.isEmpty) return null;
    final random = Random();
    return candidates[random.nextInt(candidates.length)];
  }

  RadioStation? _parseStation(Map<String, dynamic> json) {
    final id = json['stationuuid']?.toString() ?? '';
    final name = (json['name']?.toString() ?? '').trim();
    final urlResolved = (json['url_resolved']?.toString() ?? '').trim();
    final country = (json['country']?.toString() ?? 'Sconosciuto').trim();
    final countryCode = (json['countrycode']?.toString() ?? '')
        .trim()
        .toUpperCase();

    // Enforce strict HTTPS stream requirement
    if (id.isEmpty ||
        name.isEmpty ||
        !urlResolved.toLowerCase().startsWith('https://')) {
      return null;
    }

    final favicon = json['favicon']?.toString().trim();
    final faviconUrl =
        (favicon != null && favicon.toLowerCase().startsWith('https://'))
        ? favicon
        : null;

    final tagsString = json['tags']?.toString() ?? '';
    final tags = tagsString
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .take(5)
        .toList();

    final codec = json['codec']?.toString().trim();
    final bitrate = json['bitrate'] is num
        ? (json['bitrate'] as num).toInt()
        : null;

    final point = GeoPoint.tryFrom(json['geo_lat'], json['geo_long']);

    return RadioStation(
      id: id,
      name: name,
      streamUrl: urlResolved,
      country: country.isEmpty ? 'Mondo' : country,
      countryCode: countryCode,
      faviconUrl: faviconUrl,
      tags: tags,
      codec: (codec != null && codec.isNotEmpty) ? codec.toUpperCase() : null,
      bitrate: (bitrate != null && bitrate > 0) ? bitrate : null,
      latitude: point?.latitude,
      longitude: point?.longitude,
    );
  }

  Future<dynamic> _fetchJsonWithFallback(
    String path,
    Map<String, String> queryParams,
  ) async {
    Object? lastError;
    final totalMirrors = _mirrors.length;

    for (var attempt = 0; attempt < totalMirrors; attempt++) {
      final mirrorIndex = (_currentMirrorIndex + attempt) % totalMirrors;
      final baseUrl = _mirrors[mirrorIndex];
      final uri = Uri.parse(
        baseUrl,
      ).replace(path: path, queryParameters: queryParams);

      try {
        final response = await _client
            .get(
              uri,
              headers: {'User-Agent': userAgent, 'Accept': 'application/json'},
            )
            .timeout(timeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          _currentMirrorIndex = mirrorIndex; // remember working mirror
          return jsonDecode(response.body);
        } else {
          lastError = http.ClientException(
            'HTTP ${response.statusCode} from $baseUrl',
            uri,
          );
        }
      } catch (e) {
        lastError = e;
      }
    }

    throw lastError ?? Exception('All Radio Browser mirrors failed');
  }
}
