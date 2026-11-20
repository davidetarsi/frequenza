import 'package:freezed_annotation/freezed_annotation.dart';

import '../../journey/domain/travel_leg.dart';
import '../../../l10n/locale_keys.g.dart';
import '../domain/radio_session.dart';
import '../domain/radio_station.dart';
import '../domain/track_title.dart';

part 'radio_display.freezed.dart';

/// The journey on the map: the flight hides the destination until landing.
enum FlightPhase { grounded, flying, signalLost }

/// A text on the radio: a translation key, or words that come with the
/// station.
@freezed
sealed class DisplayText with _$DisplayText {
  const factory DisplayText.translated(String key) = Translated;
  const factory DisplayText.verbatim(String text) = Verbatim;
  const factory DisplayText.country(String code, {String? fallback}) =
      CountryText;
}

/// What the radio shows for a session, without widgets: one exhaustive
/// switch, so a new state names every text it needs.
@freezed
class RadioDisplay with _$RadioDisplay {
  const RadioDisplay._();
  const factory RadioDisplay({
    required DisplayText title,
    required DisplayText country,
    required String statusKey,
    required String knobKey,
    required FlightPhase phase,
    RadioStation? station,
    TravelLeg? leg,
    TrackTitle? track,
    @Default(false) bool busy,
    @Default(false) bool flying,
    @Default(false) bool playing,
    @Default(true) bool knobEnabled,
    @Default(false) bool playKeyEnabled,
    @Default(false) bool playKeyOn,
    @Default(false) bool playKeyDown,
    @Default(false) bool saveEnabled,
    @Default(false) bool nextStopPending,
  }) = _RadioDisplay;

  factory RadioDisplay.of(RadioSession session) => switch (session) {
    Off() => const RadioDisplay(
      title: Translated(LocaleKeys.whereTo),
      country: Translated(LocaleKeys.worldAwaits),
      statusKey: LocaleKeys.ready,
      knobKey: LocaleKeys.powerOn,
      phase: FlightPhase.grounded,
    ),
    Flying(:final signalLost) => RadioDisplay(
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
      RadioDisplay(
        title: Verbatim(station.name),
        country: station.country.isEmpty && station.countryCode.isEmpty
            ? const Translated(LocaleKeys.unknownCountry)
            : CountryText(station.countryCode, fallback: station.country),
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
        track:
            trackTitle != null &&
                (playback == OnAirPlayback.playing ||
                    playback == OnAirPlayback.paused)
            ? TrackTitle.parse(trackTitle, stationName: station.name)
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
    Failed() => const RadioDisplay(
      title: Translated(LocaleKeys.signalLost),
      country: Translated(LocaleKeys.worldAwaits),
      statusKey: LocaleKeys.stationError,
      knobKey: LocaleKeys.retry,
      phase: FlightPhase.signalLost,
    ),
  };

  /// The song as the radio writes it.
  String? get song => track?.display;
}
