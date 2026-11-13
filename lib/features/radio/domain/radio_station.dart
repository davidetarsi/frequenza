// Freezed copies the JSON annotations from factory parameters to the fields.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../journey/domain/geo_point.dart';

part 'radio_station.freezed.dart';
part 'radio_station.g.dart';

@Freezed(equal: false)
class RadioStation with _$RadioStation {
  const RadioStation._();

  const factory RadioStation({
    required String id,
    required String name,
    @JsonKey(name: 'url') required String streamUrl,
    required String country,
    @JsonKey(name: 'code') required String countryCode,
    String? faviconUrl,
    @Default([]) List<String> tags,
    String? codec,
    int? bitrate,
    @JsonKey(name: 'lat') double? latitude,
    @JsonKey(name: 'lon') double? longitude,
  }) = _RadioStation;

  factory RadioStation.fromJson(Map<String, dynamic> json) =>
      _$RadioStationFromJson(json);

  /// The station's own position, when Radio Browser provides a valid one.
  GeoPoint? get point => GeoPoint.tryFrom(latitude, longitude);

  @override
  bool operator ==(Object other) => other is RadioStation && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
