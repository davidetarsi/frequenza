// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radio_station.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RadioStationImpl _$$RadioStationImplFromJson(Map<String, dynamic> json) =>
    _$RadioStationImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      streamUrl: json['url'] as String,
      country: json['country'] as String,
      countryCode: json['code'] as String,
      faviconUrl: json['faviconUrl'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      codec: json['codec'] as String?,
      bitrate: (json['bitrate'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$RadioStationImplToJson(_$RadioStationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.streamUrl,
      'country': instance.country,
      'code': instance.countryCode,
      'faviconUrl': instance.faviconUrl,
      'tags': instance.tags,
      'codec': instance.codec,
      'bitrate': instance.bitrate,
    };
