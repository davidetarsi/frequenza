// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'radio_station.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RadioStation _$RadioStationFromJson(Map<String, dynamic> json) {
  return _RadioStation.fromJson(json);
}

/// @nodoc
mixin _$RadioStation {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'url')
  String get streamUrl => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  @JsonKey(name: 'code')
  String get countryCode => throw _privateConstructorUsedError;
  String? get faviconUrl => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String? get codec => throw _privateConstructorUsedError;
  int? get bitrate => throw _privateConstructorUsedError;
  @JsonKey(name: 'lat')
  double? get latitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'lon')
  double? get longitude => throw _privateConstructorUsedError;

  /// Serializes this RadioStation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RadioStation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RadioStationCopyWith<RadioStation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RadioStationCopyWith<$Res> {
  factory $RadioStationCopyWith(
    RadioStation value,
    $Res Function(RadioStation) then,
  ) = _$RadioStationCopyWithImpl<$Res, RadioStation>;
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'url') String streamUrl,
    String country,
    @JsonKey(name: 'code') String countryCode,
    String? faviconUrl,
    List<String> tags,
    String? codec,
    int? bitrate,
    @JsonKey(name: 'lat') double? latitude,
    @JsonKey(name: 'lon') double? longitude,
  });
}

/// @nodoc
class _$RadioStationCopyWithImpl<$Res, $Val extends RadioStation>
    implements $RadioStationCopyWith<$Res> {
  _$RadioStationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RadioStation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? streamUrl = null,
    Object? country = null,
    Object? countryCode = null,
    Object? faviconUrl = freezed,
    Object? tags = null,
    Object? codec = freezed,
    Object? bitrate = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            streamUrl: null == streamUrl
                ? _value.streamUrl
                : streamUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            country: null == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String,
            countryCode: null == countryCode
                ? _value.countryCode
                : countryCode // ignore: cast_nullable_to_non_nullable
                      as String,
            faviconUrl: freezed == faviconUrl
                ? _value.faviconUrl
                : faviconUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            codec: freezed == codec
                ? _value.codec
                : codec // ignore: cast_nullable_to_non_nullable
                      as String?,
            bitrate: freezed == bitrate
                ? _value.bitrate
                : bitrate // ignore: cast_nullable_to_non_nullable
                      as int?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RadioStationImplCopyWith<$Res>
    implements $RadioStationCopyWith<$Res> {
  factory _$$RadioStationImplCopyWith(
    _$RadioStationImpl value,
    $Res Function(_$RadioStationImpl) then,
  ) = __$$RadioStationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'url') String streamUrl,
    String country,
    @JsonKey(name: 'code') String countryCode,
    String? faviconUrl,
    List<String> tags,
    String? codec,
    int? bitrate,
    @JsonKey(name: 'lat') double? latitude,
    @JsonKey(name: 'lon') double? longitude,
  });
}

/// @nodoc
class __$$RadioStationImplCopyWithImpl<$Res>
    extends _$RadioStationCopyWithImpl<$Res, _$RadioStationImpl>
    implements _$$RadioStationImplCopyWith<$Res> {
  __$$RadioStationImplCopyWithImpl(
    _$RadioStationImpl _value,
    $Res Function(_$RadioStationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioStation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? streamUrl = null,
    Object? country = null,
    Object? countryCode = null,
    Object? faviconUrl = freezed,
    Object? tags = null,
    Object? codec = freezed,
    Object? bitrate = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(
      _$RadioStationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        streamUrl: null == streamUrl
            ? _value.streamUrl
            : streamUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        country: null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String,
        countryCode: null == countryCode
            ? _value.countryCode
            : countryCode // ignore: cast_nullable_to_non_nullable
                  as String,
        faviconUrl: freezed == faviconUrl
            ? _value.faviconUrl
            : faviconUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        codec: freezed == codec
            ? _value.codec
            : codec // ignore: cast_nullable_to_non_nullable
                  as String?,
        bitrate: freezed == bitrate
            ? _value.bitrate
            : bitrate // ignore: cast_nullable_to_non_nullable
                  as int?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RadioStationImpl extends _RadioStation {
  const _$RadioStationImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'url') required this.streamUrl,
    required this.country,
    @JsonKey(name: 'code') required this.countryCode,
    this.faviconUrl,
    final List<String> tags = const [],
    this.codec,
    this.bitrate,
    @JsonKey(name: 'lat') this.latitude,
    @JsonKey(name: 'lon') this.longitude,
  }) : _tags = tags,
       super._();

  factory _$RadioStationImpl.fromJson(Map<String, dynamic> json) =>
      _$$RadioStationImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'url')
  final String streamUrl;
  @override
  final String country;
  @override
  @JsonKey(name: 'code')
  final String countryCode;
  @override
  final String? faviconUrl;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String? codec;
  @override
  final int? bitrate;
  @override
  @JsonKey(name: 'lat')
  final double? latitude;
  @override
  @JsonKey(name: 'lon')
  final double? longitude;

  @override
  String toString() {
    return 'RadioStation(id: $id, name: $name, streamUrl: $streamUrl, country: $country, countryCode: $countryCode, faviconUrl: $faviconUrl, tags: $tags, codec: $codec, bitrate: $bitrate, latitude: $latitude, longitude: $longitude)';
  }

  /// Create a copy of RadioStation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RadioStationImplCopyWith<_$RadioStationImpl> get copyWith =>
      __$$RadioStationImplCopyWithImpl<_$RadioStationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RadioStationImplToJson(this);
  }
}

abstract class _RadioStation extends RadioStation {
  const factory _RadioStation({
    required final String id,
    required final String name,
    @JsonKey(name: 'url') required final String streamUrl,
    required final String country,
    @JsonKey(name: 'code') required final String countryCode,
    final String? faviconUrl,
    final List<String> tags,
    final String? codec,
    final int? bitrate,
    @JsonKey(name: 'lat') final double? latitude,
    @JsonKey(name: 'lon') final double? longitude,
  }) = _$RadioStationImpl;
  const _RadioStation._() : super._();

  factory _RadioStation.fromJson(Map<String, dynamic> json) =
      _$RadioStationImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'url')
  String get streamUrl;
  @override
  String get country;
  @override
  @JsonKey(name: 'code')
  String get countryCode;
  @override
  String? get faviconUrl;
  @override
  List<String> get tags;
  @override
  String? get codec;
  @override
  int? get bitrate;
  @override
  @JsonKey(name: 'lat')
  double? get latitude;
  @override
  @JsonKey(name: 'lon')
  double? get longitude;

  /// Create a copy of RadioStation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RadioStationImplCopyWith<_$RadioStationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
