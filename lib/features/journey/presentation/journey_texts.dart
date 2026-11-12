import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_motion.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../radio/domain/radio_station.dart';
import '../domain/local_clock.dart';

/// "In volo verso…" with dots that keep searching.
class FlightDots extends StatefulWidget {
  const FlightDots({
    super.key,
    required this.label,
    required this.style,
    required this.maxLines,
  });

  final String label;
  final TextStyle style;
  final int maxLines;

  @override
  State<FlightDots> createState() => _FlightDotsState();
}

class _FlightDotsState extends State<FlightDots>
    with SingleTickerProviderStateMixin {
  late final _dots = AnimationController(
    vsync: this,
    duration: RouteMapDesign.dotsCycle,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.enabled(context)) {
      if (!_dots.isAnimating) _dots.repeat();
    } else {
      _dots
        ..stop()
        ..value = 1;
    }
  }

  @override
  void dispose() {
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${widget.label}…',
    child: ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _dots,
        builder: (context, _) {
          final shown = _dots.value >= 1 ? 3 : (_dots.value * 4).floor();
          return Text.rich(
            TextSpan(
              text: widget.label,
              children: [
                // Hidden dots keep the width steady while they appear.
                for (var i = 0; i < 3; i++)
                  TextSpan(
                    text: '.',
                    style: i < shown
                        ? null
                        : const TextStyle(color: Color(0x00000000)),
                  ),
              ],
            ),
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,
            style: widget.style,
          );
        },
      ),
    ),
  );
}

/// The station name coming into focus as the flight lands.
class LandingFocus extends StatelessWidget {
  const LandingFocus({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.enabled(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: motion ? RouteMapDesign.landingBlur : 0, end: 0),
      duration: motion ? RouteMapDesign.landing : Duration.zero,
      curve: Curves.easeOutCubic,
      builder: (context, sigma, child) => sigma <= 0
          ? child!
          : ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: child,
            ),
      child: child,
    );
  }
}

/// The station's local time, refreshed at each minute.
class LocalTimeText extends StatefulWidget {
  const LocalTimeText({super.key, required this.station, required this.style});

  final RadioStation station;
  final TextStyle style;

  @override
  State<LocalTimeText> createState() => _LocalTimeTextState();
}

class _LocalTimeTextState extends State<LocalTimeText> {
  Timer? _tick;

  void _schedule() {
    final now = DateTime.now();
    _tick = Timer(
      Duration(seconds: 60 - now.second, milliseconds: -now.millisecond),
      () => setState(_schedule),
    );
  }

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final time = localTimeOf(widget.station, DateTime.now().toUtc());
    if (time == null) return const SizedBox.shrink();
    return Text(
      LocaleKeys.localTime.tr(
        context: context,
        args: ['${time.approximate ? '≈ ' : ''}${time.hhmm}'],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.end,
      style: widget.style,
    );
  }
}
