// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'radio_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RadioSession {
  Journey get journey => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Journey journey) off,
    required TResult Function(
      Journey journey,
      FlightKind kind,
      int attempt,
      bool signalLost,
    )
    flying,
    required TResult Function(
      Journey journey,
      RadioStation station,
      OnAirPlayback playback,
      String? trackTitle,
    )
    onAir,
    required TResult Function(Journey journey) failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Journey journey)? off,
    TResult? Function(
      Journey journey,
      FlightKind kind,
      int attempt,
      bool signalLost,
    )?
    flying,
    TResult? Function(
      Journey journey,
      RadioStation station,
      OnAirPlayback playback,
      String? trackTitle,
    )?
    onAir,
    TResult? Function(Journey journey)? failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Journey journey)? off,
    TResult Function(
      Journey journey,
      FlightKind kind,
      int attempt,
      bool signalLost,
    )?
    flying,
    TResult Function(
      Journey journey,
      RadioStation station,
      OnAirPlayback playback,
      String? trackTitle,
    )?
    onAir,
    TResult Function(Journey journey)? failed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Off value) off,
    required TResult Function(Flying value) flying,
    required TResult Function(OnAir value) onAir,
    required TResult Function(Failed value) failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Off value)? off,
    TResult? Function(Flying value)? flying,
    TResult? Function(OnAir value)? onAir,
    TResult? Function(Failed value)? failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Off value)? off,
    TResult Function(Flying value)? flying,
    TResult Function(OnAir value)? onAir,
    TResult Function(Failed value)? failed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of RadioSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RadioSessionCopyWith<RadioSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RadioSessionCopyWith<$Res> {
  factory $RadioSessionCopyWith(
    RadioSession value,
    $Res Function(RadioSession) then,
  ) = _$RadioSessionCopyWithImpl<$Res, RadioSession>;
  @useResult
  $Res call({Journey journey});

  $JourneyCopyWith<$Res> get journey;
}

/// @nodoc
class _$RadioSessionCopyWithImpl<$Res, $Val extends RadioSession>
    implements $RadioSessionCopyWith<$Res> {
  _$RadioSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RadioSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? journey = null}) {
    return _then(
      _value.copyWith(
            journey: null == journey
                ? _value.journey
                : journey // ignore: cast_nullable_to_non_nullable
                      as Journey,
          )
          as $Val,
    );
  }

  /// Create a copy of RadioSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $JourneyCopyWith<$Res> get journey {
    return $JourneyCopyWith<$Res>(_value.journey, (value) {
      return _then(_value.copyWith(journey: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OffImplCopyWith<$Res> implements $RadioSessionCopyWith<$Res> {
  factory _$$OffImplCopyWith(_$OffImpl value, $Res Function(_$OffImpl) then) =
      __$$OffImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Journey journey});

  @override
  $JourneyCopyWith<$Res> get journey;
}

/// @nodoc
class __$$OffImplCopyWithImpl<$Res>
    extends _$RadioSessionCopyWithImpl<$Res, _$OffImpl>
    implements _$$OffImplCopyWith<$Res> {
  __$$OffImplCopyWithImpl(_$OffImpl _value, $Res Function(_$OffImpl) _then)
    : super(_value, _then);

  /// Create a copy of RadioSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? journey = null}) {
    return _then(
      _$OffImpl(
        null == journey
            ? _value.journey
            : journey // ignore: cast_nullable_to_non_nullable
                  as Journey,
      ),
    );
  }
}

/// @nodoc

class _$OffImpl implements Off {
  const _$OffImpl(this.journey);

  @override
  final Journey journey;

  @override
  String toString() {
    return 'RadioSession.off(journey: $journey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OffImpl &&
            (identical(other.journey, journey) || other.journey == journey));
  }

  @override
  int get hashCode => Object.hash(runtimeType, journey);

  /// Create a copy of RadioSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OffImplCopyWith<_$OffImpl> get copyWith =>
      __$$OffImplCopyWithImpl<_$OffImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Journey journey) off,
    required TResult Function(
      Journey journey,
      FlightKind kind,
      int attempt,
      bool signalLost,
    )
    flying,
    required TResult Function(
      Journey journey,
      RadioStation station,
      OnAirPlayback playback,
      String? trackTitle,
    )
    onAir,
    required TResult Function(Journey journey) failed,
  }) {
    return off(journey);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Journey journey)? off,
    TResult? Function(
      Journey journey,
      FlightKind kind,
      int attempt,
      bool signalLost,
    )?
    flying,
    TResult? Function(
      Journey journey,
      RadioStation station,
      OnAirPlayback playback,
      String? trackTitle,
    )?
    onAir,
    TResult? Function(Journey journey)? failed,
  }) {
    return off?.call(journey);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Journey journey)? off,
    TResult Function(
      Journey journey,
      FlightKind kind,
      int attempt,
      bool signalLost,
    )?
    flying,
    TResult Function(
      Journey journey,
      RadioStation station,
      OnAirPlayback playback,
      String? trackTitle,
    )?
    onAir,
    TResult Function(Journey journey)? failed,
    required TResult orElse(),
  }) {
    if (off != null) {
      return off(journey);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Off value) off,
    required TResult Function(Flying value) flying,
    required TResult Function(OnAir value) onAir,
    required TResult Function(Failed value) failed,
  }) {
    return off(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Off value)? off,
    TResult? Function(Flying value)? flying,
    TResult? Function(OnAir value)? onAir,
    TResult? Function(Failed value)? failed,
  }) {
    return off?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Off value)? off,
    TResult Function(Flying value)? flying,
    TResult Function(OnAir value)? onAir,
    TResult Function(Failed value)? failed,
    required TResult orElse(),
  }) {
    if (off != null) {
      return off(this);
    }
    return orElse();
  }
}

abstract class Off implements RadioSession {
  const factory Off(final Journey journey) = _$OffImpl;

  @override
  Journey get journey;

  /// Create a copy of RadioSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OffImplCopyWith<_$OffImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FlyingImplCopyWith<$Res>
    implements $RadioSessionCopyWith<$Res> {
  factory _$$FlyingImplCopyWith(
    _$FlyingImpl value,
    $Res Function(_$FlyingImpl) then,
  ) = __$$FlyingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Journey journey, FlightKind kind, int attempt, bool signalLost});

  @override
  $JourneyCopyWith<$Res> get journey;
}

/// @nodoc
class __$$FlyingImplCopyWithImpl<$Res>
    extends _$RadioSessionCopyWithImpl<$Res, _$FlyingImpl>
    implements _$$FlyingImplCopyWith<$Res> {
  __$$FlyingImplCopyWithImpl(
    _$FlyingImpl _value,
    $Res Function(_$FlyingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? journey = null,
    Object? kind = null,
    Object? attempt = null,
    Object? signalLost = null,
  }) {
    return _then(
      _$FlyingImpl(
        null == journey
            ? _value.journey
            : journey // ignore: cast_nullable_to_non_nullable
                  as Journey,
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as FlightKind,
        attempt: null == attempt
            ? _value.attempt
            : attempt // ignore: cast_nullable_to_non_nullable
                  as int,
        signalLost: null == signalLost
            ? _value.signalLost
            : signalLost // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$FlyingImpl implements Flying {
  const _$FlyingImpl(
    this.journey, {
    required this.kind,
    this.attempt = 0,
    this.signalLost = false,
  });

  @override
  final Journey journey;
  @override
  final FlightKind kind;
  @override
  @JsonKey()
  final int attempt;
  @override
  @JsonKey()
  final bool signalLost;

  @override
  String toString() {
    return 'RadioSession.flying(journey: $journey, kind: $kind, attempt: $attempt, signalLost: $signalLost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlyingImpl &&
            (identical(other.journey, journey) || other.journey == journey) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.attempt, attempt) || other.attempt == attempt) &&
            (identical(other.signalLost, signalLost) ||
                other.signalLost == signalLost));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, journey, kind, attempt, signalLost);

  /// Create a copy of RadioSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlyingImplCopyWith<_$FlyingImpl> get copyWith =>
      __$$FlyingImplCopyWithImpl<_$FlyingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Journey journey) off,
    required TResult Function(
      Journey journey,
      FlightKind kind,
      int attempt,
      bool signalLost,
    )
    flying,
    required TResult Function(
      Journey journey,
      RadioStation station,
      OnAirPlayback playback,
      String? trackTitle,
    )
    onAir,
    required TResult Function(Journey journey) failed,
  }) {
    return flying(journey, kind, attempt, signalLost);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Journey journey)? off,
    TResult? Function(
      Journey journey,
      FlightKind kind,
      int attempt,
      bool signalLost,
    )?
    flying,
    TResult? Function(
      Journey journey,
      RadioStation station,
      OnAirPlayback playback,
      String? trackTitle,
    )?
    onAir,
    TResult? Function(Journey journey)? failed,
  }) {
    return flying?.call(journey, kind, attempt, signalLost);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Journey journey)? off,
    TResult Function(
      Journey journey,
      FlightKind kind,
      int attempt,
      bool signalLost,
    )?
    flying,
    TResult Function(
      Journey journey,
      RadioStation station,
      OnAirPlayback playback,
      String? trackTitle,
    )?
    onAir,
    TResult Function(Journey journey)? failed,
    required TResult orElse(),
  }) {
    if (flying != null) {
      return flying(journey, kind, attempt, signalLost);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Off value) off,
    required TResult Function(Flying value) flying,
    required TResult Function(OnAir value) onAir,
    required TResult Function(Failed value) failed,
  }) {
    return flying(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Off value)? off,
    TResult? Function(Flying value)? flying,
    TResult? Function(OnAir value)? onAir,
    TResult? Function(Failed value)? failed,
  }) {
    return flying?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Off value)? off,
    TResult Function(Flying value)? flying,
    TResult Function(OnAir value)? onAir,
    TResult Function(Failed value)? failed,
    required TResult orElse(),
  }) {
    if (flying != null) {
      return flying(this);
    }
    return orElse();
  }
}

abstract class Flying implements RadioSession {
  const factory Flying(
    final Journey journey, {
    required final FlightKind kind,
    final int attempt,
    final bool signalLost,
  }) = _$FlyingImpl;

  @override
  Journey get journey;
  FlightKind get kind;
  int get attempt;
  bool get signalLost;

  /// Create a copy of RadioSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlyingImplCopyWith<_$FlyingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$OnAirImplCopyWith<$Res>
    implements $RadioSessionCopyWith<$Res> {
  factory _$$OnAirImplCopyWith(
    _$OnAirImpl value,
    $Res Function(_$OnAirImpl) then,
  ) = __$$OnAirImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Journey journey,
    RadioStation station,
    OnAirPlayback playback,
    String? trackTitle,
  });

  @override
  $JourneyCopyWith<$Res> get journey;
  $RadioStationCopyWith<$Res> get station;
}

/// @nodoc
class __$$OnAirImplCopyWithImpl<$Res>
    extends _$RadioSessionCopyWithImpl<$Res, _$OnAirImpl>
    implements _$$OnAirImplCopyWith<$Res> {
  __$$OnAirImplCopyWithImpl(
    _$OnAirImpl _value,
    $Res Function(_$OnAirImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? journey = null,
    Object? station = null,
    Object? playback = null,
    Object? trackTitle = freezed,
  }) {
    return _then(
      _$OnAirImpl(
        null == journey
            ? _value.journey
            : journey // ignore: cast_nullable_to_non_nullable
                  as Journey,
        null == station
            ? _value.station
            : station // ignore: cast_nullable_to_non_nullable
                  as RadioStation,
        playback: null == playback
            ? _value.playback
            : playback // ignore: cast_nullable_to_non_nullable
                  as OnAirPlayback,
        trackTitle: freezed == trackTitle
            ? _value.trackTitle
            : trackTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }

  /// Create a copy of RadioSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RadioStationCopyWith<$Res> get station {
    return $RadioStationCopyWith<$Res>(_value.station, (value) {
      return _then(_value.copyWith(station: value));
    });
  }
}

/// @nodoc

class _$OnAirImpl implements OnAir {
  const _$OnAirImpl(
    this.journey,
    this.station, {
    required this.playback,
    this.trackTitle,
  });

  @override
  final Journey journey;
  @override
  final RadioStation station;
  @override
  final OnAirPlayback playback;
  @override
  final String? trackTitle;

  @override
  String toString() {
    return 'RadioSession.onAir(journey: $journey, station: $station, playback: $playback, trackTitle: $trackTitle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnAirImpl &&
            (identical(other.journey, journey) || other.journey == journey) &&
            (identical(other.station, station) || other.station == station) &&
            (identical(other.playback, playback) ||
                other.playback == playback) &&
            (identical(other.trackTitle, trackTitle) ||
                other.trackTitle == trackTitle));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, journey, station, playback, trackTitle);

  /// Create a copy of RadioSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnAirImplCopyWith<_$OnAirImpl> get copyWith =>
      __$$OnAirImplCopyWithImpl<_$OnAirImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Journey journey) off,
    required TResult Function(
      Journey journey,
      FlightKind kind,
      int attempt,
      bool signalLost,
    )
    flying,
    required TResult Function(
      Journey journey,
      RadioStation station,
      OnAirPlayback playback,
      String? trackTitle,
    )
    onAir,
    required TResult Function(Journey journey) failed,
  }) {
    return onAir(journey, station, playback, trackTitle);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Journey journey)? off,
    TResult? Function(
      Journey journey,
      FlightKind kind,
      int attempt,
      bool signalLost,
    )?
    flying,
    TResult? Function(
      Journey journey,
      RadioStation station,
      OnAirPlayback playback,
      String? trackTitle,
    )?
    onAir,
    TResult? Function(Journey journey)? failed,
  }) {
    return onAir?.call(journey, station, playback, trackTitle);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Journey journey)? off,
    TResult Function(
      Journey journey,
      FlightKind kind,
      int attempt,
      bool signalLost,
    )?
    flying,
    TResult Function(
      Journey journey,
      RadioStation station,
      OnAirPlayback playback,
      String? trackTitle,
    )?
    onAir,
    TResult Function(Journey journey)? failed,
    required TResult orElse(),
  }) {
    if (onAir != null) {
      return onAir(journey, station, playback, trackTitle);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Off value) off,
    required TResult Function(Flying value) flying,
    required TResult Function(OnAir value) onAir,
    required TResult Function(Failed value) failed,
  }) {
    return onAir(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Off value)? off,
    TResult? Function(Flying value)? flying,
    TResult? Function(OnAir value)? onAir,
    TResult? Function(Failed value)? failed,
  }) {
    return onAir?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Off value)? off,
    TResult Function(Flying value)? flying,
    TResult Function(OnAir value)? onAir,
    TResult Function(Failed value)? failed,
    required TResult orElse(),
  }) {
    if (onAir != null) {
      return onAir(this);
    }
    return orElse();
  }
}

abstract class OnAir implements RadioSession {
  const factory OnAir(
    final Journey journey,
    final RadioStation station, {
    required final OnAirPlayback playback,
    final String? trackTitle,
  }) = _$OnAirImpl;

  @override
  Journey get journey;
  RadioStation get station;
  OnAirPlayback get playback;
  String? get trackTitle;

  /// Create a copy of RadioSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnAirImplCopyWith<_$OnAirImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FailedImplCopyWith<$Res>
    implements $RadioSessionCopyWith<$Res> {
  factory _$$FailedImplCopyWith(
    _$FailedImpl value,
    $Res Function(_$FailedImpl) then,
  ) = __$$FailedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Journey journey});

  @override
  $JourneyCopyWith<$Res> get journey;
}

/// @nodoc
class __$$FailedImplCopyWithImpl<$Res>
    extends _$RadioSessionCopyWithImpl<$Res, _$FailedImpl>
    implements _$$FailedImplCopyWith<$Res> {
  __$$FailedImplCopyWithImpl(
    _$FailedImpl _value,
    $Res Function(_$FailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? journey = null}) {
    return _then(
      _$FailedImpl(
        null == journey
            ? _value.journey
            : journey // ignore: cast_nullable_to_non_nullable
                  as Journey,
      ),
    );
  }
}

/// @nodoc

class _$FailedImpl implements Failed {
  const _$FailedImpl(this.journey);

  @override
  final Journey journey;

  @override
  String toString() {
    return 'RadioSession.failed(journey: $journey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FailedImpl &&
            (identical(other.journey, journey) || other.journey == journey));
  }

  @override
  int get hashCode => Object.hash(runtimeType, journey);

  /// Create a copy of RadioSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FailedImplCopyWith<_$FailedImpl> get copyWith =>
      __$$FailedImplCopyWithImpl<_$FailedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Journey journey) off,
    required TResult Function(
      Journey journey,
      FlightKind kind,
      int attempt,
      bool signalLost,
    )
    flying,
    required TResult Function(
      Journey journey,
      RadioStation station,
      OnAirPlayback playback,
      String? trackTitle,
    )
    onAir,
    required TResult Function(Journey journey) failed,
  }) {
    return failed(journey);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Journey journey)? off,
    TResult? Function(
      Journey journey,
      FlightKind kind,
      int attempt,
      bool signalLost,
    )?
    flying,
    TResult? Function(
      Journey journey,
      RadioStation station,
      OnAirPlayback playback,
      String? trackTitle,
    )?
    onAir,
    TResult? Function(Journey journey)? failed,
  }) {
    return failed?.call(journey);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Journey journey)? off,
    TResult Function(
      Journey journey,
      FlightKind kind,
      int attempt,
      bool signalLost,
    )?
    flying,
    TResult Function(
      Journey journey,
      RadioStation station,
      OnAirPlayback playback,
      String? trackTitle,
    )?
    onAir,
    TResult Function(Journey journey)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(journey);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Off value) off,
    required TResult Function(Flying value) flying,
    required TResult Function(OnAir value) onAir,
    required TResult Function(Failed value) failed,
  }) {
    return failed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Off value)? off,
    TResult? Function(Flying value)? flying,
    TResult? Function(OnAir value)? onAir,
    TResult? Function(Failed value)? failed,
  }) {
    return failed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Off value)? off,
    TResult Function(Flying value)? flying,
    TResult Function(OnAir value)? onAir,
    TResult Function(Failed value)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(this);
    }
    return orElse();
  }
}

abstract class Failed implements RadioSession {
  const factory Failed(final Journey journey) = _$FailedImpl;

  @override
  Journey get journey;

  /// Create a copy of RadioSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FailedImplCopyWith<_$FailedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
