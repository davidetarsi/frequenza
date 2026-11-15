// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'station_place.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$StationPlace {
  GeoPoint get point => throw _privateConstructorUsedError;
  bool get approximate => throw _privateConstructorUsedError;
  String get countryCode => throw _privateConstructorUsedError;

  /// Create a copy of StationPlace
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StationPlaceCopyWith<StationPlace> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StationPlaceCopyWith<$Res> {
  factory $StationPlaceCopyWith(
    StationPlace value,
    $Res Function(StationPlace) then,
  ) = _$StationPlaceCopyWithImpl<$Res, StationPlace>;
  @useResult
  $Res call({GeoPoint point, bool approximate, String countryCode});

  $GeoPointCopyWith<$Res> get point;
}

/// @nodoc
class _$StationPlaceCopyWithImpl<$Res, $Val extends StationPlace>
    implements $StationPlaceCopyWith<$Res> {
  _$StationPlaceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StationPlace
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? point = null,
    Object? approximate = null,
    Object? countryCode = null,
  }) {
    return _then(
      _value.copyWith(
            point: null == point
                ? _value.point
                : point // ignore: cast_nullable_to_non_nullable
                      as GeoPoint,
            approximate: null == approximate
                ? _value.approximate
                : approximate // ignore: cast_nullable_to_non_nullable
                      as bool,
            countryCode: null == countryCode
                ? _value.countryCode
                : countryCode // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of StationPlace
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GeoPointCopyWith<$Res> get point {
    return $GeoPointCopyWith<$Res>(_value.point, (value) {
      return _then(_value.copyWith(point: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StationPlaceImplCopyWith<$Res>
    implements $StationPlaceCopyWith<$Res> {
  factory _$$StationPlaceImplCopyWith(
    _$StationPlaceImpl value,
    $Res Function(_$StationPlaceImpl) then,
  ) = __$$StationPlaceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({GeoPoint point, bool approximate, String countryCode});

  @override
  $GeoPointCopyWith<$Res> get point;
}

/// @nodoc
class __$$StationPlaceImplCopyWithImpl<$Res>
    extends _$StationPlaceCopyWithImpl<$Res, _$StationPlaceImpl>
    implements _$$StationPlaceImplCopyWith<$Res> {
  __$$StationPlaceImplCopyWithImpl(
    _$StationPlaceImpl _value,
    $Res Function(_$StationPlaceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StationPlace
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? point = null,
    Object? approximate = null,
    Object? countryCode = null,
  }) {
    return _then(
      _$StationPlaceImpl(
        point: null == point
            ? _value.point
            : point // ignore: cast_nullable_to_non_nullable
                  as GeoPoint,
        approximate: null == approximate
            ? _value.approximate
            : approximate // ignore: cast_nullable_to_non_nullable
                  as bool,
        countryCode: null == countryCode
            ? _value.countryCode
            : countryCode // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$StationPlaceImpl implements _StationPlace {
  const _$StationPlaceImpl({
    required this.point,
    required this.approximate,
    required this.countryCode,
  });

  @override
  final GeoPoint point;
  @override
  final bool approximate;
  @override
  final String countryCode;

  @override
  String toString() {
    return 'StationPlace(point: $point, approximate: $approximate, countryCode: $countryCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StationPlaceImpl &&
            (identical(other.point, point) || other.point == point) &&
            (identical(other.approximate, approximate) ||
                other.approximate == approximate) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, point, approximate, countryCode);

  /// Create a copy of StationPlace
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StationPlaceImplCopyWith<_$StationPlaceImpl> get copyWith =>
      __$$StationPlaceImplCopyWithImpl<_$StationPlaceImpl>(this, _$identity);
}

abstract class _StationPlace implements StationPlace {
  const factory _StationPlace({
    required final GeoPoint point,
    required final bool approximate,
    required final String countryCode,
  }) = _$StationPlaceImpl;

  @override
  GeoPoint get point;
  @override
  bool get approximate;
  @override
  String get countryCode;

  /// Create a copy of StationPlace
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StationPlaceImplCopyWith<_$StationPlaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
