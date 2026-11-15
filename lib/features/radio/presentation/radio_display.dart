import '../../journey/domain/travel_leg.dart';
import '../../../l10n/locale_keys.g.dart';
import '../domain/radio_session.dart';
import '../domain/radio_station.dart';

/// The journey on the map: the flight hides the destination until landing.
enum FlightPhase { grounded, flying, signalLost }

/// A text on the radio: a translation key, or words that come with the
/// station.
sealed class DisplayText {
  const DisplayText();
}

final class Translated extends DisplayText {
  const Translated(this.key);
  final String key;

  @override
  bool operator ==(Object other) => other is Translated && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

final class Verbatim extends DisplayText {
  const Verbatim(this.text);
  final String text;

  @override
  bool operator ==(Object other) => other is Verbatim && other.text == text;

  @override
  int get hashCode => text.hashCode;
}

/// What the radio shows for a session, without widgets: one exhaustive
/// switch, so a new state names every text it needs.
class RadioDisplay {
  const RadioDisplay._({
    required this.title,
    required this.country,
    required this.statusKey,
    required this.knobKey,
    required this.phase,
    this.station,
    this.leg,
    this.song,
    this.busy = false,
    this.flying = false,
    this.playing = false,
    this.knobEnabled = true,
    this.playKeyEnabled = false,
    this.playKeyOn = false,
    this.playKeyDown = false,
    this.saveEnabled = false,
    this.nextStopPending = false,
  });

  factory RadioDisplay.of(RadioSession session) => switch (session) {
    Off() => const RadioDisplay._(
      title: Translated(LocaleKeys.whereTo),
      country: Translated(LocaleKeys.worldAwaits),
      statusKey: LocaleKeys.ready,
      knobKey: LocaleKeys.powerOn,
      phase: FlightPhase.grounded,
    ),
    Flying(:final signalLost) => RadioDisplay._(
      title: Translated(
        signalLost ? LocaleKeys.signalLost : LocaleKeys.flyingTo,
      ),
      country: const Verbatim(''),
      statusKey: LocaleKeys.searching,
      knobKey: LocaleKeys.tuning,
      phase: signalLost ? FlightPhase.signalLost : FlightPhase.flying,
      busy: true,
      flying: !signalLost,
      knobEnabled: false,
      nextStopPending: true,
    ),
    OnAir(:final journey, :final station, :final playback, :final trackTitle) =>
      RadioDisplay._(
        title: Verbatim(station.name),
        country: station.country.isEmpty
            ? const Translated(LocaleKeys.unknownCountry)
            : Verbatim(station.country),
        statusKey: switch (playback) {
          OnAirPlayback.playing => LocaleKeys.playing,
          OnAirPlayback.paused => LocaleKeys.paused,
          OnAirPlayback.buffering => LocaleKeys.connecting,
          OnAirPlayback.ended => LocaleKeys.ready,
          OnAirPlayback.broken => LocaleKeys.stationError,
        },
        knobKey: playback == OnAirPlayback.broken
            ? LocaleKeys.retry
            : LocaleKeys.tune,
        phase: FlightPhase.grounded,
        station: station,
        leg: journey.leg,
        song:
            playback == OnAirPlayback.playing ||
                playback == OnAirPlayback.paused
            ? trackTitle
            : null,
        busy: playback == OnAirPlayback.buffering,
        playing: playback == OnAirPlayback.playing,
        playKeyEnabled: playback != OnAirPlayback.broken,
        playKeyOn:
            playback == OnAirPlayback.playing ||
            playback == OnAirPlayback.buffering,
        playKeyDown: playback == OnAirPlayback.paused,
        saveEnabled: true,
      ),
    Failed() => const RadioDisplay._(
      title: Translated(LocaleKeys.signalLost),
      country: Translated(LocaleKeys.worldAwaits),
      statusKey: LocaleKeys.stationError,
      knobKey: LocaleKeys.retry,
      phase: FlightPhase.signalLost,
    ),
  };

  final DisplayText title, country;
  final String statusKey, knobKey;
  final FlightPhase phase;

  /// The station on air, and the leg that brought it.
  final RadioStation? station;
  final TravelLeg? leg;

  /// The track title, while the station plays or rests.
  final String? song;

  /// A flight, or a station refilling its stream: no song, no local time.
  final bool busy;

  /// Flying with the signal: the destination is hidden.
  final bool flying;
  final bool playing;
  final bool knobEnabled, playKeyEnabled, playKeyOn, playKeyDown;
  final bool saveEnabled;
  final bool nextStopPending;
}
