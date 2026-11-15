import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/journey/domain/station_place.dart';
import 'package:frequenza/features/journey/domain/travel_leg.dart';
import 'package:frequenza/features/radio/domain/radio_session.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';

/// Reads of the session for the tests: the journey's parts, and the
/// station only while on air.
extension SessionReads on RadioSession {
  RadioStation? get station => switch (this) {
    OnAir(:final station) => station,
    _ => null,
  };
  int get trips => journey.trips;
  List<RadioStation> get previous => journey.previous;
  TravelLeg? get leg => journey.leg;
  List<TravelLeg> get history => journey.history;
  StationPlace get departure => journey.departure;
  bool get canGoBack => journey.canGoBack;
}

final isOff = isA<Off>();
final isFailed = isA<Failed>();

Matcher isFlying({bool? signalLost}) => signalLost == null
    ? isA<Flying>()
    : isA<Flying>().having((f) => f.signalLost, 'signalLost', signalLost);

Matcher isOnAir(OnAirPlayback playback) =>
    isA<OnAir>().having((s) => s.playback, 'playback', playback);
