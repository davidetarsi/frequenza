// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listening.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Listening {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(
      RadioStation station,
      Duration since,
      Duration stalled,
      bool written,
      int lastSeconds,
    )
    counting,
    required TResult Function(
      RadioStation station,
      Duration since,
      Duration stalledAt,
      Duration stalled,
      bool written,
      int lastSeconds,
    )
    stalled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(
      RadioStation station,
      Duration since,
      Duration stalled,
      bool written,
      int lastSeconds,
    )?
    counting,
    TResult? Function(
      RadioStation station,
      Duration since,
      Duration stalledAt,
      Duration stalled,
      bool written,
      int lastSeconds,
    )?
    stalled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(
      RadioStation station,
      Duration since,
      Duration stalled,
      bool written,
      int lastSeconds,
    )?
    counting,
    TResult Function(
      RadioStation station,
      Duration since,
      Duration stalledAt,
      Duration stalled,
      bool written,
      int lastSeconds,
    )?
    stalled,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Idle value) idle,
    required TResult Function(Counting value) counting,
    required TResult Function(Stalled value) stalled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Idle value)? idle,
    TResult? Function(Counting value)? counting,
    TResult? Function(Stalled value)? stalled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Idle value)? idle,
    TResult Function(Counting value)? counting,
    TResult Function(Stalled value)? stalled,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListeningCopyWith<$Res> {
  factory $ListeningCopyWith(Listening value, $Res Function(Listening) then) =
      _$ListeningCopyWithImpl<$Res, Listening>;
}

/// @nodoc
class _$ListeningCopyWithImpl<$Res, $Val extends Listening>
    implements $ListeningCopyWith<$Res> {
  _$ListeningCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Listening
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$IdleImplCopyWith<$Res> {
  factory _$$IdleImplCopyWith(
    _$IdleImpl value,
    $Res Function(_$IdleImpl) then,
  ) = __$$IdleImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$IdleImplCopyWithImpl<$Res>
    extends _$ListeningCopyWithImpl<$Res, _$IdleImpl>
    implements _$$IdleImplCopyWith<$Res> {
  __$$IdleImplCopyWithImpl(_$IdleImpl _value, $Res Function(_$IdleImpl) _then)
    : super(_value, _then);

  /// Create a copy of Listening
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$IdleImpl implements Idle {
  const _$IdleImpl();

  @override
  String toString() {
    return 'Listening.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$IdleImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(
      RadioStation station,
      Duration since,
      Duration stalled,
      bool written,
      int lastSeconds,
    )
    counting,
    required TResult Function(
      RadioStation station,
      Duration since,
      Duration stalledAt,
      Duration stalled,
      bool written,
      int lastSeconds,
    )
    stalled,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(
      RadioStation station,
      Duration since,
      Duration stalled,
      bool written,
      int lastSeconds,
    )?
    counting,
    TResult? Function(
      RadioStation station,
      Duration since,
      Duration stalledAt,
      Duration stalled,
      bool written,
      int lastSeconds,
    )?
    stalled,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(
      RadioStation station,
      Duration since,
      Duration stalled,
      bool written,
      int lastSeconds,
    )?
    counting,
    TResult Function(
      RadioStation station,
      Duration since,
      Duration stalledAt,
      Duration stalled,
      bool written,
      int lastSeconds,
    )?
    stalled,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Idle value) idle,
    required TResult Function(Counting value) counting,
    required TResult Function(Stalled value) stalled,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Idle value)? idle,
    TResult? Function(Counting value)? counting,
    TResult? Function(Stalled value)? stalled,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Idle value)? idle,
    TResult Function(Counting value)? counting,
    TResult Function(Stalled value)? stalled,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class Idle implements Listening {
  const factory Idle() = _$IdleImpl;
}

/// @nodoc
abstract class _$$CountingImplCopyWith<$Res> {
  factory _$$CountingImplCopyWith(
    _$CountingImpl value,
    $Res Function(_$CountingImpl) then,
  ) = __$$CountingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    RadioStation station,
    Duration since,
    Duration stalled,
    bool written,
    int lastSeconds,
  });

  $RadioStationCopyWith<$Res> get station;
}

/// @nodoc
class __$$CountingImplCopyWithImpl<$Res>
    extends _$ListeningCopyWithImpl<$Res, _$CountingImpl>
    implements _$$CountingImplCopyWith<$Res> {
  __$$CountingImplCopyWithImpl(
    _$CountingImpl _value,
    $Res Function(_$CountingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Listening
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? station = null,
    Object? since = null,
    Object? stalled = null,
    Object? written = null,
    Object? lastSeconds = null,
  }) {
    return _then(
      _$CountingImpl(
        null == station
            ? _value.station
            : station // ignore: cast_nullable_to_non_nullable
                  as RadioStation,
        since: null == since
            ? _value.since
            : since // ignore: cast_nullable_to_non_nullable
                  as Duration,
        stalled: null == stalled
            ? _value.stalled
            : stalled // ignore: cast_nullable_to_non_nullable
                  as Duration,
        written: null == written
            ? _value.written
            : written // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastSeconds: null == lastSeconds
            ? _value.lastSeconds
            : lastSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }

  /// Create a copy of Listening
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

class _$CountingImpl implements Counting {
  const _$CountingImpl(
    this.station, {
    required this.since,
    this.stalled = Duration.zero,
    this.written = false,
    this.lastSeconds = 0,
  });

  @override
  final RadioStation station;
  @override
  final Duration since;
  @override
  @JsonKey()
  final Duration stalled;
  @override
  @JsonKey()
  final bool written;
  @override
  @JsonKey()
  final int lastSeconds;

  @override
  String toString() {
    return 'Listening.counting(station: $station, since: $since, stalled: $stalled, written: $written, lastSeconds: $lastSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CountingImpl &&
            (identical(other.station, station) || other.station == station) &&
            (identical(other.since, since) || other.since == since) &&
            (identical(other.stalled, stalled) || other.stalled == stalled) &&
            (identical(other.written, written) || other.written == written) &&
            (identical(other.lastSeconds, lastSeconds) ||
                other.lastSeconds == lastSeconds));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, station, since, stalled, written, lastSeconds);

  /// Create a copy of Listening
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CountingImplCopyWith<_$CountingImpl> get copyWith =>
      __$$CountingImplCopyWithImpl<_$CountingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(
      RadioStation station,
      Duration since,
      Duration stalled,
      bool written,
      int lastSeconds,
    )
    counting,
    required TResult Function(
      RadioStation station,
      Duration since,
      Duration stalledAt,
      Duration stalled,
      bool written,
      int lastSeconds,
    )
    stalled,
  }) {
    return counting(station, since, this.stalled, written, lastSeconds);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(
      RadioStation station,
      Duration since,
      Duration stalled,
      bool written,
      int lastSeconds,
    )?
    counting,
    TResult? Function(
      RadioStation station,
      Duration since,
      Duration stalledAt,
      Duration stalled,
      bool written,
      int lastSeconds,
    )?
    stalled,
  }) {
    return counting?.call(station, since, this.stalled, written, lastSeconds);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(
      RadioStation station,
      Duration since,
      Duration stalled,
      bool written,
      int lastSeconds,
    )?
    counting,
    TResult Function(
      RadioStation station,
      Duration since,
      Duration stalledAt,
      Duration stalled,
      bool written,
      int lastSeconds,
    )?
    stalled,
    required TResult orElse(),
  }) {
    if (counting != null) {
      return counting(station, since, this.stalled, written, lastSeconds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Idle value) idle,
    required TResult Function(Counting value) counting,
    required TResult Function(Stalled value) stalled,
  }) {
    return counting(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Idle value)? idle,
    TResult? Function(Counting value)? counting,
    TResult? Function(Stalled value)? stalled,
  }) {
    return counting?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Idle value)? idle,
    TResult Function(Counting value)? counting,
    TResult Function(Stalled value)? stalled,
    required TResult orElse(),
  }) {
    if (counting != null) {
      return counting(this);
    }
    return orElse();
  }
}

abstract class Counting implements Listening {
  const factory Counting(
    final RadioStation station, {
    required final Duration since,
    final Duration stalled,
    final bool written,
    final int lastSeconds,
  }) = _$CountingImpl;

  RadioStation get station;
  Duration get since;
  Duration get stalled;
  bool get written;
  int get lastSeconds;

  /// Create a copy of Listening
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CountingImplCopyWith<_$CountingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StalledImplCopyWith<$Res> {
  factory _$$StalledImplCopyWith(
    _$StalledImpl value,
    $Res Function(_$StalledImpl) then,
  ) = __$$StalledImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    RadioStation station,
    Duration since,
    Duration stalledAt,
    Duration stalled,
    bool written,
    int lastSeconds,
  });

  $RadioStationCopyWith<$Res> get station;
}

/// @nodoc
class __$$StalledImplCopyWithImpl<$Res>
    extends _$ListeningCopyWithImpl<$Res, _$StalledImpl>
    implements _$$StalledImplCopyWith<$Res> {
  __$$StalledImplCopyWithImpl(
    _$StalledImpl _value,
    $Res Function(_$StalledImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Listening
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? station = null,
    Object? since = null,
    Object? stalledAt = null,
    Object? stalled = null,
    Object? written = null,
    Object? lastSeconds = null,
  }) {
    return _then(
      _$StalledImpl(
        null == station
            ? _value.station
            : station // ignore: cast_nullable_to_non_nullable
                  as RadioStation,
        since: null == since
            ? _value.since
            : since // ignore: cast_nullable_to_non_nullable
                  as Duration,
        stalledAt: null == stalledAt
            ? _value.stalledAt
            : stalledAt // ignore: cast_nullable_to_non_nullable
                  as Duration,
        stalled: null == stalled
            ? _value.stalled
            : stalled // ignore: cast_nullable_to_non_nullable
                  as Duration,
        written: null == written
            ? _value.written
            : written // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastSeconds: null == lastSeconds
            ? _value.lastSeconds
            : lastSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }

  /// Create a copy of Listening
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

class _$StalledImpl implements Stalled {
  const _$StalledImpl(
    this.station, {
    required this.since,
    required this.stalledAt,
    this.stalled = Duration.zero,
    this.written = false,
    this.lastSeconds = 0,
  });

  @override
  final RadioStation station;
  @override
  final Duration since;
  @override
  final Duration stalledAt;
  @override
  @JsonKey()
  final Duration stalled;
  @override
  @JsonKey()
  final bool written;
  @override
  @JsonKey()
  final int lastSeconds;

  @override
  String toString() {
    return 'Listening.stalled(station: $station, since: $since, stalledAt: $stalledAt, stalled: $stalled, written: $written, lastSeconds: $lastSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StalledImpl &&
            (identical(other.station, station) || other.station == station) &&
            (identical(other.since, since) || other.since == since) &&
            (identical(other.stalledAt, stalledAt) ||
                other.stalledAt == stalledAt) &&
            (identical(other.stalled, stalled) || other.stalled == stalled) &&
            (identical(other.written, written) || other.written == written) &&
            (identical(other.lastSeconds, lastSeconds) ||
                other.lastSeconds == lastSeconds));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    station,
    since,
    stalledAt,
    stalled,
    written,
    lastSeconds,
  );

  /// Create a copy of Listening
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StalledImplCopyWith<_$StalledImpl> get copyWith =>
      __$$StalledImplCopyWithImpl<_$StalledImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(
      RadioStation station,
      Duration since,
      Duration stalled,
      bool written,
      int lastSeconds,
    )
    counting,
    required TResult Function(
      RadioStation station,
      Duration since,
      Duration stalledAt,
      Duration stalled,
      bool written,
      int lastSeconds,
    )
    stalled,
  }) {
    return stalled(
      station,
      since,
      stalledAt,
      this.stalled,
      written,
      lastSeconds,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(
      RadioStation station,
      Duration since,
      Duration stalled,
      bool written,
      int lastSeconds,
    )?
    counting,
    TResult? Function(
      RadioStation station,
      Duration since,
      Duration stalledAt,
      Duration stalled,
      bool written,
      int lastSeconds,
    )?
    stalled,
  }) {
    return stalled?.call(
      station,
      since,
      stalledAt,
      this.stalled,
      written,
      lastSeconds,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(
      RadioStation station,
      Duration since,
      Duration stalled,
      bool written,
      int lastSeconds,
    )?
    counting,
    TResult Function(
      RadioStation station,
      Duration since,
      Duration stalledAt,
      Duration stalled,
      bool written,
      int lastSeconds,
    )?
    stalled,
    required TResult orElse(),
  }) {
    if (stalled != null) {
      return stalled(
        station,
        since,
        stalledAt,
        this.stalled,
        written,
        lastSeconds,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Idle value) idle,
    required TResult Function(Counting value) counting,
    required TResult Function(Stalled value) stalled,
  }) {
    return stalled(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Idle value)? idle,
    TResult? Function(Counting value)? counting,
    TResult? Function(Stalled value)? stalled,
  }) {
    return stalled?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Idle value)? idle,
    TResult Function(Counting value)? counting,
    TResult Function(Stalled value)? stalled,
    required TResult orElse(),
  }) {
    if (stalled != null) {
      return stalled(this);
    }
    return orElse();
  }
}

abstract class Stalled implements Listening {
  const factory Stalled(
    final RadioStation station, {
    required final Duration since,
    required final Duration stalledAt,
    final Duration stalled,
    final bool written,
    final int lastSeconds,
  }) = _$StalledImpl;

  RadioStation get station;
  Duration get since;
  Duration get stalledAt;
  Duration get stalled;
  bool get written;
  int get lastSeconds;

  /// Create a copy of Listening
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StalledImplCopyWith<_$StalledImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
