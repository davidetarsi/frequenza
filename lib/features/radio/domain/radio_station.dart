// Freezed copies the JSON annotations from factory parameters to the fields.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

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
  }) = _RadioStation;

  factory RadioStation.fromJson(Map<String, dynamic> json) =>
      _$RadioStationFromJson(json);

  @override
  bool operator ==(Object other) => other is RadioStation && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
