import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_motion.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../journey/domain/geo_point.dart';
import '../../journey/domain/station_place.dart';
import '../../journey/domain/travel_leg.dart';
import '../../journey/presentation/journey_texts.dart';
import '../../journey/presentation/route_map.dart';
import '../../radio/domain/radio_station.dart';
import '../../radio/presentation/radio_cabinet.dart';
import '../../radio/presentation/radio_display.dart';
import '../../radio/presentation/radio_keys.dart';

/// The radio on its own, as a picture: off, a turn of the dial, a flight
/// and a landing far away, then again. Silent, and still on the landing
/// when animations are off.
class WelcomeDemo extends StatefulWidget {
  const WelcomeDemo({super.key});

  static const loop = Duration(seconds: 6);

  /// Wide enough for the regular layout; the page scales it to fit.
  static const width = 340.0;

  @override
  State<WelcomeDemo> createState() => _WelcomeDemoState();
}

class _WelcomeDemoState extends State<WelcomeDemo>
    with SingleTickerProviderStateMixin {
  late final _clock = AnimationController(
    vsync: this,
    duration: WelcomeDemo.loop,
  );

  static const _station = RadioStation(
    id: 'welcome',
    name: 'Radio Paraíso',
    streamUrl: 'https://example.com',
    country: 'Brazil',
    countryCode: 'BR',
    tags: ['samba', 'mpb'],
    latitude: -22.91,
    longitude: -43.17,
  );
  static const _leg = TravelLeg(
    from: homePlace,
    to: StationPlace(
      point: GeoPoint(-22.91, -43.17),
      approximate: false,
      countryCode: 'BR',
    ),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!AppMotion.enabled(context)) {
      _clock
        ..stop()
        ..value = 1;
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _clock,
    builder: (context, _) {
      final t = _clock.value;
      if (t < 1 / 6) return _off(context);
      if (t < 1 / 2) {
        // One turn of the dial at the start of the flight.
        final turn = Curves.easeInOut.transform(((t - 1 / 6) * 6).clamp(0, 1));
        return _flying(context, turn);
      }
      return _landed(context);
    },
  );

  RadioCabinet _cabinet(
    BuildContext context, {
    required String country,
    String? countryDetail,
    required String station,
    String detail = '',
    required String status,
    required String knob,
    required FlightPhase phase,
    TravelLeg? leg,
    bool flying = false,
    bool playing = false,
    double turns = 0,
    Widget? localTime,
  }) => RadioCabinet(
    compact: false,
    horizontal: false,
    country: country,
    countryDetail: countryDetail,
    station: station,
    detail: detail,
    status: status,
    knobLabel: knob.toUpperCase(),
    tuneLabel: '',
    onTune: () {},
    isBusy: flying,
    isPlaying: playing,
    flying: flying,
    landings: leg == null ? 0 : 1,
    dialTurns: turns,
    tripLabel: leg == null
        ? null
        : LocaleKeys.tripNumber.tr(context: context, args: ['1']),
    localTime: localTime,
    map: RouteMap(
      flight: phase,
      playing: playing,
      departure: homePlace,
      leg: leg,
      history: const [],
      trips: leg == null ? 0 : 1,
    ),
    playKey: RadioKey(
      icon: playing ? Icons.pause : Icons.play_arrow,
      label: '',
      down: false,
      toggles: false,
      onPressed: leg == null ? null : () {},
    ),
    saveKey: RadioKey(
      icon: Icons.favorite_border,
      label: '',
      down: false,
      onPressed: leg == null ? null : () {},
    ),
  );

  Widget _off(BuildContext context) => _cabinet(
    context,
    country: LocaleKeys.worldAwaits.tr(context: context),
    station: LocaleKeys.whereTo.tr(context: context),
    detail: LocaleKeys.firstTrip.tr(context: context),
    status: LocaleKeys.ready.tr(context: context),
    knob: LocaleKeys.powerOn.tr(context: context),
    phase: FlightPhase.grounded,
  );

  Widget _flying(BuildContext context, double turns) => _cabinet(
    context,
    country: '',
    station: LocaleKeys.flyingTo.tr(context: context),
    status: LocaleKeys.searching.tr(context: context),
    knob: LocaleKeys.tuning.tr(context: context),
    phase: FlightPhase.flying,
    flying: true,
    turns: turns,
  );

  Widget _landed(BuildContext context) {
    final km = _leg.distance!.km;
    return _cabinet(
      context,
      country: _station.country,
      countryDetail: LocaleKeys.distanceKm.tr(
        context: context,
        args: [
          NumberFormat.decimalPattern(
            context.locale.toLanguageTag(),
          ).format(km),
        ],
      ),
      station: _station.name,
      detail: _station.tags.join(' · '),
      status: LocaleKeys.playing.tr(context: context),
      knob: LocaleKeys.tune.tr(context: context),
      phase: FlightPhase.grounded,
      leg: _leg,
      playing: true,
      localTime: LocalTimeText(
        station: _station,
        style: RadioCabinetDesign.statusText,
      ),
    );
  }
}
