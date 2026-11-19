import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../ui/theme/app_motion.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../radio/presentation/radio_display.dart';
import '../data/world_atlas.g.dart';
import '../domain/geo_point.dart';
import '../domain/station_place.dart';
import '../domain/travel_leg.dart';
import 'country_shape.dart';

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
    this.reconnecting = false,
  });

  final FlightPhase flight;
  final bool playing;
  final StationPlace departure;
  final TravelLeg? leg;
  final List<TravelLeg> history;
  final int trips;
  final bool reconnecting;

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

  late final _camera = AnimationController(vsync: this, value: 1);
  Rect _from = _worldView, _to = _worldView;
  CountryShape? _country, _previousCountry;
  double _outlineStart = 0, _previousOpacity = 0;
  bool _arriving = false, _initialized = false;

  double get _outline => _country == null
      ? 0
      : _arriving
      ? _outlineStart + (1 - _outlineStart) * _reveal(_camera.value)
      : _outlineStart * (1 - const Interval(0, .6).transform(_camera.value));
  Rect get _view =>
      interpolateMapView(_from, _to, _cameraProgress(_camera.value, _arriving));

  CountryShape? get _destination => widget.leg?.to == null
      ? null
      : CountryShape.of(widget.leg!.to!.countryCode);

  void _move({required bool arriving, required bool animate}) {
    final oldOutline = _outline;
    final oldCountry = _country;
    _from = _view;
    _arriving = arriving;
    final next = arriving ? _destination : oldCountry;
    _previousCountry = arriving && next != oldCountry ? oldCountry : null;
    _previousOpacity = _previousCountry == null ? 0 : oldOutline;
    _outlineStart = arriving && next != oldCountry ? 0 : oldOutline;
    _country = next;
    _to = arriving ? next?.viewport ?? _worldView : _worldView;
    _camera.duration = arriving
        ? RouteMapDesign.countryArrival
        : RouteMapDesign.countryDeparture;
    if (animate) {
      _camera.forward(from: 0);
    } else {
      _camera.value = 1;
    }
  }

  /// Made once: the welcome demo rebuilds the map on every frame.
  late final _landingCurve = CurvedAnimation(
    parent: _landing,
    curve: Curves.easeOutCubic,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final focused =
          widget.flight == FlightPhase.grounded && widget.leg?.to != null;
      _country = focused ? _destination : null;
      _from = _to = _country?.viewport ?? _worldView;
      _arriving = focused;
    }
    _updateMotion();
  }

  @override
  void didUpdateWidget(RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final landed =
        widget.flight == FlightPhase.grounded && widget.leg?.to != null;
    if (widget.flight != FlightPhase.grounded &&
        !widget.reconnecting &&
        (oldWidget.flight == FlightPhase.grounded || oldWidget.reconnecting)) {
      _move(arriving: false, animate: AppMotion.enabled(context));
    } else if (landed &&
        (widget.trips != oldWidget.trips ||
            oldWidget.flight != FlightPhase.grounded &&
                !oldWidget.reconnecting)) {
      _move(arriving: true, animate: AppMotion.enabled(context));
    } else if (widget.flight == FlightPhase.grounded &&
        widget.leg?.to == null &&
        (oldWidget.leg?.to != null || widget.trips != oldWidget.trips)) {
      _move(arriving: false, animate: AppMotion.enabled(context));
    }
    if (widget.trips > oldWidget.trips && AppMotion.enabled(context)) {
      _landing.forward(from: 0);
    }
    _updateMotion();
  }

  void _updateMotion() {
    final motion = AppMotion.enabled(context);
    if (!motion) {
      _landing.value = 1;
      _camera.value = 1;
    }
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
    _camera.dispose();
    _landingCurve.dispose();
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
        painter: RouteMapPainter(
          flight: widget.flight,
          playing: widget.playing,
          departure: widget.departure,
          leg: widget.leg,
          history: widget.history,
          trips: widget.trips,
          landing: _landingCurve,
          pulse: _pulse,
          camera: _camera,
          fromView: _from,
          toView: _to,
          country: _country,
          previousCountry: _previousCountry,
          previousOpacity: _previousOpacity,
          outlineStart: _outlineStart,
          arriving: _arriving,
        ),
      ),
    ),
  );
}

const _worldView = Rect.fromLTWH(
  -180,
  -RouteMapDesign.north,
  360,
  RouteMapDesign.north - RouteMapDesign.south,
);

double _cameraProgress(double value, bool arriving) => arriving
    ? const Interval(.12, .8, curve: Curves.easeInOutCubic).transform(value)
    : Curves.easeInOutCubic.transform(value);
double _reveal(double value) =>
    const Interval(.45, 1, curve: Curves.easeOutCubic).transform(value);

/// Paints the current camera frame; movement changes only display geometry.
class RouteMapPainter extends CustomPainter {
  RouteMapPainter({
    required this.flight,
    required this.playing,
    required this.departure,
    required this.leg,
    required this.history,
    required this.trips,
    required this.landing,
    required this.pulse,
    required this.camera,
    required this.fromView,
    required this.toView,
    required this.country,
    required this.previousCountry,
    required this.previousOpacity,
    required this.outlineStart,
    required this.arriving,
  }) : super(repaint: Listenable.merge([landing, pulse, camera]));

  final FlightPhase flight;
  final bool playing;
  final StationPlace departure;
  final TravelLeg? leg;
  final List<TravelLeg> history;
  final int trips;
  final Animation<double> landing, pulse, camera;
  final Rect fromView, toView;
  final CountryShape? country, previousCountry;
  final double previousOpacity, outlineStart;
  final bool arriving;

  Rect get viewport => interpolateMapView(
    fromView,
    toView,
    _cameraProgress(camera.value, arriving),
  );
  double get outline => country == null
      ? 0
      : arriving
      ? outlineStart + (1 - outlineStart) * _reveal(camera.value)
      : outlineStart * (1 - const Interval(0, .6).transform(camera.value));

  static const _ink = TravelRadioPalette.screenInk;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.clipRect(Offset.zero & size);
    final view = viewport;
    final scale = math.min(size.width / view.width, size.height / view.height);
    Offset project(GeoPoint p) {
      final lon =
          p.longitude + ((view.center.dx - p.longitude) / 360).round() * 360;
      return size.center(Offset.zero) +
          Offset(lon - view.center.dx, -p.latitude - view.center.dy) * scale;
    }

    _paintDots(canvas, project, scale, size);
    final fade = 1 - outline;
    for (final past in fade > .001 ? history : const <TravelLeg>[]) {
      if (identical(past, leg) || past.to == null) continue;
      _paintHistory(
        canvas,
        project(past.from.point),
        project(past.to!.point),
        fade,
      );
    }
    if (previousCountry != null) {
      _paintCountry(
        canvas,
        previousCountry!,
        previousOpacity * (1 - const Interval(0, .4).transform(camera.value)),
        view,
        scale,
        size,
      );
    }
    if (country != null && outline > 0) {
      _paintCountry(canvas, country!, outline, view, scale, size);
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
        canvas.drawCircle(
          from,
          RouteMapDesign.pointRadius * .7,
          Paint()..color = _ink.withValues(alpha: 1 - outline),
        );
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
              ..color = _ink.withValues(
                alpha: RouteMapDesign.arcOpacity * (1 - outline),
              ),
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

  static final _landPoints = <GeoPoint>[
    for (var row = 0; row < worldDotRows.length; row++)
      for (var col = 0; col < worldDotRows[row].length; col++)
        if (worldDotRows[row].codeUnitAt(col) == 0x31)
          GeoPoint(
            worldDotNorth - (row + .5) * worldDotStep,
            -180 + (col + .5) * worldDotStep,
          ),
  ];

  void _paintDots(
    Canvas canvas,
    Offset Function(GeoPoint) project,
    double scale,
    Size size,
  ) {
    final paint = Paint()
      ..color = _ink.withValues(
        alpha:
            RouteMapDesign.dotOpacity *
            (1 - outline * RouteMapDesign.countryDotFade),
      );
    final radius = (RouteMapDesign.dotRadius * math.sqrt(scale / .6)).clamp(
      RouteMapDesign.dotRadius,
      1.4,
    );
    final visible = (Offset.zero & size).inflate(radius);
    for (final place in _landPoints) {
      final point = project(place);
      if (visible.contains(point)) canvas.drawCircle(point, radius, paint);
    }
  }

  void _paintCountry(
    Canvas canvas,
    CountryShape shape,
    double progress,
    Rect view,
    double scale,
    Size size,
  ) {
    if (progress <= 0) return;
    final shift =
        ((view.center.dx - shape.bounds.center.dx) / 360).round() * 360.0;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    canvas.translate(shift - view.center.dx, -view.center.dy);
    canvas.drawPath(
      shape.path,
      Paint()
        ..color = _ink.withValues(
          alpha: RouteMapDesign.countryFillOpacity * progress,
        ),
    );
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = RouteMapDesign.countryStroke / scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _ink.withValues(alpha: progress.clamp(0, 1));
    if (progress >= 1) {
      canvas.drawPath(shape.path, ink);
    } else {
      var remaining = shape.length * progress;
      for (final metric in shape.metrics) {
        if (remaining <= 0) break;
        canvas.drawPath(
          metric.extractPath(0, math.min(remaining, metric.length)),
          ink,
        );
        remaining -= metric.length;
      }
    }
    canvas.restore();
  }

  void _paintHistory(Canvas canvas, Offset from, Offset to, double opacity) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = RouteMapDesign.historyStroke
      ..color = _ink.withValues(alpha: RouteMapDesign.historyOpacity * opacity);
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
  bool shouldRepaint(RouteMapPainter old) =>
      flight != old.flight ||
      playing != old.playing ||
      departure != old.departure ||
      leg != old.leg ||
      history != old.history ||
      trips != old.trips ||
      fromView != old.fromView ||
      toView != old.toView ||
      country != old.country ||
      previousCountry != old.previousCountry ||
      outlineStart != old.outlineStart ||
      arriving != old.arriving ||
      previousOpacity != old.previousOpacity;
}
