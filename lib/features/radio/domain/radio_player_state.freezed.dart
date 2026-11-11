// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'radio_player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RadioPlayerState {
  PlaybackStatus get status => throw _privateConstructorUsedError;
  RadioStation? get station => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get trackTitle => throw _privateConstructorUsedError;

  /// Create a copy of RadioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RadioPlayerStateCopyWith<RadioPlayerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RadioPlayerStateCopyWith<$Res> {
  factory $RadioPlayerStateCopyWith(
    RadioPlayerState value,
    $Res Function(RadioPlayerState) then,
  ) = _$RadioPlayerStateCopyWithImpl<$Res, RadioPlayerState>;
  @useResult
  $Res call({
    PlaybackStatus status,
    RadioStation? station,
    String? errorMessage,
    String? trackTitle,
  });

  $RadioStationCopyWith<$Res>? get station;
}

/// @nodoc
class _$RadioPlayerStateCopyWithImpl<$Res, $Val extends RadioPlayerState>
    implements $RadioPlayerStateCopyWith<$Res> {
  _$RadioPlayerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RadioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? station = freezed,
    Object? errorMessage = freezed,
    Object? trackTitle = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PlaybackStatus,
            station: freezed == station
                ? _value.station
                : station // ignore: cast_nullable_to_non_nullable
                      as RadioStation?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            trackTitle: freezed == trackTitle
                ? _value.trackTitle
                : trackTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of RadioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RadioStationCopyWith<$Res>? get station {
    if (_value.station == null) {
      return null;
    }

    return $RadioStationCopyWith<$Res>(_value.station!, (value) {
      return _then(_value.copyWith(station: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RadioPlayerStateImplCopyWith<$Res>
    implements $RadioPlayerStateCopyWith<$Res> {
  factory _$$RadioPlayerStateImplCopyWith(
    _$RadioPlayerStateImpl value,
    $Res Function(_$RadioPlayerStateImpl) then,
  ) = __$$RadioPlayerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    PlaybackStatus status,
    RadioStation? station,
    String? errorMessage,
    String? trackTitle,
  });

  @override
  $RadioStationCopyWith<$Res>? get station;
}

/// @nodoc
class __$$RadioPlayerStateImplCopyWithImpl<$Res>
    extends _$RadioPlayerStateCopyWithImpl<$Res, _$RadioPlayerStateImpl>
    implements _$$RadioPlayerStateImplCopyWith<$Res> {
  __$$RadioPlayerStateImplCopyWithImpl(
    _$RadioPlayerStateImpl _value,
    $Res Function(_$RadioPlayerStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? station = freezed,
    Object? errorMessage = freezed,
    Object? trackTitle = freezed,
  }) {
    return _then(
      _$RadioPlayerStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PlaybackStatus,
        station: freezed == station
            ? _value.station
            : station // ignore: cast_nullable_to_non_nullable
                  as RadioStation?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        trackTitle: freezed == trackTitle
            ? _value.trackTitle
            : trackTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$RadioPlayerStateImpl extends _RadioPlayerState {
  const _$RadioPlayerStateImpl({
    this.status = PlaybackStatus.idle,
    this.station,
    this.errorMessage,
    this.trackTitle,
  }) : super._();

  @override
  @JsonKey()
  final PlaybackStatus status;
  @override
  final RadioStation? station;
  @override
  final String? errorMessage;
  @override
  final String? trackTitle;

  @override
  String toString() {
    return 'RadioPlayerState(status: $status, station: $station, errorMessage: $errorMessage, trackTitle: $trackTitle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RadioPlayerStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.station, station) || other.station == station) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.trackTitle, trackTitle) ||
                other.trackTitle == trackTitle));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, status, station, errorMessage, trackTitle);

  /// Create a copy of RadioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RadioPlayerStateImplCopyWith<_$RadioPlayerStateImpl> get copyWith =>
      __$$RadioPlayerStateImplCopyWithImpl<_$RadioPlayerStateImpl>(
        this,
        _$identity,
      );
}

abstract class _RadioPlayerState extends RadioPlayerState {
  const factory _RadioPlayerState({
    final PlaybackStatus status,
    final RadioStation? station,
    final String? errorMessage,
    final String? trackTitle,
  }) = _$RadioPlayerStateImpl;
  const _RadioPlayerState._() : super._();

  @override
  PlaybackStatus get status;
  @override
  RadioStation? get station;
  @override
  String? get errorMessage;
  @override
  String? get trackTitle;

  /// Create a copy of RadioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RadioPlayerStateImplCopyWith<_$RadioPlayerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
