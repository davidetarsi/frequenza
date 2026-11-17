import 'package:freezed_annotation/freezed_annotation.dart';

part 'listen.freezed.dart';

/// One continuous listen to a station: a snapshot, always valid.
@freezed
class Listen with _$Listen {
  const factory Listen({
    required int id,
    required String stationId,

    /// ISO alpha-2, empty when unknown.
    required String countryCode,

    /// UTC.
    required DateTime startedAt,
    required int seconds,
  }) = _Listen;
}
