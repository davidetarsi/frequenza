import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../journey/domain/station_place.dart';
import '../../radio/domain/radio_station.dart';
import 'listen.dart';

part 'diary_summary.freezed.dart';

/// When a country counts as a stop: five minutes, or one per cent of all the
/// listening in a long period. To be tuned with real data.
abstract final class DiaryThreshold {
  static const minimumSeconds = 300;

  static int of(int totalSeconds) =>
      math.max(minimumSeconds, (totalSeconds / 100).round());
}

@freezed
class StationTime with _$StationTime {
  const factory StationTime({
    required RadioStation station,
    required int seconds,
  }) = _StationTime;
}

@freezed
class CountryTime with _$CountryTime {
  const factory CountryTime({
    required String code,

    /// Radio Browser's name, for countries the atlas does not know.
    required String name,
    required int seconds,

    /// Most heard first.
    required List<StationTime> stations,
    required DateTime lastListen,

    /// 0 when passing through; 1 to 4 by quartiles among the stops.
    required int level,
  }) = _CountryTime;
}

/// The diary of one period.
@freezed
sealed class DiarySummary with _$DiarySummary {
  const DiarySummary._();

  const factory DiarySummary.empty() = DiaryEmpty;

  const factory DiarySummary.filled({
    /// Most heard first; passing countries too, with level 0.
    required List<CountryTime> countries,
    required int totalSeconds,
    required int stationCount,
    required StationTime top,
    required int thresholdSeconds,
    required double? longestTripKm,
  }) = DiaryFilled;
}

extension DiaryFilledCountries on DiaryFilled {
  List<CountryTime> get stopped => [
    for (final country in countries)
      if (country.level > 0) country,
  ];

  /// The most heard country stopped in; null when there is none.
  CountryTime? get topStop => countries.where((c) => c.level > 0).firstOrNull;

  List<CountryTime> get passing => [
    for (final country in countries)
      if (country.level == 0) country,
  ];
}

/// What the sheet of a touched country shows.
@freezed
sealed class CountryCard with _$CountryCard {
  const factory CountryCard.stopped(CountryTime country) = StoppedCountry;

  const factory CountryCard.passing(
    CountryTime country, {
    required int thresholdSeconds,
  }) = PassingCountry;

  const factory CountryCard.unvisited(String code) = UnvisitedCountry;
}

/// The diary of [listens], whose stations are in [stations].
DiarySummary summarize(
  List<Listen> listens,
  Map<String, RadioStation> stations,
) {
  final heard = [
    for (final listen in listens)
      if (stations[listen.stationId] case final station?) (listen, station),
  ];
  if (heard.isEmpty) return const DiarySummary.empty();

  final total = heard.fold(0, (sum, item) => sum + item.$1.seconds);
  final threshold = DiaryThreshold.of(total);
  final byStation = <String, int>{};
  for (final (listen, _) in heard) {
    byStation.update(
      listen.stationId,
      (s) => s + listen.seconds,
      ifAbsent: () => listen.seconds,
    );
  }
  StationTime timeOf(String id) =>
      StationTime(station: stations[id]!, seconds: byStation[id]!);
  int mostHeard(StationTime a, StationTime b) => b.seconds != a.seconds
      ? b.seconds.compareTo(a.seconds)
      : a.station.name.compareTo(b.station.name);

  final byCountry = <String, List<(Listen, RadioStation)>>{};
  for (final item in heard) {
    final code = item.$2.countryCode;
    if (code.isEmpty) continue;
    byCountry.putIfAbsent(code, () => []).add(item);
  }
  final unranked = [
    for (final MapEntry(key: code, value: items) in byCountry.entries)
      (
        code: code,
        name: items
            .map((item) => item.$2.country)
            .firstWhere((name) => name.isNotEmpty, orElse: () => code),
        seconds: items.fold(0, (sum, item) => sum + item.$1.seconds),
        stations: ({
          for (final (l, _) in items) l.stationId,
        }.map(timeOf).toList()..sort(mostHeard)),
        last: items
            .map((item) => item.$1.startedAt)
            .reduce((a, b) => a.isAfter(b) ? a : b),
      ),
  ]..sort((a, b) => b.seconds.compareTo(a.seconds));
  final stops = unranked.where((c) => c.seconds >= threshold).length;

  final top = (byStation.keys.map(timeOf).toList()..sort(mostHeard)).first;
  return DiarySummary.filled(
    countries: [
      for (final (index, c) in unranked.indexed)
        CountryTime(
          code: c.code,
          name: c.name,
          seconds: c.seconds,
          stations: c.stations,
          lastListen: c.last,
          level: c.seconds >= threshold ? 4 - index * 4 ~/ stops : 0,
        ),
    ],
    totalSeconds: total,
    stationCount: byStation.length,
    top: top,
    thresholdSeconds: threshold,
    longestTripKm: _longestTrip(heard),
  );
}

/// The longest distance between two listens in a row of different stations.
double? _longestTrip(List<(Listen, RadioStation)> heard) {
  final ordered = [...heard]
    ..sort((a, b) => a.$1.startedAt.compareTo(b.$1.startedAt));
  double? longest;
  for (var i = 1; i < ordered.length; i++) {
    final (_, from) = ordered[i - 1];
    final (_, to) = ordered[i];
    if (from.id == to.id) continue;
    final a = placeOf(from), b = placeOf(to);
    if (a == null || b == null) continue;
    final km = a.point.distanceKm(b.point);
    if (longest == null || km > longest) longest = km;
  }
  return longest;
}

/// The case of the sheet for the country [code].
CountryCard cardFor(DiarySummary summary, String code) => switch (summary) {
  DiaryEmpty() => CountryCard.unvisited(code),
  DiaryFilled(:final countries, :final thresholdSeconds) => switch (countries
      .where((c) => c.code == code)
      .firstOrNull) {
    null => CountryCard.unvisited(code),
    final country when country.level > 0 => CountryCard.stopped(country),
    final country => CountryCard.passing(
      country,
      thresholdSeconds: thresholdSeconds,
    ),
  },
};
