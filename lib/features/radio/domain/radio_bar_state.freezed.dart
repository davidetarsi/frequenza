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
      bool connecting,
    )
    playing,
    required TResult Function(RadioStation station, TrackTitle? track) paused,
    required TResult Function(RadioStation station) stopped,
    required TResult Function() failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? hidden,
    TResult? Function()? flying,
    TResult? Function(RadioStation station, TrackTitle? track, bool connecting)?
    playing,
    TResult? Function(RadioStation station, TrackTitle? track)? paused,
    TResult? Function(RadioStation station)? stopped,
    TResult? Function()? failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? hidden,
    TResult Function()? flying,
    TResult Function(RadioStation station, TrackTitle? track, bool connecting)?
    playing,
    TResult Function(RadioStation station, TrackTitle? track)? paused,
    TResult Function(RadioStation station)? stopped,
    TResult Function()? failed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BarHidden value) hidden,
    required TResult Function(BarFlying value) flying,
    required TResult Function(BarPlaying value) playing,
    required TResult Function(BarPaused value) paused,
    required TResult Function(BarStopped value) stopped,
    required TResult Function(BarFailed value) failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BarHidden value)? hidden,
    TResult? Function(BarFlying value)? flying,
    TResult? Function(BarPlaying value)? playing,
    TResult? Function(BarPaused value)? paused,
    TResult? Function(BarStopped value)? stopped,
    TResult? Function(BarFailed value)? failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BarHidden value)? hidden,
    TResult Function(BarFlying value)? flying,
    TResult Function(BarPlaying value)? playing,
    TResult Function(BarPaused value)? paused,
    TResult Function(BarStopped value)? stopped,
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

class _$BarHiddenImpl extends BarHidden {
  const _$BarHiddenImpl() : super._();

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
      bool connecting,
    )
    playing,
    required TResult Function(RadioStation station, TrackTitle? track) paused,
    required TResult Function(RadioStation station) stopped,
    required TResult Function() failed,
  }) {
    return hidden();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? hidden,
    TResult? Function()? flying,
    TResult? Function(RadioStation station, TrackTitle? track, bool connecting)?
    playing,
    TResult? Function(RadioStation station, TrackTitle? track)? paused,
    TResult? Function(RadioStation station)? stopped,
    TResult? Function()? failed,
  }) {
    return hidden?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? hidden,
    TResult Function()? flying,
    TResult Function(RadioStation station, TrackTitle? track, bool connecting)?
    playing,
    TResult Function(RadioStation station, TrackTitle? track)? paused,
    TResult Function(RadioStation station)? stopped,
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
    required TResult Function(BarPlaying value) playing,
    required TResult Function(BarPaused value) paused,
    required TResult Function(BarStopped value) stopped,
    required TResult Function(BarFailed value) failed,
  }) {
    return hidden(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BarHidden value)? hidden,
    TResult? Function(BarFlying value)? flying,
    TResult? Function(BarPlaying value)? playing,
    TResult? Function(BarPaused value)? paused,
    TResult? Function(BarStopped value)? stopped,
    TResult? Function(BarFailed value)? failed,
  }) {
    return hidden?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BarHidden value)? hidden,
    TResult Function(BarFlying value)? flying,
    TResult Function(BarPlaying value)? playing,
    TResult Function(BarPaused value)? paused,
    TResult Function(BarStopped value)? stopped,
    TResult Function(BarFailed value)? failed,
    required TResult orElse(),
  }) {
    if (hidden != null) {
      return hidden(this);
    }
    return orElse();
  }
}

abstract class BarHidden extends RadioBarState {
  const factory BarHidden() = _$BarHiddenImpl;
  const BarHidden._() : super._();
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

class _$BarFlyingImpl extends BarFlying {
  const _$BarFlyingImpl() : super._();

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
      bool connecting,
    )
    playing,
    required TResult Function(RadioStation station, TrackTitle? track) paused,
    required TResult Function(RadioStation station) stopped,
    required TResult Function() failed,
  }) {
    return flying();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? hidden,
    TResult? Function()? flying,
    TResult? Function(RadioStation station, TrackTitle? track, bool connecting)?
    playing,
    TResult? Function(RadioStation station, TrackTitle? track)? paused,
    TResult? Function(RadioStation station)? stopped,
    TResult? Function()? failed,
  }) {
    return flying?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? hidden,
    TResult Function()? flying,
    TResult Function(RadioStation station, TrackTitle? track, bool connecting)?
    playing,
    TResult Function(RadioStation station, TrackTitle? track)? paused,
    TResult Function(RadioStation station)? stopped,
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
    required TResult Function(BarPlaying value) playing,
    required TResult Function(BarPaused value) paused,
    required TResult Function(BarStopped value) stopped,
    required TResult Function(BarFailed value) failed,
  }) {
    return flying(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BarHidden value)? hidden,
    TResult? Function(BarFlying value)? flying,
    TResult? Function(BarPlaying value)? playing,
    TResult? Function(BarPaused value)? paused,
    TResult? Function(BarStopped value)? stopped,
    TResult? Function(BarFailed value)? failed,
  }) {
    return flying?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BarHidden value)? hidden,
    TResult Function(BarFlying value)? flying,
    TResult Function(BarPlaying value)? playing,
    TResult Function(BarPaused value)? paused,
    TResult Function(BarStopped value)? stopped,
    TResult Function(BarFailed value)? failed,
    required TResult orElse(),
  }) {
    if (flying != null) {
      return flying(this);
    }
    return orElse();
  }
}

abstract class BarFlying extends RadioBarState {
  const factory BarFlying() = _$BarFlyingImpl;
  const BarFlying._() : super._();
}

/// @nodoc
abstract class _$$BarPlayingImplCopyWith<$Res> {
  factory _$$BarPlayingImplCopyWith(
    _$BarPlayingImpl value,
    $Res Function(_$BarPlayingImpl) then,
  ) = __$$BarPlayingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({RadioStation station, TrackTitle? track, bool connecting});

  $RadioStationCopyWith<$Res> get station;
  $TrackTitleCopyWith<$Res>? get track;
}

/// @nodoc
class __$$BarPlayingImplCopyWithImpl<$Res>
    extends _$RadioBarStateCopyWithImpl<$Res, _$BarPlayingImpl>
    implements _$$BarPlayingImplCopyWith<$Res> {
  __$$BarPlayingImplCopyWithImpl(
    _$BarPlayingImpl _value,
    $Res Function(_$BarPlayingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? station = null,
    Object? track = freezed,
    Object? connecting = null,
  }) {
    return _then(
      _$BarPlayingImpl(
        null == station
            ? _value.station
            : station // ignore: cast_nullable_to_non_nullable
                  as RadioStation,
        track: freezed == track
            ? _value.track
            : track // ignore: cast_nullable_to_non_nullable
                  as TrackTitle?,
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

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrackTitleCopyWith<$Res>? get track {
    if (_value.track == null) {
      return null;
    }

    return $TrackTitleCopyWith<$Res>(_value.track!, (value) {
      return _then(_value.copyWith(track: value));
    });
  }
}

/// @nodoc

class _$BarPlayingImpl extends BarPlaying {
  const _$BarPlayingImpl(this.station, {this.track, this.connecting = false})
    : super._();

  @override
  final RadioStation station;
  @override
  final TrackTitle? track;
  @override
  @JsonKey()
  final bool connecting;

  @override
  String toString() {
    return 'RadioBarState.playing(station: $station, track: $track, connecting: $connecting)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BarPlayingImpl &&
            (identical(other.station, station) || other.station == station) &&
            (identical(other.track, track) || other.track == track) &&
            (identical(other.connecting, connecting) ||
                other.connecting == connecting));
  }

  @override
  int get hashCode => Object.hash(runtimeType, station, track, connecting);

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BarPlayingImplCopyWith<_$BarPlayingImpl> get copyWith =>
      __$$BarPlayingImplCopyWithImpl<_$BarPlayingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() hidden,
    required TResult Function() flying,
    required TResult Function(
      RadioStation station,
      TrackTitle? track,
      bool connecting,
    )
    playing,
    required TResult Function(RadioStation station, TrackTitle? track) paused,
    required TResult Function(RadioStation station) stopped,
    required TResult Function() failed,
  }) {
    return playing(station, track, connecting);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? hidden,
    TResult? Function()? flying,
    TResult? Function(RadioStation station, TrackTitle? track, bool connecting)?
    playing,
    TResult? Function(RadioStation station, TrackTitle? track)? paused,
    TResult? Function(RadioStation station)? stopped,
    TResult? Function()? failed,
  }) {
    return playing?.call(station, track, connecting);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? hidden,
    TResult Function()? flying,
    TResult Function(RadioStation station, TrackTitle? track, bool connecting)?
    playing,
    TResult Function(RadioStation station, TrackTitle? track)? paused,
    TResult Function(RadioStation station)? stopped,
    TResult Function()? failed,
    required TResult orElse(),
  }) {
    if (playing != null) {
      return playing(station, track, connecting);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BarHidden value) hidden,
    required TResult Function(BarFlying value) flying,
    required TResult Function(BarPlaying value) playing,
    required TResult Function(BarPaused value) paused,
    required TResult Function(BarStopped value) stopped,
    required TResult Function(BarFailed value) failed,
  }) {
    return playing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BarHidden value)? hidden,
    TResult? Function(BarFlying value)? flying,
    TResult? Function(BarPlaying value)? playing,
    TResult? Function(BarPaused value)? paused,
    TResult? Function(BarStopped value)? stopped,
    TResult? Function(BarFailed value)? failed,
  }) {
    return playing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BarHidden value)? hidden,
    TResult Function(BarFlying value)? flying,
    TResult Function(BarPlaying value)? playing,
    TResult Function(BarPaused value)? paused,
    TResult Function(BarStopped value)? stopped,
    TResult Function(BarFailed value)? failed,
    required TResult orElse(),
  }) {
    if (playing != null) {
      return playing(this);
    }
    return orElse();
  }
}

abstract class BarPlaying extends RadioBarState {
  const factory BarPlaying(
    final RadioStation station, {
    final TrackTitle? track,
    final bool connecting,
  }) = _$BarPlayingImpl;
  const BarPlaying._() : super._();

  RadioStation get station;
  TrackTitle? get track;
  bool get connecting;

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BarPlayingImplCopyWith<_$BarPlayingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BarPausedImplCopyWith<$Res> {
  factory _$$BarPausedImplCopyWith(
    _$BarPausedImpl value,
    $Res Function(_$BarPausedImpl) then,
  ) = __$$BarPausedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({RadioStation station, TrackTitle? track});

  $RadioStationCopyWith<$Res> get station;
  $TrackTitleCopyWith<$Res>? get track;
}

/// @nodoc
class __$$BarPausedImplCopyWithImpl<$Res>
    extends _$RadioBarStateCopyWithImpl<$Res, _$BarPausedImpl>
    implements _$$BarPausedImplCopyWith<$Res> {
  __$$BarPausedImplCopyWithImpl(
    _$BarPausedImpl _value,
    $Res Function(_$BarPausedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? station = null, Object? track = freezed}) {
    return _then(
      _$BarPausedImpl(
        null == station
            ? _value.station
            : station // ignore: cast_nullable_to_non_nullable
                  as RadioStation,
        track: freezed == track
            ? _value.track
            : track // ignore: cast_nullable_to_non_nullable
                  as TrackTitle?,
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

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrackTitleCopyWith<$Res>? get track {
    if (_value.track == null) {
      return null;
    }

    return $TrackTitleCopyWith<$Res>(_value.track!, (value) {
      return _then(_value.copyWith(track: value));
    });
  }
}

/// @nodoc

class _$BarPausedImpl extends BarPaused {
  const _$BarPausedImpl(this.station, {this.track}) : super._();

  @override
  final RadioStation station;
  @override
  final TrackTitle? track;

  @override
  String toString() {
    return 'RadioBarState.paused(station: $station, track: $track)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BarPausedImpl &&
            (identical(other.station, station) || other.station == station) &&
            (identical(other.track, track) || other.track == track));
  }

  @override
  int get hashCode => Object.hash(runtimeType, station, track);

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BarPausedImplCopyWith<_$BarPausedImpl> get copyWith =>
      __$$BarPausedImplCopyWithImpl<_$BarPausedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() hidden,
    required TResult Function() flying,
    required TResult Function(
      RadioStation station,
      TrackTitle? track,
      bool connecting,
    )
    playing,
    required TResult Function(RadioStation station, TrackTitle? track) paused,
    required TResult Function(RadioStation station) stopped,
    required TResult Function() failed,
  }) {
    return paused(station, track);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? hidden,
    TResult? Function()? flying,
    TResult? Function(RadioStation station, TrackTitle? track, bool connecting)?
    playing,
    TResult? Function(RadioStation station, TrackTitle? track)? paused,
    TResult? Function(RadioStation station)? stopped,
    TResult? Function()? failed,
  }) {
    return paused?.call(station, track);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? hidden,
    TResult Function()? flying,
    TResult Function(RadioStation station, TrackTitle? track, bool connecting)?
    playing,
    TResult Function(RadioStation station, TrackTitle? track)? paused,
    TResult Function(RadioStation station)? stopped,
    TResult Function()? failed,
    required TResult orElse(),
  }) {
    if (paused != null) {
      return paused(station, track);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BarHidden value) hidden,
    required TResult Function(BarFlying value) flying,
    required TResult Function(BarPlaying value) playing,
    required TResult Function(BarPaused value) paused,
    required TResult Function(BarStopped value) stopped,
    required TResult Function(BarFailed value) failed,
  }) {
    return paused(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BarHidden value)? hidden,
    TResult? Function(BarFlying value)? flying,
    TResult? Function(BarPlaying value)? playing,
    TResult? Function(BarPaused value)? paused,
    TResult? Function(BarStopped value)? stopped,
    TResult? Function(BarFailed value)? failed,
  }) {
    return paused?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BarHidden value)? hidden,
    TResult Function(BarFlying value)? flying,
    TResult Function(BarPlaying value)? playing,
    TResult Function(BarPaused value)? paused,
    TResult Function(BarStopped value)? stopped,
    TResult Function(BarFailed value)? failed,
    required TResult orElse(),
  }) {
    if (paused != null) {
      return paused(this);
    }
    return orElse();
  }
}

abstract class BarPaused extends RadioBarState {
  const factory BarPaused(
    final RadioStation station, {
    final TrackTitle? track,
  }) = _$BarPausedImpl;
  const BarPaused._() : super._();

  RadioStation get station;
  TrackTitle? get track;

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BarPausedImplCopyWith<_$BarPausedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BarStoppedImplCopyWith<$Res> {
  factory _$$BarStoppedImplCopyWith(
    _$BarStoppedImpl value,
    $Res Function(_$BarStoppedImpl) then,
  ) = __$$BarStoppedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({RadioStation station});

  $RadioStationCopyWith<$Res> get station;
}

/// @nodoc
class __$$BarStoppedImplCopyWithImpl<$Res>
    extends _$RadioBarStateCopyWithImpl<$Res, _$BarStoppedImpl>
    implements _$$BarStoppedImplCopyWith<$Res> {
  __$$BarStoppedImplCopyWithImpl(
    _$BarStoppedImpl _value,
    $Res Function(_$BarStoppedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? station = null}) {
    return _then(
      _$BarStoppedImpl(
        null == station
            ? _value.station
            : station // ignore: cast_nullable_to_non_nullable
                  as RadioStation,
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

class _$BarStoppedImpl extends BarStopped {
  const _$BarStoppedImpl(this.station) : super._();

  @override
  final RadioStation station;

  @override
  String toString() {
    return 'RadioBarState.stopped(station: $station)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BarStoppedImpl &&
            (identical(other.station, station) || other.station == station));
  }

  @override
  int get hashCode => Object.hash(runtimeType, station);

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BarStoppedImplCopyWith<_$BarStoppedImpl> get copyWith =>
      __$$BarStoppedImplCopyWithImpl<_$BarStoppedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() hidden,
    required TResult Function() flying,
    required TResult Function(
      RadioStation station,
      TrackTitle? track,
      bool connecting,
    )
    playing,
    required TResult Function(RadioStation station, TrackTitle? track) paused,
    required TResult Function(RadioStation station) stopped,
    required TResult Function() failed,
  }) {
    return stopped(station);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? hidden,
    TResult? Function()? flying,
    TResult? Function(RadioStation station, TrackTitle? track, bool connecting)?
    playing,
    TResult? Function(RadioStation station, TrackTitle? track)? paused,
    TResult? Function(RadioStation station)? stopped,
    TResult? Function()? failed,
  }) {
    return stopped?.call(station);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? hidden,
    TResult Function()? flying,
    TResult Function(RadioStation station, TrackTitle? track, bool connecting)?
    playing,
    TResult Function(RadioStation station, TrackTitle? track)? paused,
    TResult Function(RadioStation station)? stopped,
    TResult Function()? failed,
    required TResult orElse(),
  }) {
    if (stopped != null) {
      return stopped(station);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BarHidden value) hidden,
    required TResult Function(BarFlying value) flying,
    required TResult Function(BarPlaying value) playing,
    required TResult Function(BarPaused value) paused,
    required TResult Function(BarStopped value) stopped,
    required TResult Function(BarFailed value) failed,
  }) {
    return stopped(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BarHidden value)? hidden,
    TResult? Function(BarFlying value)? flying,
    TResult? Function(BarPlaying value)? playing,
    TResult? Function(BarPaused value)? paused,
    TResult? Function(BarStopped value)? stopped,
    TResult? Function(BarFailed value)? failed,
  }) {
    return stopped?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BarHidden value)? hidden,
    TResult Function(BarFlying value)? flying,
    TResult Function(BarPlaying value)? playing,
    TResult Function(BarPaused value)? paused,
    TResult Function(BarStopped value)? stopped,
    TResult Function(BarFailed value)? failed,
    required TResult orElse(),
  }) {
    if (stopped != null) {
      return stopped(this);
    }
    return orElse();
  }
}

abstract class BarStopped extends RadioBarState {
  const factory BarStopped(final RadioStation station) = _$BarStoppedImpl;
  const BarStopped._() : super._();

  RadioStation get station;

  /// Create a copy of RadioBarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BarStoppedImplCopyWith<_$BarStoppedImpl> get copyWith =>
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

class _$BarFailedImpl extends BarFailed {
  const _$BarFailedImpl() : super._();

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
      bool connecting,
    )
    playing,
    required TResult Function(RadioStation station, TrackTitle? track) paused,
    required TResult Function(RadioStation station) stopped,
    required TResult Function() failed,
  }) {
    return failed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? hidden,
    TResult? Function()? flying,
    TResult? Function(RadioStation station, TrackTitle? track, bool connecting)?
    playing,
    TResult? Function(RadioStation station, TrackTitle? track)? paused,
    TResult? Function(RadioStation station)? stopped,
    TResult? Function()? failed,
  }) {
    return failed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? hidden,
    TResult Function()? flying,
    TResult Function(RadioStation station, TrackTitle? track, bool connecting)?
    playing,
    TResult Function(RadioStation station, TrackTitle? track)? paused,
    TResult Function(RadioStation station)? stopped,
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
    required TResult Function(BarPlaying value) playing,
    required TResult Function(BarPaused value) paused,
    required TResult Function(BarStopped value) stopped,
    required TResult Function(BarFailed value) failed,
  }) {
    return failed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BarHidden value)? hidden,
    TResult? Function(BarFlying value)? flying,
    TResult? Function(BarPlaying value)? playing,
    TResult? Function(BarPaused value)? paused,
    TResult? Function(BarStopped value)? stopped,
    TResult? Function(BarFailed value)? failed,
  }) {
    return failed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BarHidden value)? hidden,
    TResult Function(BarFlying value)? flying,
    TResult Function(BarPlaying value)? playing,
    TResult Function(BarPaused value)? paused,
    TResult Function(BarStopped value)? stopped,
    TResult Function(BarFailed value)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(this);
    }
    return orElse();
  }
}

abstract class BarFailed extends RadioBarState {
  const factory BarFailed() = _$BarFailedImpl;
  const BarFailed._() : super._();
}
