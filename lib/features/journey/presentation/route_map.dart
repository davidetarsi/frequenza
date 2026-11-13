import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../ui/theme/app_motion.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../radio/domain/radio_player_state.dart';
import '../data/world_atlas.g.dart';
import '../domain/geo_point.dart';
import '../domain/station_place.dart';
import '../domain/travel_leg.dart';

/// The dotted world on the radio display: a search pulse while flying, then
/// the arc of the leg once the station plays. Decorative: the same facts are
/// in the display texts.
class RouteMap extends StatefulWidget {
  const RouteMap({
    super.key,
    required this.flight,
    required this.playing,
    required this.departure,
    this.leg,
    required this.history,
    required this.trips,
  });

  final FlightPhase flight;
  final bool playing;
  final StationPlace departure;
  final TravelLeg? leg;
  final List<TravelLeg> history;
  final int trips;

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> with TickerProviderStateMixin {
  late final _landing = AnimationController(
    vsync: this,
    duration: RouteMapDesign.landing,
    value: 1,
  );
  late final _pulse = AnimationController(vsync: this);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMotion();
  }

  @override
  void didUpdateWidget(RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trips > oldWidget.trips && AppMotion.enabled(context)) {
      _landing.forward(from: 0);
    }
    _updateMotion();
  }

  void _updateMotion() {
    final motion = AppMotion.enabled(context);
    if (!motion) _landing.value = 1;
    final cycle = switch (widget.flight) {
      FlightPhase.flying => RouteMapDesign.radarCycle,
      FlightPhase.grounded when widget.playing && widget.leg?.to != null =>
        RouteMapDesign.arrivalCycle,
      _ => null,
    };
    if (motion && cycle != null) {
      if (_pulse.duration != cycle || !_pulse.isAnimating) {
        _pulse
          ..duration = cycle
          ..repeat();
      }
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _landing.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: CustomPaint(
        key: const ValueKey('route-map'),
        size: Size.infinite,
        painter: _RouteMapPainter(
          flight: widget.flight,
          playing: widget.playing,
          departure: widget.departure,
          leg: widget.leg,
          history: widget.history,
          trips: widget.trips,
          landing: CurvedAnimation(
            parent: _landing,
            curve: Curves.easeOutCubic,
          ),
          pulse: _pulse,
        ),
      ),
    ),
  );
}

class _RouteMapPainter extends CustomPainter {
  _RouteMapPainter({
    required this.flight,
    required this.playing,
    required this.departure,
    required this.leg,
    required this.history,
    required this.trips,
    required this.landing,
    required this.pulse,
  }) : super(repaint: Listenable.merge([landing, pulse]));

  final FlightPhase flight;
  final bool playing;
  final StationPlace departure;
  final TravelLeg? leg;
  final List<TravelLeg> history;
  final int trips;
  final Animation<double> landing, pulse;

  static const _ink = TravelRadioPalette.screenInk;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    const span = RouteMapDesign.north - RouteMapDesign.south;
    final scale = math.min(size.width / 360, size.height / span);
    final origin = Offset(
      (size.width - 360 * scale) / 2,
      (size.height - span * scale) / 2,
    );
    Offset project(GeoPoint p) =>
        origin +
        Offset(
          (p.longitude + 180) * scale,
          (RouteMapDesign.north -
                  p.latitude.clamp(
                    RouteMapDesign.south,
                    RouteMapDesign.north,
                  )) *
              scale,
        );

    _paintDots(canvas, origin, scale);
    for (final past in history) {
      if (identical(past, leg) || past.to == null) continue;
      _paintHistory(canvas, project(past.from.point), project(past.to!.point));
    }

    final point = Paint()..color = _ink;
    switch (flight) {
      case FlightPhase.flying:
        final centre = project(departure.point);
        canvas.drawCircle(centre, RouteMapDesign.pointRadius, point);
        for (var i = 0; i < RouteMapDesign.radarRings; i++) {
          final t = (pulse.value + i / RouteMapDesign.radarRings) % 1;
          canvas.drawCircle(
            centre,
            RouteMapDesign.pointRadius + t * RouteMapDesign.radarRadius,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = RouteMapDesign.radarStroke
              ..color = _ink.withValues(alpha: (1 - t) * .6),
          );
        }
      case FlightPhase.signalLost:
        canvas.drawCircle(
          project(departure.point),
          RouteMapDesign.pointRadius,
          point,
        );
      case FlightPhase.grounded:
        final leg = this.leg;
        if (trips == 0 || leg == null) return;
        final from = project(leg.from.point);
        canvas.drawCircle(from, RouteMapDesign.pointRadius * .7, point);
        final to = leg.to;
        if (to == null) return;
        final end = project(to.point);
        final arc = _arc(from, end);
        for (final metric in arc.computeMetrics()) {
          canvas.drawPath(
            metric.extractPath(0, metric.length * landing.value),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = RouteMapDesign.arcStroke
              ..strokeCap = StrokeCap.round
              ..color = _ink.withValues(alpha: RouteMapDesign.arcOpacity),
          );
        }
        if (landing.value < 1) return;
        canvas.drawCircle(end, RouteMapDesign.pointRadius, point);
        if (playing && pulse.value > 0) {
          canvas.drawCircle(
            end,
            RouteMapDesign.pointRadius +
                pulse.value * RouteMapDesign.arrivalPulseRadius,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = RouteMapDesign.radarStroke
              ..color = _ink.withValues(alpha: (1 - pulse.value) * .7),
          );
        }
    }
  }

  void _paintDots(Canvas canvas, Offset origin, double scale) {
    final cell = worldDotStep * scale;
    final paint = Paint()
      ..color = _ink.withValues(alpha: RouteMapDesign.dotOpacity);
    for (var row = 0; row < worldDotRows.length; row++) {
      final cells = worldDotRows[row];
      for (var col = 0; col < cells.length; col++) {
        if (cells.codeUnitAt(col) != 0x31) continue;
        canvas.drawCircle(
          origin + Offset((col + .5) * cell, (row + .5) * cell),
          RouteMapDesign.dotRadius,
          paint,
        );
      }
    }
  }

  void _paintHistory(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = RouteMapDesign.historyStroke
      ..color = _ink.withValues(alpha: RouteMapDesign.historyOpacity);
    for (final metric in _arc(from, to).computeMetrics()) {
      for (
        var d = 0.0;
        d < metric.length;
        d += RouteMapDesign.historyDash * 2
      ) {
        canvas.drawPath(
          metric.extractPath(d, d + RouteMapDesign.historyDash),
          paint,
        );
      }
    }
  }

  /// A curve bowing north, inside the map: it never wraps around the edge.
  static Path _arc(Offset from, Offset to) {
    final lift = (to - from).distance * RouteMapDesign.arcLift;
    final control = Offset(
      (from.dx + to.dx) / 2,
      math.min(from.dy, to.dy) - lift,
    );
    return Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(control.dx, control.dy, to.dx, to.dy);
  }

  @override
  bool shouldRepaint(_RouteMapPainter old) =>
      flight != old.flight ||
      playing != old.playing ||
      departure != old.departure ||
      leg != old.leg ||
      history != old.history ||
      trips != old.trips;
}
