import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../journey/domain/geo_point.dart';
import '../domain/country_draw.dart';
import '../domain/radio_repository.dart';
import '../domain/radio_station.dart';
import '../domain/station_input.dart';
import '../../../app/network/domain/https_uri.dart';

class RadioBrowserRepository implements RadioRepository {
  RadioBrowserRepository({
    http.Client? client,
    List<String>? mirrors,
    this.timeout = const Duration(seconds: 8),
    this.userAgent = 'Frequenza (it.davidetarsi.frequenza)',
    Future<String>? resolvedUserAgent,
    this.maxResponseBytes = 1024 * 1024,
    Random? random,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null,
       _resolvedUserAgent = resolvedUserAgent?.catchError(
         (Object _) => userAgent,
       ),
       _mirrors = List.unmodifiable(mirrors ?? _defaultMirrors),
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
  final bool _ownsClient;
  final Future<String>? _resolvedUserAgent;
  final int maxResponseBytes;
  final _requests = <Completer<void>>{};
  bool _closed = false;

  /// Aborts outstanding work and closes an owned HTTP client. Injected clients
  /// remain the caller's responsibility, so a shared transport is not closed.
  void close() {
    if (_closed) return;
    _closed = true;
    for (final abort in _requests) {
      if (!abort.isCompleted) abort.complete();
    }
    if (_ownsClient) _client.close();
  }

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
      // Filtered by the server: an answer with no HTTPS stream means the
      // country has none, not that the sample was unlucky.
      'is_https': 'true',
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
            if (code.isNotEmpty &&
                code.length <= StationInput.countryCode &&
                count.isFinite &&
                count > 0)
              code: count.toInt(),
      };
      return countries.isEmpty ? null : _countries = countries;
    } on Object {
      return null;
    }
  }

  RadioStation? _parseStation(Map<String, dynamic> json) {
    final id = StationInput.text(json['stationuuid'], StationInput.id);
    final name = StationInput.text(json['name'], StationInput.name);
    final stream = json['url_resolved'];
    final uri = stream is String ? httpsUri(stream) : null;
    if (id == null || name == null || uri == null) return null;
    final country =
        StationInput.text(json['country'], StationInput.country) ?? '';
    final countryCode =
        (StationInput.text(json['countrycode'], StationInput.countryCode) ?? '')
            .toUpperCase();
    final favicon = json['favicon'];
    final faviconUrl = favicon is String ? httpsUri(favicon)?.toString() : null;
    final tagsString =
        StationInput.text(json['tags'], StationInput.tagsText) ?? '';
    final tags = tagsString
        .split(',')
        .map((t) => t.trim())
        .where((t) => StationInput.text(t, StationInput.tag) != null)
        .take(StationInput.tagsCount)
        .toList();
    final codec = StationInput.text(json['codec'], StationInput.codec);
    final rawBitrate = json['bitrate'];
    final bitrate = rawBitrate is num && rawBitrate.isFinite
        ? rawBitrate.toInt()
        : null;

    final point = GeoPoint.tryFrom(json['geo_lat'], json['geo_long']);
    final region = StationInput.text(json['state'], StationInput.region);

    return RadioStation(
      id: id,
      name: name,
      streamUrl: uri.toString(),
      country: country,
      countryCode: countryCode,
      region: (region == null || region.isEmpty) ? null : region,
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
      try {
        if (_closed) throw StateError('Radio Browser repository is closed');
        final base = httpsUri(baseUrl);
        if (base == null) {
          throw FormatException('Radio Browser mirror must use HTTPS');
        }
        final uri = base.replace(path: path, queryParameters: queryParams);
        final decoded = await _requestJson(uri);
        if (_closed) throw StateError('Radio Browser repository is closed');
        _currentMirrorIndex = mirrorIndex;
        return decoded;
      } catch (e) {
        if (_closed) rethrow;
        lastError = e;
      }
    }

    throw lastError ?? Exception('All Radio Browser mirrors failed');
  }

  Future<dynamic> _requestJson(Uri uri) async {
    if (httpsUri(uri.toString()) == null) {
      throw FormatException('Invalid HTTPS request');
    }
    final identity = await (_resolvedUserAgent ?? Future.value(userAgent))
        .timeout(timeout, onTimeout: () => userAgent)
        .catchError((Object _) => userAgent);
    if (_closed) throw StateError('Radio Browser repository is closed');
    final safeIdentity =
        identity.length <= 256 && !identity.contains(RegExp(r'[\r\n]'))
        ? identity
        : 'Frequenza (it.davidetarsi.frequenza)';
    final abort = Completer<void>();
    _requests.add(abort);
    final request =
        http.AbortableRequest('GET', uri, abortTrigger: abort.future)
          ..followRedirects = false
          ..headers.addAll({
            'User-Agent': safeIdentity,
            'Accept': 'application/json',
          });
    final timer = Timer(timeout, () {
      if (!abort.isCompleted) abort.complete();
    });
    try {
      return await _readJson(request).timeout(timeout);
    } finally {
      timer.cancel();
      if (!abort.isCompleted) abort.complete();
      _requests.remove(abort);
    }
  }

  Future<dynamic> _readJson(http.BaseRequest request) async {
    final response = await _client.send(request);
    if (_closed ||
        response.statusCode < 200 ||
        response.statusCode >= 300 ||
        (response.contentLength != null &&
            response.contentLength! > maxResponseBytes)) {
      await response.stream.listen(null).cancel();
      throw http.ClientException(
        'Invalid or oversized Radio Browser response',
        request.url,
      );
    }
    final bytes = BytesBuilder();
    await for (final chunk in response.stream) {
      if (_closed || bytes.length + chunk.length > maxResponseBytes) {
        throw http.ClientException(
          'Radio Browser response exceeds its limit',
          request.url,
        );
      }
      bytes.add(chunk);
    }
    return jsonDecode(utf8.decode(bytes.takeBytes()));
  }
}
