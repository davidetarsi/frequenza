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

/// @nodoc
mixin _$RadioEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(FlightKind kind, RadioStation? target)
    flightStarted,
    required TResult Function(bool retrying) attemptFailed,
    required TResult Function() retryStarted,
    required TResult Function(
      RadioStation station,
      bool paused,
      String? trackTitle,
    )
    landed,
    required TResult Function(PlaybackStatus status) playbackChanged,
    required TResult Function(String? title) trackChanged,
    required TResult Function() switchedOff,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(FlightKind kind, RadioStation? target)? flightStarted,
    TResult? Function(bool retrying)? attemptFailed,
    TResult? Function()? retryStarted,
    TResult? Function(RadioStation station, bool paused, String? trackTitle)?
    landed,
    TResult? Function(PlaybackStatus status)? playbackChanged,
    TResult? Function(String? title)? trackChanged,
    TResult? Function()? switchedOff,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(FlightKind kind, RadioStation? target)? flightStarted,
    TResult Function(bool retrying)? attemptFailed,
    TResult Function()? retryStarted,
    TResult Function(RadioStation station, bool paused, String? trackTitle)?
    landed,
    TResult Function(PlaybackStatus status)? playbackChanged,
    TResult Function(String? title)? trackChanged,
    TResult Function()? switchedOff,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FlightStarted value) flightStarted,
    required TResult Function(AttemptFailed value) attemptFailed,
    required TResult Function(RetryStarted value) retryStarted,
    required TResult Function(Landed value) landed,
    required TResult Function(PlaybackChanged value) playbackChanged,
    required TResult Function(TrackChanged value) trackChanged,
    required TResult Function(SwitchedOff value) switchedOff,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FlightStarted value)? flightStarted,
    TResult? Function(AttemptFailed value)? attemptFailed,
    TResult? Function(RetryStarted value)? retryStarted,
    TResult? Function(Landed value)? landed,
    TResult? Function(PlaybackChanged value)? playbackChanged,
    TResult? Function(TrackChanged value)? trackChanged,
    TResult? Function(SwitchedOff value)? switchedOff,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FlightStarted value)? flightStarted,
    TResult Function(AttemptFailed value)? attemptFailed,
    TResult Function(RetryStarted value)? retryStarted,
    TResult Function(Landed value)? landed,
    TResult Function(PlaybackChanged value)? playbackChanged,
    TResult Function(TrackChanged value)? trackChanged,
    TResult Function(SwitchedOff value)? switchedOff,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RadioEventCopyWith<$Res> {
  factory $RadioEventCopyWith(
    RadioEvent value,
    $Res Function(RadioEvent) then,
  ) = _$RadioEventCopyWithImpl<$Res, RadioEvent>;
}

/// @nodoc
class _$RadioEventCopyWithImpl<$Res, $Val extends RadioEvent>
    implements $RadioEventCopyWith<$Res> {
  _$RadioEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$FlightStartedImplCopyWith<$Res> {
  factory _$$FlightStartedImplCopyWith(
    _$FlightStartedImpl value,
    $Res Function(_$FlightStartedImpl) then,
  ) = __$$FlightStartedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({FlightKind kind, RadioStation? target});

  $RadioStationCopyWith<$Res>? get target;
}

/// @nodoc
class __$$FlightStartedImplCopyWithImpl<$Res>
    extends _$RadioEventCopyWithImpl<$Res, _$FlightStartedImpl>
    implements _$$FlightStartedImplCopyWith<$Res> {
  __$$FlightStartedImplCopyWithImpl(
    _$FlightStartedImpl _value,
    $Res Function(_$FlightStartedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? kind = null, Object? target = freezed}) {
    return _then(
      _$FlightStartedImpl(
        null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as FlightKind,
        target: freezed == target
            ? _value.target
            : target // ignore: cast_nullable_to_non_nullable
                  as RadioStation?,
      ),
    );
  }

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RadioStationCopyWith<$Res>? get target {
    if (_value.target == null) {
      return null;
    }

    return $RadioStationCopyWith<$Res>(_value.target!, (value) {
      return _then(_value.copyWith(target: value));
    });
  }
}

/// @nodoc

class _$FlightStartedImpl implements FlightStarted {
  const _$FlightStartedImpl(this.kind, {this.target});

  @override
  final FlightKind kind;
  @override
  final RadioStation? target;

  @override
  String toString() {
    return 'RadioEvent.flightStarted(kind: $kind, target: $target)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlightStartedImpl &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.target, target) || other.target == target));
  }

  @override
  int get hashCode => Object.hash(runtimeType, kind, target);

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlightStartedImplCopyWith<_$FlightStartedImpl> get copyWith =>
      __$$FlightStartedImplCopyWithImpl<_$FlightStartedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(FlightKind kind, RadioStation? target)
    flightStarted,
    required TResult Function(bool retrying) attemptFailed,
    required TResult Function() retryStarted,
    required TResult Function(
      RadioStation station,
      bool paused,
      String? trackTitle,
    )
    landed,
    required TResult Function(PlaybackStatus status) playbackChanged,
    required TResult Function(String? title) trackChanged,
    required TResult Function() switchedOff,
  }) {
    return flightStarted(kind, target);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(FlightKind kind, RadioStation? target)? flightStarted,
    TResult? Function(bool retrying)? attemptFailed,
    TResult? Function()? retryStarted,
    TResult? Function(RadioStation station, bool paused, String? trackTitle)?
    landed,
    TResult? Function(PlaybackStatus status)? playbackChanged,
    TResult? Function(String? title)? trackChanged,
    TResult? Function()? switchedOff,
  }) {
    return flightStarted?.call(kind, target);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(FlightKind kind, RadioStation? target)? flightStarted,
    TResult Function(bool retrying)? attemptFailed,
    TResult Function()? retryStarted,
    TResult Function(RadioStation station, bool paused, String? trackTitle)?
    landed,
    TResult Function(PlaybackStatus status)? playbackChanged,
    TResult Function(String? title)? trackChanged,
    TResult Function()? switchedOff,
    required TResult orElse(),
  }) {
    if (flightStarted != null) {
      return flightStarted(kind, target);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FlightStarted value) flightStarted,
    required TResult Function(AttemptFailed value) attemptFailed,
    required TResult Function(RetryStarted value) retryStarted,
    required TResult Function(Landed value) landed,
    required TResult Function(PlaybackChanged value) playbackChanged,
    required TResult Function(TrackChanged value) trackChanged,
    required TResult Function(SwitchedOff value) switchedOff,
  }) {
    return flightStarted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FlightStarted value)? flightStarted,
    TResult? Function(AttemptFailed value)? attemptFailed,
    TResult? Function(RetryStarted value)? retryStarted,
    TResult? Function(Landed value)? landed,
    TResult? Function(PlaybackChanged value)? playbackChanged,
    TResult? Function(TrackChanged value)? trackChanged,
    TResult? Function(SwitchedOff value)? switchedOff,
  }) {
    return flightStarted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FlightStarted value)? flightStarted,
    TResult Function(AttemptFailed value)? attemptFailed,
    TResult Function(RetryStarted value)? retryStarted,
    TResult Function(Landed value)? landed,
    TResult Function(PlaybackChanged value)? playbackChanged,
    TResult Function(TrackChanged value)? trackChanged,
    TResult Function(SwitchedOff value)? switchedOff,
    required TResult orElse(),
  }) {
    if (flightStarted != null) {
      return flightStarted(this);
    }
    return orElse();
  }
}

abstract class FlightStarted implements RadioEvent {
  const factory FlightStarted(
    final FlightKind kind, {
    final RadioStation? target,
  }) = _$FlightStartedImpl;

  FlightKind get kind;
  RadioStation? get target;

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlightStartedImplCopyWith<_$FlightStartedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AttemptFailedImplCopyWith<$Res> {
  factory _$$AttemptFailedImplCopyWith(
    _$AttemptFailedImpl value,
    $Res Function(_$AttemptFailedImpl) then,
  ) = __$$AttemptFailedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({bool retrying});
}

/// @nodoc
class __$$AttemptFailedImplCopyWithImpl<$Res>
    extends _$RadioEventCopyWithImpl<$Res, _$AttemptFailedImpl>
    implements _$$AttemptFailedImplCopyWith<$Res> {
  __$$AttemptFailedImplCopyWithImpl(
    _$AttemptFailedImpl _value,
    $Res Function(_$AttemptFailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? retrying = null}) {
    return _then(
      _$AttemptFailedImpl(
        retrying: null == retrying
            ? _value.retrying
            : retrying // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$AttemptFailedImpl implements AttemptFailed {
  const _$AttemptFailedImpl({required this.retrying});

  @override
  final bool retrying;

  @override
  String toString() {
    return 'RadioEvent.attemptFailed(retrying: $retrying)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttemptFailedImpl &&
            (identical(other.retrying, retrying) ||
                other.retrying == retrying));
  }

  @override
  int get hashCode => Object.hash(runtimeType, retrying);

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttemptFailedImplCopyWith<_$AttemptFailedImpl> get copyWith =>
      __$$AttemptFailedImplCopyWithImpl<_$AttemptFailedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(FlightKind kind, RadioStation? target)
    flightStarted,
    required TResult Function(bool retrying) attemptFailed,
    required TResult Function() retryStarted,
    required TResult Function(
      RadioStation station,
      bool paused,
      String? trackTitle,
    )
    landed,
    required TResult Function(PlaybackStatus status) playbackChanged,
    required TResult Function(String? title) trackChanged,
    required TResult Function() switchedOff,
  }) {
    return attemptFailed(retrying);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(FlightKind kind, RadioStation? target)? flightStarted,
    TResult? Function(bool retrying)? attemptFailed,
    TResult? Function()? retryStarted,
    TResult? Function(RadioStation station, bool paused, String? trackTitle)?
    landed,
    TResult? Function(PlaybackStatus status)? playbackChanged,
    TResult? Function(String? title)? trackChanged,
    TResult? Function()? switchedOff,
  }) {
    return attemptFailed?.call(retrying);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(FlightKind kind, RadioStation? target)? flightStarted,
    TResult Function(bool retrying)? attemptFailed,
    TResult Function()? retryStarted,
    TResult Function(RadioStation station, bool paused, String? trackTitle)?
    landed,
    TResult Function(PlaybackStatus status)? playbackChanged,
    TResult Function(String? title)? trackChanged,
    TResult Function()? switchedOff,
    required TResult orElse(),
  }) {
    if (attemptFailed != null) {
      return attemptFailed(retrying);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FlightStarted value) flightStarted,
    required TResult Function(AttemptFailed value) attemptFailed,
    required TResult Function(RetryStarted value) retryStarted,
    required TResult Function(Landed value) landed,
    required TResult Function(PlaybackChanged value) playbackChanged,
    required TResult Function(TrackChanged value) trackChanged,
    required TResult Function(SwitchedOff value) switchedOff,
  }) {
    return attemptFailed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FlightStarted value)? flightStarted,
    TResult? Function(AttemptFailed value)? attemptFailed,
    TResult? Function(RetryStarted value)? retryStarted,
    TResult? Function(Landed value)? landed,
    TResult? Function(PlaybackChanged value)? playbackChanged,
    TResult? Function(TrackChanged value)? trackChanged,
    TResult? Function(SwitchedOff value)? switchedOff,
  }) {
    return attemptFailed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FlightStarted value)? flightStarted,
    TResult Function(AttemptFailed value)? attemptFailed,
    TResult Function(RetryStarted value)? retryStarted,
    TResult Function(Landed value)? landed,
    TResult Function(PlaybackChanged value)? playbackChanged,
    TResult Function(TrackChanged value)? trackChanged,
    TResult Function(SwitchedOff value)? switchedOff,
    required TResult orElse(),
  }) {
    if (attemptFailed != null) {
      return attemptFailed(this);
    }
    return orElse();
  }
}

abstract class AttemptFailed implements RadioEvent {
  const factory AttemptFailed({required final bool retrying}) =
      _$AttemptFailedImpl;

  bool get retrying;

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttemptFailedImplCopyWith<_$AttemptFailedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RetryStartedImplCopyWith<$Res> {
  factory _$$RetryStartedImplCopyWith(
    _$RetryStartedImpl value,
    $Res Function(_$RetryStartedImpl) then,
  ) = __$$RetryStartedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RetryStartedImplCopyWithImpl<$Res>
    extends _$RadioEventCopyWithImpl<$Res, _$RetryStartedImpl>
    implements _$$RetryStartedImplCopyWith<$Res> {
  __$$RetryStartedImplCopyWithImpl(
    _$RetryStartedImpl _value,
    $Res Function(_$RetryStartedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RetryStartedImpl implements RetryStarted {
  const _$RetryStartedImpl();

  @override
  String toString() {
    return 'RadioEvent.retryStarted()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RetryStartedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(FlightKind kind, RadioStation? target)
    flightStarted,
    required TResult Function(bool retrying) attemptFailed,
    required TResult Function() retryStarted,
    required TResult Function(
      RadioStation station,
      bool paused,
      String? trackTitle,
    )
    landed,
    required TResult Function(PlaybackStatus status) playbackChanged,
    required TResult Function(String? title) trackChanged,
    required TResult Function() switchedOff,
  }) {
    return retryStarted();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(FlightKind kind, RadioStation? target)? flightStarted,
    TResult? Function(bool retrying)? attemptFailed,
    TResult? Function()? retryStarted,
    TResult? Function(RadioStation station, bool paused, String? trackTitle)?
    landed,
    TResult? Function(PlaybackStatus status)? playbackChanged,
    TResult? Function(String? title)? trackChanged,
    TResult? Function()? switchedOff,
  }) {
    return retryStarted?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(FlightKind kind, RadioStation? target)? flightStarted,
    TResult Function(bool retrying)? attemptFailed,
    TResult Function()? retryStarted,
    TResult Function(RadioStation station, bool paused, String? trackTitle)?
    landed,
    TResult Function(PlaybackStatus status)? playbackChanged,
    TResult Function(String? title)? trackChanged,
    TResult Function()? switchedOff,
    required TResult orElse(),
  }) {
    if (retryStarted != null) {
      return retryStarted();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FlightStarted value) flightStarted,
    required TResult Function(AttemptFailed value) attemptFailed,
    required TResult Function(RetryStarted value) retryStarted,
    required TResult Function(Landed value) landed,
    required TResult Function(PlaybackChanged value) playbackChanged,
    required TResult Function(TrackChanged value) trackChanged,
    required TResult Function(SwitchedOff value) switchedOff,
  }) {
    return retryStarted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FlightStarted value)? flightStarted,
    TResult? Function(AttemptFailed value)? attemptFailed,
    TResult? Function(RetryStarted value)? retryStarted,
    TResult? Function(Landed value)? landed,
    TResult? Function(PlaybackChanged value)? playbackChanged,
    TResult? Function(TrackChanged value)? trackChanged,
    TResult? Function(SwitchedOff value)? switchedOff,
  }) {
    return retryStarted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FlightStarted value)? flightStarted,
    TResult Function(AttemptFailed value)? attemptFailed,
    TResult Function(RetryStarted value)? retryStarted,
    TResult Function(Landed value)? landed,
    TResult Function(PlaybackChanged value)? playbackChanged,
    TResult Function(TrackChanged value)? trackChanged,
    TResult Function(SwitchedOff value)? switchedOff,
    required TResult orElse(),
  }) {
    if (retryStarted != null) {
      return retryStarted(this);
    }
    return orElse();
  }
}

abstract class RetryStarted implements RadioEvent {
  const factory RetryStarted() = _$RetryStartedImpl;
}

/// @nodoc
abstract class _$$LandedImplCopyWith<$Res> {
  factory _$$LandedImplCopyWith(
    _$LandedImpl value,
    $Res Function(_$LandedImpl) then,
  ) = __$$LandedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({RadioStation station, bool paused, String? trackTitle});

  $RadioStationCopyWith<$Res> get station;
}

/// @nodoc
class __$$LandedImplCopyWithImpl<$Res>
    extends _$RadioEventCopyWithImpl<$Res, _$LandedImpl>
    implements _$$LandedImplCopyWith<$Res> {
  __$$LandedImplCopyWithImpl(
    _$LandedImpl _value,
    $Res Function(_$LandedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? station = null,
    Object? paused = null,
    Object? trackTitle = freezed,
  }) {
    return _then(
      _$LandedImpl(
        null == station
            ? _value.station
            : station // ignore: cast_nullable_to_non_nullable
                  as RadioStation,
        paused: null == paused
            ? _value.paused
            : paused // ignore: cast_nullable_to_non_nullable
                  as bool,
        trackTitle: freezed == trackTitle
            ? _value.trackTitle
            : trackTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }

  /// Create a copy of RadioEvent
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

class _$LandedImpl implements Landed {
  const _$LandedImpl(this.station, {required this.paused, this.trackTitle});

  @override
  final RadioStation station;
  @override
  final bool paused;
  @override
  final String? trackTitle;

  @override
  String toString() {
    return 'RadioEvent.landed(station: $station, paused: $paused, trackTitle: $trackTitle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LandedImpl &&
            (identical(other.station, station) || other.station == station) &&
            (identical(other.paused, paused) || other.paused == paused) &&
            (identical(other.trackTitle, trackTitle) ||
                other.trackTitle == trackTitle));
  }

  @override
  int get hashCode => Object.hash(runtimeType, station, paused, trackTitle);

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LandedImplCopyWith<_$LandedImpl> get copyWith =>
      __$$LandedImplCopyWithImpl<_$LandedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(FlightKind kind, RadioStation? target)
    flightStarted,
    required TResult Function(bool retrying) attemptFailed,
    required TResult Function() retryStarted,
    required TResult Function(
      RadioStation station,
      bool paused,
      String? trackTitle,
    )
    landed,
    required TResult Function(PlaybackStatus status) playbackChanged,
    required TResult Function(String? title) trackChanged,
    required TResult Function() switchedOff,
  }) {
    return landed(station, paused, trackTitle);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(FlightKind kind, RadioStation? target)? flightStarted,
    TResult? Function(bool retrying)? attemptFailed,
    TResult? Function()? retryStarted,
    TResult? Function(RadioStation station, bool paused, String? trackTitle)?
    landed,
    TResult? Function(PlaybackStatus status)? playbackChanged,
    TResult? Function(String? title)? trackChanged,
    TResult? Function()? switchedOff,
  }) {
    return landed?.call(station, paused, trackTitle);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(FlightKind kind, RadioStation? target)? flightStarted,
    TResult Function(bool retrying)? attemptFailed,
    TResult Function()? retryStarted,
    TResult Function(RadioStation station, bool paused, String? trackTitle)?
    landed,
    TResult Function(PlaybackStatus status)? playbackChanged,
    TResult Function(String? title)? trackChanged,
    TResult Function()? switchedOff,
    required TResult orElse(),
  }) {
    if (landed != null) {
      return landed(station, paused, trackTitle);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FlightStarted value) flightStarted,
    required TResult Function(AttemptFailed value) attemptFailed,
    required TResult Function(RetryStarted value) retryStarted,
    required TResult Function(Landed value) landed,
    required TResult Function(PlaybackChanged value) playbackChanged,
    required TResult Function(TrackChanged value) trackChanged,
    required TResult Function(SwitchedOff value) switchedOff,
  }) {
    return landed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FlightStarted value)? flightStarted,
    TResult? Function(AttemptFailed value)? attemptFailed,
    TResult? Function(RetryStarted value)? retryStarted,
    TResult? Function(Landed value)? landed,
    TResult? Function(PlaybackChanged value)? playbackChanged,
    TResult? Function(TrackChanged value)? trackChanged,
    TResult? Function(SwitchedOff value)? switchedOff,
  }) {
    return landed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FlightStarted value)? flightStarted,
    TResult Function(AttemptFailed value)? attemptFailed,
    TResult Function(RetryStarted value)? retryStarted,
    TResult Function(Landed value)? landed,
    TResult Function(PlaybackChanged value)? playbackChanged,
    TResult Function(TrackChanged value)? trackChanged,
    TResult Function(SwitchedOff value)? switchedOff,
    required TResult orElse(),
  }) {
    if (landed != null) {
      return landed(this);
    }
    return orElse();
  }
}

abstract class Landed implements RadioEvent {
  const factory Landed(
    final RadioStation station, {
    required final bool paused,
    final String? trackTitle,
  }) = _$LandedImpl;

  RadioStation get station;
  bool get paused;
  String? get trackTitle;

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LandedImplCopyWith<_$LandedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PlaybackChangedImplCopyWith<$Res> {
  factory _$$PlaybackChangedImplCopyWith(
    _$PlaybackChangedImpl value,
    $Res Function(_$PlaybackChangedImpl) then,
  ) = __$$PlaybackChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({PlaybackStatus status});
}

/// @nodoc
class __$$PlaybackChangedImplCopyWithImpl<$Res>
    extends _$RadioEventCopyWithImpl<$Res, _$PlaybackChangedImpl>
    implements _$$PlaybackChangedImplCopyWith<$Res> {
  __$$PlaybackChangedImplCopyWithImpl(
    _$PlaybackChangedImpl _value,
    $Res Function(_$PlaybackChangedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? status = null}) {
    return _then(
      _$PlaybackChangedImpl(
        null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PlaybackStatus,
      ),
    );
  }
}

/// @nodoc

class _$PlaybackChangedImpl implements PlaybackChanged {
  const _$PlaybackChangedImpl(this.status);

  @override
  final PlaybackStatus status;

  @override
  String toString() {
    return 'RadioEvent.playbackChanged(status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaybackChangedImpl &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status);

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaybackChangedImplCopyWith<_$PlaybackChangedImpl> get copyWith =>
      __$$PlaybackChangedImplCopyWithImpl<_$PlaybackChangedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(FlightKind kind, RadioStation? target)
    flightStarted,
    required TResult Function(bool retrying) attemptFailed,
    required TResult Function() retryStarted,
    required TResult Function(
      RadioStation station,
      bool paused,
      String? trackTitle,
    )
    landed,
    required TResult Function(PlaybackStatus status) playbackChanged,
    required TResult Function(String? title) trackChanged,
    required TResult Function() switchedOff,
  }) {
    return playbackChanged(status);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(FlightKind kind, RadioStation? target)? flightStarted,
    TResult? Function(bool retrying)? attemptFailed,
    TResult? Function()? retryStarted,
    TResult? Function(RadioStation station, bool paused, String? trackTitle)?
    landed,
    TResult? Function(PlaybackStatus status)? playbackChanged,
    TResult? Function(String? title)? trackChanged,
    TResult? Function()? switchedOff,
  }) {
    return playbackChanged?.call(status);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(FlightKind kind, RadioStation? target)? flightStarted,
    TResult Function(bool retrying)? attemptFailed,
    TResult Function()? retryStarted,
    TResult Function(RadioStation station, bool paused, String? trackTitle)?
    landed,
    TResult Function(PlaybackStatus status)? playbackChanged,
    TResult Function(String? title)? trackChanged,
    TResult Function()? switchedOff,
    required TResult orElse(),
  }) {
    if (playbackChanged != null) {
      return playbackChanged(status);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FlightStarted value) flightStarted,
    required TResult Function(AttemptFailed value) attemptFailed,
    required TResult Function(RetryStarted value) retryStarted,
    required TResult Function(Landed value) landed,
    required TResult Function(PlaybackChanged value) playbackChanged,
    required TResult Function(TrackChanged value) trackChanged,
    required TResult Function(SwitchedOff value) switchedOff,
  }) {
    return playbackChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FlightStarted value)? flightStarted,
    TResult? Function(AttemptFailed value)? attemptFailed,
    TResult? Function(RetryStarted value)? retryStarted,
    TResult? Function(Landed value)? landed,
    TResult? Function(PlaybackChanged value)? playbackChanged,
    TResult? Function(TrackChanged value)? trackChanged,
    TResult? Function(SwitchedOff value)? switchedOff,
  }) {
    return playbackChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FlightStarted value)? flightStarted,
    TResult Function(AttemptFailed value)? attemptFailed,
    TResult Function(RetryStarted value)? retryStarted,
    TResult Function(Landed value)? landed,
    TResult Function(PlaybackChanged value)? playbackChanged,
    TResult Function(TrackChanged value)? trackChanged,
    TResult Function(SwitchedOff value)? switchedOff,
    required TResult orElse(),
  }) {
    if (playbackChanged != null) {
      return playbackChanged(this);
    }
    return orElse();
  }
}

abstract class PlaybackChanged implements RadioEvent {
  const factory PlaybackChanged(final PlaybackStatus status) =
      _$PlaybackChangedImpl;

  PlaybackStatus get status;

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaybackChangedImplCopyWith<_$PlaybackChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TrackChangedImplCopyWith<$Res> {
  factory _$$TrackChangedImplCopyWith(
    _$TrackChangedImpl value,
    $Res Function(_$TrackChangedImpl) then,
  ) = __$$TrackChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String? title});
}

/// @nodoc
class __$$TrackChangedImplCopyWithImpl<$Res>
    extends _$RadioEventCopyWithImpl<$Res, _$TrackChangedImpl>
    implements _$$TrackChangedImplCopyWith<$Res> {
  __$$TrackChangedImplCopyWithImpl(
    _$TrackChangedImpl _value,
    $Res Function(_$TrackChangedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? title = freezed}) {
    return _then(
      _$TrackChangedImpl(
        freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$TrackChangedImpl implements TrackChanged {
  const _$TrackChangedImpl(this.title);

  @override
  final String? title;

  @override
  String toString() {
    return 'RadioEvent.trackChanged(title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackChangedImpl &&
            (identical(other.title, title) || other.title == title));
  }

  @override
  int get hashCode => Object.hash(runtimeType, title);

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackChangedImplCopyWith<_$TrackChangedImpl> get copyWith =>
      __$$TrackChangedImplCopyWithImpl<_$TrackChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(FlightKind kind, RadioStation? target)
    flightStarted,
    required TResult Function(bool retrying) attemptFailed,
    required TResult Function() retryStarted,
    required TResult Function(
      RadioStation station,
      bool paused,
      String? trackTitle,
    )
    landed,
    required TResult Function(PlaybackStatus status) playbackChanged,
    required TResult Function(String? title) trackChanged,
    required TResult Function() switchedOff,
  }) {
    return trackChanged(title);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(FlightKind kind, RadioStation? target)? flightStarted,
    TResult? Function(bool retrying)? attemptFailed,
    TResult? Function()? retryStarted,
    TResult? Function(RadioStation station, bool paused, String? trackTitle)?
    landed,
    TResult? Function(PlaybackStatus status)? playbackChanged,
    TResult? Function(String? title)? trackChanged,
    TResult? Function()? switchedOff,
  }) {
    return trackChanged?.call(title);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(FlightKind kind, RadioStation? target)? flightStarted,
    TResult Function(bool retrying)? attemptFailed,
    TResult Function()? retryStarted,
    TResult Function(RadioStation station, bool paused, String? trackTitle)?
    landed,
    TResult Function(PlaybackStatus status)? playbackChanged,
    TResult Function(String? title)? trackChanged,
    TResult Function()? switchedOff,
    required TResult orElse(),
  }) {
    if (trackChanged != null) {
      return trackChanged(title);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FlightStarted value) flightStarted,
    required TResult Function(AttemptFailed value) attemptFailed,
    required TResult Function(RetryStarted value) retryStarted,
    required TResult Function(Landed value) landed,
    required TResult Function(PlaybackChanged value) playbackChanged,
    required TResult Function(TrackChanged value) trackChanged,
    required TResult Function(SwitchedOff value) switchedOff,
  }) {
    return trackChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FlightStarted value)? flightStarted,
    TResult? Function(AttemptFailed value)? attemptFailed,
    TResult? Function(RetryStarted value)? retryStarted,
    TResult? Function(Landed value)? landed,
    TResult? Function(PlaybackChanged value)? playbackChanged,
    TResult? Function(TrackChanged value)? trackChanged,
    TResult? Function(SwitchedOff value)? switchedOff,
  }) {
    return trackChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FlightStarted value)? flightStarted,
    TResult Function(AttemptFailed value)? attemptFailed,
    TResult Function(RetryStarted value)? retryStarted,
    TResult Function(Landed value)? landed,
    TResult Function(PlaybackChanged value)? playbackChanged,
    TResult Function(TrackChanged value)? trackChanged,
    TResult Function(SwitchedOff value)? switchedOff,
    required TResult orElse(),
  }) {
    if (trackChanged != null) {
      return trackChanged(this);
    }
    return orElse();
  }
}

abstract class TrackChanged implements RadioEvent {
  const factory TrackChanged(final String? title) = _$TrackChangedImpl;

  String? get title;

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackChangedImplCopyWith<_$TrackChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SwitchedOffImplCopyWith<$Res> {
  factory _$$SwitchedOffImplCopyWith(
    _$SwitchedOffImpl value,
    $Res Function(_$SwitchedOffImpl) then,
  ) = __$$SwitchedOffImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SwitchedOffImplCopyWithImpl<$Res>
    extends _$RadioEventCopyWithImpl<$Res, _$SwitchedOffImpl>
    implements _$$SwitchedOffImplCopyWith<$Res> {
  __$$SwitchedOffImplCopyWithImpl(
    _$SwitchedOffImpl _value,
    $Res Function(_$SwitchedOffImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SwitchedOffImpl implements SwitchedOff {
  const _$SwitchedOffImpl();

  @override
  String toString() {
    return 'RadioEvent.switchedOff()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SwitchedOffImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(FlightKind kind, RadioStation? target)
    flightStarted,
    required TResult Function(bool retrying) attemptFailed,
    required TResult Function() retryStarted,
    required TResult Function(
      RadioStation station,
      bool paused,
      String? trackTitle,
    )
    landed,
    required TResult Function(PlaybackStatus status) playbackChanged,
    required TResult Function(String? title) trackChanged,
    required TResult Function() switchedOff,
  }) {
    return switchedOff();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(FlightKind kind, RadioStation? target)? flightStarted,
    TResult? Function(bool retrying)? attemptFailed,
    TResult? Function()? retryStarted,
    TResult? Function(RadioStation station, bool paused, String? trackTitle)?
    landed,
    TResult? Function(PlaybackStatus status)? playbackChanged,
    TResult? Function(String? title)? trackChanged,
    TResult? Function()? switchedOff,
  }) {
    return switchedOff?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(FlightKind kind, RadioStation? target)? flightStarted,
    TResult Function(bool retrying)? attemptFailed,
    TResult Function()? retryStarted,
    TResult Function(RadioStation station, bool paused, String? trackTitle)?
    landed,
    TResult Function(PlaybackStatus status)? playbackChanged,
    TResult Function(String? title)? trackChanged,
    TResult Function()? switchedOff,
    required TResult orElse(),
  }) {
    if (switchedOff != null) {
      return switchedOff();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FlightStarted value) flightStarted,
    required TResult Function(AttemptFailed value) attemptFailed,
    required TResult Function(RetryStarted value) retryStarted,
    required TResult Function(Landed value) landed,
    required TResult Function(PlaybackChanged value) playbackChanged,
    required TResult Function(TrackChanged value) trackChanged,
    required TResult Function(SwitchedOff value) switchedOff,
  }) {
    return switchedOff(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FlightStarted value)? flightStarted,
    TResult? Function(AttemptFailed value)? attemptFailed,
    TResult? Function(RetryStarted value)? retryStarted,
    TResult? Function(Landed value)? landed,
    TResult? Function(PlaybackChanged value)? playbackChanged,
    TResult? Function(TrackChanged value)? trackChanged,
    TResult? Function(SwitchedOff value)? switchedOff,
  }) {
    return switchedOff?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FlightStarted value)? flightStarted,
    TResult Function(AttemptFailed value)? attemptFailed,
    TResult Function(RetryStarted value)? retryStarted,
    TResult Function(Landed value)? landed,
    TResult Function(PlaybackChanged value)? playbackChanged,
    TResult Function(TrackChanged value)? trackChanged,
    TResult Function(SwitchedOff value)? switchedOff,
    required TResult orElse(),
  }) {
    if (switchedOff != null) {
      return switchedOff(this);
    }
    return orElse();
  }
}

abstract class SwitchedOff implements RadioEvent {
  const factory SwitchedOff() = _$SwitchedOffImpl;
}
