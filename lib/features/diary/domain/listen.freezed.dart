// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listen.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Listen {
  int get id => throw _privateConstructorUsedError;
  String get stationId => throw _privateConstructorUsedError;

  /// ISO alpha-2, empty when unknown.
  String get countryCode => throw _privateConstructorUsedError;

  /// UTC.
  DateTime get startedAt => throw _privateConstructorUsedError;
  int get seconds => throw _privateConstructorUsedError;

  /// Create a copy of Listen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListenCopyWith<Listen> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListenCopyWith<$Res> {
  factory $ListenCopyWith(Listen value, $Res Function(Listen) then) =
      _$ListenCopyWithImpl<$Res, Listen>;
  @useResult
  $Res call({
    int id,
    String stationId,
    String countryCode,
    DateTime startedAt,
    int seconds,
  });
}

/// @nodoc
class _$ListenCopyWithImpl<$Res, $Val extends Listen>
    implements $ListenCopyWith<$Res> {
  _$ListenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Listen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stationId = null,
    Object? countryCode = null,
    Object? startedAt = null,
    Object? seconds = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            stationId: null == stationId
                ? _value.stationId
                : stationId // ignore: cast_nullable_to_non_nullable
                      as String,
            countryCode: null == countryCode
                ? _value.countryCode
                : countryCode // ignore: cast_nullable_to_non_nullable
                      as String,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            seconds: null == seconds
                ? _value.seconds
                : seconds // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ListenImplCopyWith<$Res> implements $ListenCopyWith<$Res> {
  factory _$$ListenImplCopyWith(
    _$ListenImpl value,
    $Res Function(_$ListenImpl) then,
  ) = __$$ListenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String stationId,
    String countryCode,
    DateTime startedAt,
    int seconds,
  });
}

/// @nodoc
class __$$ListenImplCopyWithImpl<$Res>
    extends _$ListenCopyWithImpl<$Res, _$ListenImpl>
    implements _$$ListenImplCopyWith<$Res> {
  __$$ListenImplCopyWithImpl(
    _$ListenImpl _value,
    $Res Function(_$ListenImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Listen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stationId = null,
    Object? countryCode = null,
    Object? startedAt = null,
    Object? seconds = null,
  }) {
    return _then(
      _$ListenImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        stationId: null == stationId
            ? _value.stationId
            : stationId // ignore: cast_nullable_to_non_nullable
                  as String,
        countryCode: null == countryCode
            ? _value.countryCode
            : countryCode // ignore: cast_nullable_to_non_nullable
                  as String,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        seconds: null == seconds
            ? _value.seconds
            : seconds // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ListenImpl implements _Listen {
  const _$ListenImpl({
    required this.id,
    required this.stationId,
    required this.countryCode,
    required this.startedAt,
    required this.seconds,
  });

  @override
  final int id;
  @override
  final String stationId;

  /// ISO alpha-2, empty when unknown.
  @override
  final String countryCode;

  /// UTC.
  @override
  final DateTime startedAt;
  @override
  final int seconds;

  @override
  String toString() {
    return 'Listen(id: $id, stationId: $stationId, countryCode: $countryCode, startedAt: $startedAt, seconds: $seconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListenImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.seconds, seconds) || other.seconds == seconds));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, stationId, countryCode, startedAt, seconds);

  /// Create a copy of Listen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListenImplCopyWith<_$ListenImpl> get copyWith =>
      __$$ListenImplCopyWithImpl<_$ListenImpl>(this, _$identity);
}

abstract class _Listen implements Listen {
  const factory _Listen({
    required final int id,
    required final String stationId,
    required final String countryCode,
    required final DateTime startedAt,
    required final int seconds,
  }) = _$ListenImpl;

  @override
  int get id;
  @override
  String get stationId;

  /// ISO alpha-2, empty when unknown.
  @override
  String get countryCode;

  /// UTC.
  @override
  DateTime get startedAt;
  @override
  int get seconds;

  /// Create a copy of Listen
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListenImplCopyWith<_$ListenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
