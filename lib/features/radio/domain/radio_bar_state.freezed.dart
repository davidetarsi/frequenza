// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'radio_bar_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RadioBarState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() hidden,
    required TResult Function() flying,
    required TResult Function(
      RadioStation station,
      TrackTitle? track,
      bool playing,
      bool connecting,
    )
    onAir,
    required TResult Function() failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? hidden,
    TResult? Function()? flying,
    TResult? Function(
      RadioStation station,
      TrackTitle? track,
      bool playing,
      bool connecting,
    )?
    onAir,
    TResult? Function()? failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? hidden,
    TResult Function()? flying,
    TResult Function(
      RadioStation station,
      TrackTitle? track,
      bool playing,
      bool connecting,
    )?
    onAir,
    TResult Function()? failed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BarHidden value) hidden,
    required TResult Function(BarFlying value) flying,
    required TResult Function(BarOnAir value) onAir,
    required TResult Function(BarFailed value) failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BarHidden value)? hidden,
    TResult? Function(BarFlying value)? flying,
    TResult? Function(BarOnAir value)? onAir,
    TResult? Function(BarFailed value)? failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BarHidden value)? hidden,
    TResult Function(BarFlying value)? flying,
    TResult Function(BarOnAir value)? onAir,
    TResult Function(BarFailed value)? failed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RadioBarStateCopyWith<$Res> {
  factory $RadioBarStateCopyWith(
    RadioBarState value,
    $Res Function(RadioBarState) then,
  ) = _$RadioBarStateCopyWithImpl<$Res, RadioBarState>;
}

/// @nodoc
class _$RadioBarStateCopyWithImpl<$Res, $Val extends RadioBarState>
    implements $RadioBarStateCopyWith<$Res> {
  _$RadioBarStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$BarHiddenImplCopyWith<$Res> {
  factory _$$BarHiddenImplCopyWith(
    _$BarHiddenImpl value,
    $Res Function(_$BarHiddenImpl) then,
  ) = __$$BarHiddenImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BarHiddenImplCopyWithImpl<$Res>
    extends _$RadioBarStateCopyWithImpl<$Res, _$BarHiddenImpl>
    implements _$$BarHiddenImplCopyWith<$Res> {
  __$$BarHiddenImplCopyWithImpl(
    _$BarHiddenImpl _value,
    $Res Function(_$BarHiddenImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$BarHiddenImpl implements BarHidden {
  const _$BarHiddenImpl();

  @override
  String toString() {
    return 'RadioBarState.hidden()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$BarHiddenImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() hidden,
    required TResult Function() flying,
    required TResult Function(
      RadioStation station,
      TrackTitle? track,
      bool playing,
      bool connecting,
    )
    onAir,
    required TResult Function() failed,
  }) {
    return hidden();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? hidden,
    TResult? Function()? flying,
    TResult? Function(
      RadioStation station,
      TrackTitle? track,
      bool playing,
      bool connecting,
    )?
    onAir,
    TResult? Function()? failed,
  }) {
    return hidden?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? hidden,
    TResult Function()? flying,
    TResult Function(
      RadioStation station,
      TrackTitle? track,
      bool playing,
      bool connecting,
    )?
    onAir,
    TResult Function()? failed,
    required TResult orElse(),
  }) {
    if (hidden != null) {
      return hidden();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BarHidden value) hidden,
    required TResult Function(BarFlying value) flying,
    required TResult Function(BarOnAir value) onAir,
    required TResult Function(BarFailed value) failed,
  }) {
    return hidden(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BarHidden value)? hidden,
    TResult? Function(BarFlying value)? flying,
    TResult? Function(BarOnAir value)? onAir,
    TResult? Function(BarFailed value)? failed,
  }) {
    return hidden?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BarHidden value)? hidden,
    TResult Function(BarFlying value)? flying,
    TResult Function(BarOnAir value)? onAir,
    TResult Function(BarFailed value)? failed,
    required TResult orElse(),
  }) {
    if (hidden != null) {
      return hidden(this);
    }
    return orElse();
  }
}

abstract class BarHidden implements RadioBarState {
  const factory BarHidden() = _$BarHiddenImpl;
}

/// @nodoc
abstract class _$$BarFlyingImplCopyWith<$Res> {
  factory _$$BarFlyingImplCopyWith(
    _$BarFlyingImpl value,
    $Res Function(_$BarFlyingImpl) then,
  ) = __$$BarFlyingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BarFlyingImplCopyWithImpl<$Res>
    extends _$RadioBarStateCopyWithImpl<$Res, _$BarFlyingImpl>
    implements _$$BarFlyingImplCopyWith<$Res> {
  __$$BarFlyingImplCopyWithImpl(
    _$BarFlyingImpl _value,
    $Res Function(_$BarFlyingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$BarFlyingImpl implements BarFlying {
  const _$BarFlyingImpl();

  @override
  String toString() {
    return 'RadioBarState.flying()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$BarFlyingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() hidden,
    required TResult Function() flying,
    required TResult Function(
      RadioStation station,
      TrackTitle? track,
      bool playing,
      bool connecting,
    )
    onAir,
    required TResult Function() failed,
  }) {
    return flying();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? hidden,
    TResult? Function()? flying,
    TResult? Function(
      RadioStation station,
      TrackTitle? track,
      bool playing,
      bool connecting,
    )?
    onAir,
    TResult? Function()? failed,
  }) {
    return flying?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? hidden,
    TResult Function()? flying,
    TResult Function(
      RadioStation station,
      TrackTitle? track,
      bool playing,
      bool connecting,
    )?
    onAir,
    TResult Function()? failed,
    required TResult orElse(),
  }) {
    if (flying != null) {
      return flying();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BarHidden value) hidden,
    required TResult Function(BarFlying value) flying,
    required TResult Function(BarOnAir value) onAir,
    required TResult Function(BarFailed value) failed,
  }) {
    return flying(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BarHidden value)? hidden,
    TResult? Function(BarFlying value)? flying,
    TResult? Function(BarOnAir value)? onAir,
    TResult? Function(BarFailed value)? failed,
  }) {
    return flying?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BarHidden value)? hidden,
    TResult Function(BarFlying value)? flying,
    TResult Function(BarOnAir value)? onAir,
    TResult Function(BarFailed value)? failed,
    required TResult orElse(),
  }) {
    if (flying != null) {
      return flying(this);
    }
    return orElse();
  }
}

abstract class BarFlying implements RadioBarState {
  const factory BarFlying() = _$BarFlyingImpl;
}

/// @nodoc
abstract class _$$BarOnAirImplCopyWith<$Res> {
  factory _$$BarOnAirImplCopyWith(
    _$BarOnAirImpl value,
    $Res Function(_$BarOnAirImpl) then,
  ) = __$$BarOnAirImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    RadioStation station,
    TrackTitle? track,
    bool playing,
    bool connecting,
  });

  $RadioStationCopyWith<$Res> get station;
}

/// @nodoc
class __$$BarOnAirImplCopyWithImpl<$Res>
    extends _$RadioBarStateCopyWithImpl<$Res, _$BarOnAirImpl>
    implements _$$BarOnAirImplCopyWith<$Res> {
  __$$BarOnAirImplCopyWithImpl(
    _$BarOnAirImpl _value,
    $Res Function(_$BarOnAirImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? station = null,
    Object? track = freezed,
    Object? playing = null,
    Object? connecting = null,
  }) {
    return _then(
      _$BarOnAirImpl(
        null == station
            ? _value.station
            : station // ignore: cast_nullable_to_non_nullable
                  as RadioStation,
        track: freezed == track
            ? _value.track
            : track // ignore: cast_nullable_to_non_nullable
                  as TrackTitle?,
        playing: null == playing
            ? _value.playing
            : playing // ignore: cast_nullable_to_non_nullable
                  as bool,
        connecting: null == connecting
            ? _value.connecting
            : connecting // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }

  /// Create a copy of RadioBarState
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

class _$BarOnAirImpl implements BarOnAir {
  const _$BarOnAirImpl(
    this.station, {
    this.track,
    required this.playing,
    required this.connecting,
  });

  @override
  final RadioStation station;
  @override
  final TrackTitle? track;
  @override
  final bool playing;
  @override
  final bool connecting;

  @override
  String toString() {
    return 'RadioBarState.onAir(station: $station, track: $track, playing: $playing, connecting: $connecting)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BarOnAirImpl &&
            (identical(other.station, station) || other.station == station) &&
            (identical(other.track, track) || other.track == track) &&
            (identical(other.playing, playing) || other.playing == playing) &&
            (identical(other.connecting, connecting) ||
                other.connecting == connecting));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, station, track, playing, connecting);

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BarOnAirImplCopyWith<_$BarOnAirImpl> get copyWith =>
      __$$BarOnAirImplCopyWithImpl<_$BarOnAirImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() hidden,
    required TResult Function() flying,
    required TResult Function(
      RadioStation station,
      TrackTitle? track,
      bool playing,
      bool connecting,
    )
    onAir,
    required TResult Function() failed,
  }) {
    return onAir(station, track, playing, connecting);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? hidden,
    TResult? Function()? flying,
    TResult? Function(
      RadioStation station,
      TrackTitle? track,
      bool playing,
      bool connecting,
    )?
    onAir,
    TResult? Function()? failed,
  }) {
    return onAir?.call(station, track, playing, connecting);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? hidden,
    TResult Function()? flying,
    TResult Function(
      RadioStation station,
      TrackTitle? track,
      bool playing,
      bool connecting,
    )?
    onAir,
    TResult Function()? failed,
    required TResult orElse(),
  }) {
    if (onAir != null) {
      return onAir(station, track, playing, connecting);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BarHidden value) hidden,
    required TResult Function(BarFlying value) flying,
    required TResult Function(BarOnAir value) onAir,
    required TResult Function(BarFailed value) failed,
  }) {
    return onAir(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BarHidden value)? hidden,
    TResult? Function(BarFlying value)? flying,
    TResult? Function(BarOnAir value)? onAir,
    TResult? Function(BarFailed value)? failed,
  }) {
    return onAir?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BarHidden value)? hidden,
    TResult Function(BarFlying value)? flying,
    TResult Function(BarOnAir value)? onAir,
    TResult Function(BarFailed value)? failed,
    required TResult orElse(),
  }) {
    if (onAir != null) {
      return onAir(this);
    }
    return orElse();
  }
}

abstract class BarOnAir implements RadioBarState {
  const factory BarOnAir(
    final RadioStation station, {
    final TrackTitle? track,
    required final bool playing,
    required final bool connecting,
  }) = _$BarOnAirImpl;

  RadioStation get station;
  TrackTitle? get track;
  bool get playing;
  bool get connecting;

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BarOnAirImplCopyWith<_$BarOnAirImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BarFailedImplCopyWith<$Res> {
  factory _$$BarFailedImplCopyWith(
    _$BarFailedImpl value,
    $Res Function(_$BarFailedImpl) then,
  ) = __$$BarFailedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BarFailedImplCopyWithImpl<$Res>
    extends _$RadioBarStateCopyWithImpl<$Res, _$BarFailedImpl>
    implements _$$BarFailedImplCopyWith<$Res> {
  __$$BarFailedImplCopyWithImpl(
    _$BarFailedImpl _value,
    $Res Function(_$BarFailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$BarFailedImpl implements BarFailed {
  const _$BarFailedImpl();

  @override
  String toString() {
    return 'RadioBarState.failed()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$BarFailedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() hidden,
    required TResult Function() flying,
    required TResult Function(
      RadioStation station,
      TrackTitle? track,
      bool playing,
      bool connecting,
    )
    onAir,
    required TResult Function() failed,
  }) {
    return failed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? hidden,
    TResult? Function()? flying,
    TResult? Function(
      RadioStation station,
      TrackTitle? track,
      bool playing,
      bool connecting,
    )?
    onAir,
    TResult? Function()? failed,
  }) {
    return failed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? hidden,
    TResult Function()? flying,
    TResult Function(
      RadioStation station,
      TrackTitle? track,
      bool playing,
      bool connecting,
    )?
    onAir,
    TResult Function()? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BarHidden value) hidden,
    required TResult Function(BarFlying value) flying,
    required TResult Function(BarOnAir value) onAir,
    required TResult Function(BarFailed value) failed,
  }) {
    return failed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BarHidden value)? hidden,
    TResult? Function(BarFlying value)? flying,
    TResult? Function(BarOnAir value)? onAir,
    TResult? Function(BarFailed value)? failed,
  }) {
    return failed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BarHidden value)? hidden,
    TResult Function(BarFlying value)? flying,
    TResult Function(BarOnAir value)? onAir,
    TResult Function(BarFailed value)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(this);
    }
    return orElse();
  }
}

abstract class BarFailed implements RadioBarState {
  const factory BarFailed() = _$BarFailedImpl;
}
