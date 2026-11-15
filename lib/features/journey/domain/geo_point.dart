import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'geo_point.freezed.dart';

/// A position on Earth in decimal degrees.
@freezed
class GeoPoint with _$GeoPoint {
  const GeoPoint._();

  const factory GeoPoint(double latitude, double longitude) = _GeoPoint;

  static const _earthRadiusKm = 6371.0;

  /// Reads numeric coordinates, treating out-of-range values and the
  /// placeholder pair 0,0 as missing.
  static GeoPoint? tryFrom(Object? latitude, Object? longitude) {
    if (latitude is! num || longitude is! num) return null;
    final lat = latitude.toDouble(), lon = longitude.toDouble();
    if (!lat.isFinite || !lon.isFinite) return null;
    if (lat.abs() > 90 || lon.abs() > 180) return null;
    if (lat == 0 && lon == 0) return null;
    return GeoPoint(lat, lon);
  }

  double distanceKm(GeoPoint other) {
    double rad(double degrees) => degrees * math.pi / 180;
    final dLat = rad(other.latitude - latitude);
    final dLon = rad(other.longitude - longitude);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(latitude)) *
            math.cos(rad(other.latitude)) *
            math.pow(math.sin(dLon / 2), 2);
    return 2 * _earthRadiusKm * math.asin(math.min(1, math.sqrt(a)));
  }
}
