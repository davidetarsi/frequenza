import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../journey/domain/geo_point.dart';
import '../domain/country_draw.dart';
import '../domain/radio_repository.dart';
import '../domain/radio_station.dart';

class RadioBrowserRepository implements RadioRepository {
  RadioBrowserRepository({
    http.Client? client,
    List<String>? mirrors,
    this.timeout = const Duration(seconds: 8),
    this.userAgent = 'Frequenza/0.1.0 (it.davidetarsi.frequenza)',
    Random? random,
  }) : _client = client ?? http.Client(),
       _mirrors = mirrors ?? _defaultMirrors,
       _random = random ?? Random();

  /// `all` is the name Radio Browser keeps pointing at its live servers;
  /// `de1` is the one known server, in case that name does not resolve.
  static const List<String> _defaultMirrors = [
    'https://all.api.radio-browser.info',
    'https://de1.api.radio-browser.info',
  ];

  /// Countries tried in one turn of the dial before drawing from the whole
  /// world, and stations asked for in each draw.
  static const countryTries = 4;
  static const drawSize = 30;

  final http.Client _client;
  final List<String> _mirrors;
  final Duration timeout;
  final String userAgent;
  final Random _random;

  int _currentMirrorIndex = 0;

  /// Stations per country, loaded once; null until a load succeeds.
  Map<String, int>? _countries;

  /// Countries that answered with no usable station in this session.
  final _emptyCountries = <String>{};

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

  /// Draws a country first, weighted by [CountryDraw], then a station of
  /// that country that is not in [avoid]. [countries] limits the draw to the
  /// chosen ones; without it, after [countryTries] countries with nothing
  /// new, the draw falls back to the whole world. A station only avoided is
  /// kept as a last resort, so a turn of the dial never ends in silence
  /// just because everything was heard.
  @override
  Future<RadioStation?> getRandomStation({
    Set<String>? countries,
    Set<String> avoid = const {},
  }) async {
    final chosen = countries == null || countries.isEmpty ? null : countries;
    final known =
        await _loadCountries() ??
        (chosen == null ? null : {for (final code in chosen) code: 1});
    RadioStation? spare;
    if (known != null) {
      final tried = <String>{};
      for (var i = 0; i < countryTries; i++) {
        final code = CountryDraw.pick(
          known,
          among: chosen,
          skip: {..._emptyCountries, ...tried},
          random: _random,
        );
        if (code == null) break;
        tried.add(code);
        final usable = await _draw(countryCode: code);
        if (usable.isEmpty) _emptyCountries.add(code);
        final station = _choose(usable, avoid);
        if (station != null) return station;
        spare ??= usable.isEmpty ? null : usable.first;
      }
    }
    if (chosen == null) {
      final usable = await _draw();
      spare ??= usable.isEmpty ? null : usable.first;
      return _choose(usable, avoid) ?? spare;
    }
    return spare;
  }

  RadioStation? _choose(List<RadioStation> usable, Set<String> avoid) {
    final fresh = [
      for (final station in usable)
        if (!avoid.contains(station.id)) station,
    ];
    return fresh.isEmpty ? null : fresh[_random.nextInt(fresh.length)];
  }

  /// Random stations, of one country or of the whole world. The seed changes
  /// every time: the server keeps a random answer for about ten minutes, and
  /// the same request would land on the same few stations.
  Future<List<RadioStation>> _draw({String? countryCode}) async {
    final data = await _fetchJsonWithFallback('/json/stations/search', {
      'limit': '$drawSize',
      'hidebroken': 'true',
      'order': 'random',
      'seed': '${_random.nextInt(1 << 32)}',
      'countrycode': ?countryCode,
    });
    if (data is! List) return const [];
    return [
      for (final raw in data)
        if (raw is Map<String, dynamic>) ?_parseStation(raw),
    ];
  }

  /// The countries and how many stations each has. A failed load is not
  /// kept: the next turn of the dial tries again.
  Future<Map<String, int>?> _loadCountries() async {
    if (_countries case final countries?) return countries;
    try {
      final data = await _fetchJsonWithFallback('/json/countries', const {});
      if (data is! List) return null;
      final countries = <String, int>{
        for (final raw in data)
          if (raw case {
            'iso_3166_1': final String code,
            'stationcount': final num count,
          })
            code: count.toInt(),
      };
      return countries.isEmpty ? null : _countries = countries;
    } on Object {
      return null;
    }
  }

  RadioStation? _parseStation(Map<String, dynamic> json) {
    final id = json['stationuuid']?.toString() ?? '';
    final name = (json['name']?.toString() ?? '').trim();
    final urlResolved = (json['url_resolved']?.toString() ?? '').trim();
    final country = (json['country']?.toString() ?? '').trim();
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
      country: country,
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
