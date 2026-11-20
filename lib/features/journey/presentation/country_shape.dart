import 'dart:math' as math;
import 'dart:ui';

import '../domain/atlas/country_outlines.g.dart';
import '../../../ui/theme/travel_radio_design.dart';

/// Display geometry only. Decoded lazily, without networking or product state.
class CountryShape {
  CountryShape._(this.rings, this.bounds);

  final List<List<Offset>> rings;
  final Rect bounds;
  static final _cache = <String, CountryShape>{};

  static CountryShape? of(String code) {
    final cached = _cache[code];
    if (cached != null) return cached;
    final encoded = countryOutlines[code];
    if (encoded == null) return null;
    final rings = <List<Offset>>[];
    for (final ring in encoded.split('|')) {
      var x = 0, y = 0;
      final points = <Offset>[];
      for (final point in ring.split(';')) {
        final pair = point.split(',');
        x += int.parse(pair[0], radix: 36);
        y += int.parse(pair[1], radix: 36);
        points.add(Offset(x / 1000, -y / 1000));
      }
      rings.add(points);
    }
    // The biggest empty longitude gap is the seam. Fiji and Russia must
    // not grow to a full-world box because they cross the date line.
    final longitudes = rings.expand((ring) => ring).map((p) => p.dx).toList()
      ..sort();
    var seam = longitudes.first;
    var widest = -1.0;
    for (var i = 0; i < longitudes.length; i++) {
      final next = longitudes[(i + 1) % longitudes.length];
      final gap = i == longitudes.length - 1
          ? next + 360 - longitudes[i]
          : next - longitudes[i];
      if (gap > widest) {
        widest = gap;
        seam = next;
      }
    }
    final unwrapped = rings
        .map(
          (ring) => ring
              .map((p) => Offset(p.dx < seam ? p.dx + 360 : p.dx, p.dy))
              .toList(),
        )
        .toList();
    var bounds = _bounds(unwrapped);
    final shift = (bounds.center.dx / 360).round() * 360.0;
    final normalized = unwrapped
        .map((ring) => ring.map((p) => p - Offset(shift, 0)).toList())
        .toList();
    bounds = _bounds(normalized);
    final shape = CountryShape._(normalized, bounds);
    _cache[code] = shape;
    return shape;
  }

  late final Path path = _path();
  late final List<PathMetric> metrics = path.computeMetrics().toList();
  late final double length = metrics.fold(
    0,
    (sum, metric) => sum + metric.length,
  );

  Path _path() {
    final result = Path()..fillType = PathFillType.evenOdd;
    for (final ring in rings) {
      result.moveTo(ring.first.dx, ring.first.dy);
      for (final point in ring.skip(1)) {
        result.lineTo(point.dx, point.dy);
      }
      result.close();
    }
    return result;
  }

  /// A little breathing room around the whole country, also for small islands.
  Rect get viewport => Rect.fromCenter(
    center: bounds.center,
    width: math.max(
      RouteMapDesign.minCountryViewExtent,
      bounds.width * RouteMapDesign.countryViewMargin,
    ),
    height: math.max(
      RouteMapDesign.minCountryViewExtent,
      bounds.height * RouteMapDesign.countryViewMargin,
    ),
  );

  static Rect _bounds(List<List<Offset>> rings) {
    final points = rings.expand((r) => r);
    return Rect.fromLTRB(
      points.map((p) => p.dx).reduce(math.min),
      points.map((p) => p.dy).reduce(math.min),
      points.map((p) => p.dx).reduce(math.max),
      points.map((p) => p.dy).reduce(math.max),
    );
  }
}

/// Scale geometrically and pan by the same change in extent. This keeps the
/// destination in frame instead of zooming past it while the centre catches up.
Rect interpolateMapView(Rect from, Rect to, double progress) {
  if (progress <= 0) return from;
  if (progress >= 1) return to;
  (double, double) axis(double a, double b, double start, double end) {
    if (a == b) return (a, start + (end - start) * progress);
    final extent = math.exp(
      math.log(a) + (math.log(b) - math.log(a)) * progress,
    );
    final pan = (extent - a) / (b - a);
    return (extent, start + (end - start) * pan);
  }

  final (width, x) = axis(from.width, to.width, from.center.dx, to.center.dx);
  final (height, y) = axis(
    from.height,
    to.height,
    from.center.dy,
    to.center.dy,
  );
  return Rect.fromCenter(center: Offset(x, y), width: width, height: height);
}
