// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diary_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$StationTime {
  RadioStation get station => throw _privateConstructorUsedError;
  int get seconds => throw _privateConstructorUsedError;

  /// Create a copy of StationTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StationTimeCopyWith<StationTime> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StationTimeCopyWith<$Res> {
  factory $StationTimeCopyWith(
    StationTime value,
    $Res Function(StationTime) then,
  ) = _$StationTimeCopyWithImpl<$Res, StationTime>;
  @useResult
  $Res call({RadioStation station, int seconds});

  $RadioStationCopyWith<$Res> get station;
}

/// @nodoc
class _$StationTimeCopyWithImpl<$Res, $Val extends StationTime>
    implements $StationTimeCopyWith<$Res> {
  _$StationTimeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StationTime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? station = null, Object? seconds = null}) {
    return _then(
      _value.copyWith(
            station: null == station
                ? _value.station
                : station // ignore: cast_nullable_to_non_nullable
                      as RadioStation,
            seconds: null == seconds
                ? _value.seconds
                : seconds // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of StationTime
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RadioStationCopyWith<$Res> get station {
    return $RadioStationCopyWith<$Res>(_value.station, (value) {
      return _then(_value.copyWith(station: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StationTimeImplCopyWith<$Res>
    implements $StationTimeCopyWith<$Res> {
  factory _$$StationTimeImplCopyWith(
    _$StationTimeImpl value,
    $Res Function(_$StationTimeImpl) then,
  ) = __$$StationTimeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({RadioStation station, int seconds});

  @override
  $RadioStationCopyWith<$Res> get station;
}

/// @nodoc
class __$$StationTimeImplCopyWithImpl<$Res>
    extends _$StationTimeCopyWithImpl<$Res, _$StationTimeImpl>
    implements _$$StationTimeImplCopyWith<$Res> {
  __$$StationTimeImplCopyWithImpl(
    _$StationTimeImpl _value,
    $Res Function(_$StationTimeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StationTime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? station = null, Object? seconds = null}) {
    return _then(
      _$StationTimeImpl(
        station: null == station
            ? _value.station
            : station // ignore: cast_nullable_to_non_nullable
                  as RadioStation,
        seconds: null == seconds
            ? _value.seconds
            : seconds // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$StationTimeImpl implements _StationTime {
  const _$StationTimeImpl({required this.station, required this.seconds});

  @override
  final RadioStation station;
  @override
  final int seconds;

  @override
  String toString() {
    return 'StationTime(station: $station, seconds: $seconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StationTimeImpl &&
            (identical(other.station, station) || other.station == station) &&
            (identical(other.seconds, seconds) || other.seconds == seconds));
  }

  @override
  int get hashCode => Object.hash(runtimeType, station, seconds);

  /// Create a copy of StationTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StationTimeImplCopyWith<_$StationTimeImpl> get copyWith =>
      __$$StationTimeImplCopyWithImpl<_$StationTimeImpl>(this, _$identity);
}

abstract class _StationTime implements StationTime {
  const factory _StationTime({
    required final RadioStation station,
    required final int seconds,
  }) = _$StationTimeImpl;

  @override
  RadioStation get station;
  @override
  int get seconds;

  /// Create a copy of StationTime
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StationTimeImplCopyWith<_$StationTimeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CountryTime {
  String get code => throw _privateConstructorUsedError;

  /// Radio Browser's name, for countries the atlas does not know.
  String get name => throw _privateConstructorUsedError;
  int get seconds => throw _privateConstructorUsedError;

  /// Most heard first.
  List<StationTime> get stations => throw _privateConstructorUsedError;
  DateTime get lastListen => throw _privateConstructorUsedError;

  /// 0 when passing through; 1 to 4 by quartiles among the stops.
  int get level => throw _privateConstructorUsedError;

  /// Create a copy of CountryTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CountryTimeCopyWith<CountryTime> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CountryTimeCopyWith<$Res> {
  factory $CountryTimeCopyWith(
    CountryTime value,
    $Res Function(CountryTime) then,
  ) = _$CountryTimeCopyWithImpl<$Res, CountryTime>;
  @useResult
  $Res call({
    String code,
    String name,
    int seconds,
    List<StationTime> stations,
    DateTime lastListen,
    int level,
  });
}

/// @nodoc
class _$CountryTimeCopyWithImpl<$Res, $Val extends CountryTime>
    implements $CountryTimeCopyWith<$Res> {
  _$CountryTimeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CountryTime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? seconds = null,
    Object? stations = null,
    Object? lastListen = null,
    Object? level = null,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            seconds: null == seconds
                ? _value.seconds
                : seconds // ignore: cast_nullable_to_non_nullable
                      as int,
            stations: null == stations
                ? _value.stations
                : stations // ignore: cast_nullable_to_non_nullable
                      as List<StationTime>,
            lastListen: null == lastListen
                ? _value.lastListen
                : lastListen // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CountryTimeImplCopyWith<$Res>
    implements $CountryTimeCopyWith<$Res> {
  factory _$$CountryTimeImplCopyWith(
    _$CountryTimeImpl value,
    $Res Function(_$CountryTimeImpl) then,
  ) = __$$CountryTimeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String code,
    String name,
    int seconds,
    List<StationTime> stations,
    DateTime lastListen,
    int level,
  });
}

/// @nodoc
class __$$CountryTimeImplCopyWithImpl<$Res>
    extends _$CountryTimeCopyWithImpl<$Res, _$CountryTimeImpl>
    implements _$$CountryTimeImplCopyWith<$Res> {
  __$$CountryTimeImplCopyWithImpl(
    _$CountryTimeImpl _value,
    $Res Function(_$CountryTimeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CountryTime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? seconds = null,
    Object? stations = null,
    Object? lastListen = null,
    Object? level = null,
  }) {
    return _then(
      _$CountryTimeImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        seconds: null == seconds
            ? _value.seconds
            : seconds // ignore: cast_nullable_to_non_nullable
                  as int,
        stations: null == stations
            ? _value._stations
            : stations // ignore: cast_nullable_to_non_nullable
                  as List<StationTime>,
        lastListen: null == lastListen
            ? _value.lastListen
            : lastListen // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$CountryTimeImpl implements _CountryTime {
  const _$CountryTimeImpl({
    required this.code,
    required this.name,
    required this.seconds,
    required final List<StationTime> stations,
    required this.lastListen,
    required this.level,
  }) : _stations = stations;

  @override
  final String code;

  /// Radio Browser's name, for countries the atlas does not know.
  @override
  final String name;
  @override
  final int seconds;

  /// Most heard first.
  final List<StationTime> _stations;

  /// Most heard first.
  @override
  List<StationTime> get stations {
    if (_stations is EqualUnmodifiableListView) return _stations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stations);
  }

  @override
  final DateTime lastListen;

  /// 0 when passing through; 1 to 4 by quartiles among the stops.
  @override
  final int level;

  @override
  String toString() {
    return 'CountryTime(code: $code, name: $name, seconds: $seconds, stations: $stations, lastListen: $lastListen, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CountryTimeImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.seconds, seconds) || other.seconds == seconds) &&
            const DeepCollectionEquality().equals(other._stations, _stations) &&
            (identical(other.lastListen, lastListen) ||
                other.lastListen == lastListen) &&
            (identical(other.level, level) || other.level == level));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    code,
    name,
    seconds,
    const DeepCollectionEquality().hash(_stations),
    lastListen,
    level,
  );

  /// Create a copy of CountryTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CountryTimeImplCopyWith<_$CountryTimeImpl> get copyWith =>
      __$$CountryTimeImplCopyWithImpl<_$CountryTimeImpl>(this, _$identity);
}

abstract class _CountryTime implements CountryTime {
  const factory _CountryTime({
    required final String code,
    required final String name,
    required final int seconds,
    required final List<StationTime> stations,
    required final DateTime lastListen,
    required final int level,
  }) = _$CountryTimeImpl;

  @override
  String get code;

  /// Radio Browser's name, for countries the atlas does not know.
  @override
  String get name;
  @override
  int get seconds;

  /// Most heard first.
  @override
  List<StationTime> get stations;
  @override
  DateTime get lastListen;

  /// 0 when passing through; 1 to 4 by quartiles among the stops.
  @override
  int get level;

  /// Create a copy of CountryTime
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CountryTimeImplCopyWith<_$CountryTimeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DiarySummary {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function(
      List<CountryTime> countries,
      int totalSeconds,
      int stationCount,
      StationTime top,
      int thresholdSeconds,
      double? longestTripKm,
    )
    filled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? empty,
    TResult? Function(
      List<CountryTime> countries,
      int totalSeconds,
      int stationCount,
      StationTime top,
      int thresholdSeconds,
      double? longestTripKm,
    )?
    filled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(
      List<CountryTime> countries,
      int totalSeconds,
      int stationCount,
      StationTime top,
      int thresholdSeconds,
      double? longestTripKm,
    )?
    filled,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DiaryEmpty value) empty,
    required TResult Function(DiaryFilled value) filled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DiaryEmpty value)? empty,
    TResult? Function(DiaryFilled value)? filled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DiaryEmpty value)? empty,
    TResult Function(DiaryFilled value)? filled,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiarySummaryCopyWith<$Res> {
  factory $DiarySummaryCopyWith(
    DiarySummary value,
    $Res Function(DiarySummary) then,
  ) = _$DiarySummaryCopyWithImpl<$Res, DiarySummary>;
}

/// @nodoc
class _$DiarySummaryCopyWithImpl<$Res, $Val extends DiarySummary>
    implements $DiarySummaryCopyWith<$Res> {
  _$DiarySummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiarySummary
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$DiaryEmptyImplCopyWith<$Res> {
  factory _$$DiaryEmptyImplCopyWith(
    _$DiaryEmptyImpl value,
    $Res Function(_$DiaryEmptyImpl) then,
  ) = __$$DiaryEmptyImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DiaryEmptyImplCopyWithImpl<$Res>
    extends _$DiarySummaryCopyWithImpl<$Res, _$DiaryEmptyImpl>
    implements _$$DiaryEmptyImplCopyWith<$Res> {
  __$$DiaryEmptyImplCopyWithImpl(
    _$DiaryEmptyImpl _value,
    $Res Function(_$DiaryEmptyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiarySummary
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$DiaryEmptyImpl extends DiaryEmpty {
  const _$DiaryEmptyImpl() : super._();

  @override
  String toString() {
    return 'DiarySummary.empty()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DiaryEmptyImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function(
      List<CountryTime> countries,
      int totalSeconds,
      int stationCount,
      StationTime top,
      int thresholdSeconds,
      double? longestTripKm,
    )
    filled,
  }) {
    return empty();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? empty,
    TResult? Function(
      List<CountryTime> countries,
      int totalSeconds,
      int stationCount,
      StationTime top,
      int thresholdSeconds,
      double? longestTripKm,
    )?
    filled,
  }) {
    return empty?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(
      List<CountryTime> countries,
      int totalSeconds,
      int stationCount,
      StationTime top,
      int thresholdSeconds,
      double? longestTripKm,
    )?
    filled,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DiaryEmpty value) empty,
    required TResult Function(DiaryFilled value) filled,
  }) {
    return empty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DiaryEmpty value)? empty,
    TResult? Function(DiaryFilled value)? filled,
  }) {
    return empty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DiaryEmpty value)? empty,
    TResult Function(DiaryFilled value)? filled,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty(this);
    }
    return orElse();
  }
}

abstract class DiaryEmpty extends DiarySummary {
  const factory DiaryEmpty() = _$DiaryEmptyImpl;
  const DiaryEmpty._() : super._();
}

/// @nodoc
abstract class _$$DiaryFilledImplCopyWith<$Res> {
  factory _$$DiaryFilledImplCopyWith(
    _$DiaryFilledImpl value,
    $Res Function(_$DiaryFilledImpl) then,
  ) = __$$DiaryFilledImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    List<CountryTime> countries,
    int totalSeconds,
    int stationCount,
    StationTime top,
    int thresholdSeconds,
    double? longestTripKm,
  });

  $StationTimeCopyWith<$Res> get top;
}

/// @nodoc
class __$$DiaryFilledImplCopyWithImpl<$Res>
    extends _$DiarySummaryCopyWithImpl<$Res, _$DiaryFilledImpl>
    implements _$$DiaryFilledImplCopyWith<$Res> {
  __$$DiaryFilledImplCopyWithImpl(
    _$DiaryFilledImpl _value,
    $Res Function(_$DiaryFilledImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiarySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? countries = null,
    Object? totalSeconds = null,
    Object? stationCount = null,
    Object? top = null,
    Object? thresholdSeconds = null,
    Object? longestTripKm = freezed,
  }) {
    return _then(
      _$DiaryFilledImpl(
        countries: null == countries
            ? _value._countries
            : countries // ignore: cast_nullable_to_non_nullable
                  as List<CountryTime>,
        totalSeconds: null == totalSeconds
            ? _value.totalSeconds
            : totalSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        stationCount: null == stationCount
            ? _value.stationCount
            : stationCount // ignore: cast_nullable_to_non_nullable
                  as int,
        top: null == top
            ? _value.top
            : top // ignore: cast_nullable_to_non_nullable
                  as StationTime,
        thresholdSeconds: null == thresholdSeconds
            ? _value.thresholdSeconds
            : thresholdSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        longestTripKm: freezed == longestTripKm
            ? _value.longestTripKm
            : longestTripKm // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }

  /// Create a copy of DiarySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StationTimeCopyWith<$Res> get top {
    return $StationTimeCopyWith<$Res>(_value.top, (value) {
      return _then(_value.copyWith(top: value));
    });
  }
}

/// @nodoc

class _$DiaryFilledImpl extends DiaryFilled {
  const _$DiaryFilledImpl({
    required final List<CountryTime> countries,
    required this.totalSeconds,
    required this.stationCount,
    required this.top,
    required this.thresholdSeconds,
    required this.longestTripKm,
  }) : _countries = countries,
       super._();

  /// Most heard first; passing countries too, with level 0.
  final List<CountryTime> _countries;

  /// Most heard first; passing countries too, with level 0.
  @override
  List<CountryTime> get countries {
    if (_countries is EqualUnmodifiableListView) return _countries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_countries);
  }

  @override
  final int totalSeconds;
  @override
  final int stationCount;
  @override
  final StationTime top;
  @override
  final int thresholdSeconds;
  @override
  final double? longestTripKm;

  @override
  String toString() {
    return 'DiarySummary.filled(countries: $countries, totalSeconds: $totalSeconds, stationCount: $stationCount, top: $top, thresholdSeconds: $thresholdSeconds, longestTripKm: $longestTripKm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiaryFilledImpl &&
            const DeepCollectionEquality().equals(
              other._countries,
              _countries,
            ) &&
            (identical(other.totalSeconds, totalSeconds) ||
                other.totalSeconds == totalSeconds) &&
            (identical(other.stationCount, stationCount) ||
                other.stationCount == stationCount) &&
            (identical(other.top, top) || other.top == top) &&
            (identical(other.thresholdSeconds, thresholdSeconds) ||
                other.thresholdSeconds == thresholdSeconds) &&
            (identical(other.longestTripKm, longestTripKm) ||
                other.longestTripKm == longestTripKm));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_countries),
    totalSeconds,
    stationCount,
    top,
    thresholdSeconds,
    longestTripKm,
  );

  /// Create a copy of DiarySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiaryFilledImplCopyWith<_$DiaryFilledImpl> get copyWith =>
      __$$DiaryFilledImplCopyWithImpl<_$DiaryFilledImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function(
      List<CountryTime> countries,
      int totalSeconds,
      int stationCount,
      StationTime top,
      int thresholdSeconds,
      double? longestTripKm,
    )
    filled,
  }) {
    return filled(
      countries,
      totalSeconds,
      stationCount,
      top,
      thresholdSeconds,
      longestTripKm,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? empty,
    TResult? Function(
      List<CountryTime> countries,
      int totalSeconds,
      int stationCount,
      StationTime top,
      int thresholdSeconds,
      double? longestTripKm,
    )?
    filled,
  }) {
    return filled?.call(
      countries,
      totalSeconds,
      stationCount,
      top,
      thresholdSeconds,
      longestTripKm,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(
      List<CountryTime> countries,
      int totalSeconds,
      int stationCount,
      StationTime top,
      int thresholdSeconds,
      double? longestTripKm,
    )?
    filled,
    required TResult orElse(),
  }) {
    if (filled != null) {
      return filled(
        countries,
        totalSeconds,
        stationCount,
        top,
        thresholdSeconds,
        longestTripKm,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DiaryEmpty value) empty,
    required TResult Function(DiaryFilled value) filled,
  }) {
    return filled(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DiaryEmpty value)? empty,
    TResult? Function(DiaryFilled value)? filled,
  }) {
    return filled?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DiaryEmpty value)? empty,
    TResult Function(DiaryFilled value)? filled,
    required TResult orElse(),
  }) {
    if (filled != null) {
      return filled(this);
    }
    return orElse();
  }
}

abstract class DiaryFilled extends DiarySummary {
  const factory DiaryFilled({
    required final List<CountryTime> countries,
    required final int totalSeconds,
    required final int stationCount,
    required final StationTime top,
    required final int thresholdSeconds,
    required final double? longestTripKm,
  }) = _$DiaryFilledImpl;
  const DiaryFilled._() : super._();

  /// Most heard first; passing countries too, with level 0.
  List<CountryTime> get countries;
  int get totalSeconds;
  int get stationCount;
  StationTime get top;
  int get thresholdSeconds;
  double? get longestTripKm;

  /// Create a copy of DiarySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiaryFilledImplCopyWith<_$DiaryFilledImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CountryCard {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CountryTime country) stopped,
    required TResult Function(CountryTime country, int thresholdSeconds)
    passing,
    required TResult Function(String code) unvisited,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CountryTime country)? stopped,
    TResult? Function(CountryTime country, int thresholdSeconds)? passing,
    TResult? Function(String code)? unvisited,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CountryTime country)? stopped,
    TResult Function(CountryTime country, int thresholdSeconds)? passing,
    TResult Function(String code)? unvisited,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StoppedCountry value) stopped,
    required TResult Function(PassingCountry value) passing,
    required TResult Function(UnvisitedCountry value) unvisited,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StoppedCountry value)? stopped,
    TResult? Function(PassingCountry value)? passing,
    TResult? Function(UnvisitedCountry value)? unvisited,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StoppedCountry value)? stopped,
    TResult Function(PassingCountry value)? passing,
    TResult Function(UnvisitedCountry value)? unvisited,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CountryCardCopyWith<$Res> {
  factory $CountryCardCopyWith(
    CountryCard value,
    $Res Function(CountryCard) then,
  ) = _$CountryCardCopyWithImpl<$Res, CountryCard>;
}

/// @nodoc
class _$CountryCardCopyWithImpl<$Res, $Val extends CountryCard>
    implements $CountryCardCopyWith<$Res> {
  _$CountryCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CountryCard
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$StoppedCountryImplCopyWith<$Res> {
  factory _$$StoppedCountryImplCopyWith(
    _$StoppedCountryImpl value,
    $Res Function(_$StoppedCountryImpl) then,
  ) = __$$StoppedCountryImplCopyWithImpl<$Res>;
  @useResult
  $Res call({CountryTime country});

  $CountryTimeCopyWith<$Res> get country;
}

/// @nodoc
class __$$StoppedCountryImplCopyWithImpl<$Res>
    extends _$CountryCardCopyWithImpl<$Res, _$StoppedCountryImpl>
    implements _$$StoppedCountryImplCopyWith<$Res> {
  __$$StoppedCountryImplCopyWithImpl(
    _$StoppedCountryImpl _value,
    $Res Function(_$StoppedCountryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CountryCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? country = null}) {
    return _then(
      _$StoppedCountryImpl(
        null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as CountryTime,
      ),
    );
  }

  /// Create a copy of CountryCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CountryTimeCopyWith<$Res> get country {
    return $CountryTimeCopyWith<$Res>(_value.country, (value) {
      return _then(_value.copyWith(country: value));
    });
  }
}

/// @nodoc

class _$StoppedCountryImpl implements StoppedCountry {
  const _$StoppedCountryImpl(this.country);

  @override
  final CountryTime country;

  @override
  String toString() {
    return 'CountryCard.stopped(country: $country)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoppedCountryImpl &&
            (identical(other.country, country) || other.country == country));
  }

  @override
  int get hashCode => Object.hash(runtimeType, country);

  /// Create a copy of CountryCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoppedCountryImplCopyWith<_$StoppedCountryImpl> get copyWith =>
      __$$StoppedCountryImplCopyWithImpl<_$StoppedCountryImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CountryTime country) stopped,
    required TResult Function(CountryTime country, int thresholdSeconds)
    passing,
    required TResult Function(String code) unvisited,
  }) {
    return stopped(country);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CountryTime country)? stopped,
    TResult? Function(CountryTime country, int thresholdSeconds)? passing,
    TResult? Function(String code)? unvisited,
  }) {
    return stopped?.call(country);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CountryTime country)? stopped,
    TResult Function(CountryTime country, int thresholdSeconds)? passing,
    TResult Function(String code)? unvisited,
    required TResult orElse(),
  }) {
    if (stopped != null) {
      return stopped(country);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StoppedCountry value) stopped,
    required TResult Function(PassingCountry value) passing,
    required TResult Function(UnvisitedCountry value) unvisited,
  }) {
    return stopped(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StoppedCountry value)? stopped,
    TResult? Function(PassingCountry value)? passing,
    TResult? Function(UnvisitedCountry value)? unvisited,
  }) {
    return stopped?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StoppedCountry value)? stopped,
    TResult Function(PassingCountry value)? passing,
    TResult Function(UnvisitedCountry value)? unvisited,
    required TResult orElse(),
  }) {
    if (stopped != null) {
      return stopped(this);
    }
    return orElse();
  }
}

abstract class StoppedCountry implements CountryCard {
  const factory StoppedCountry(final CountryTime country) =
      _$StoppedCountryImpl;

  CountryTime get country;

  /// Create a copy of CountryCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoppedCountryImplCopyWith<_$StoppedCountryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PassingCountryImplCopyWith<$Res> {
  factory _$$PassingCountryImplCopyWith(
    _$PassingCountryImpl value,
    $Res Function(_$PassingCountryImpl) then,
  ) = __$$PassingCountryImplCopyWithImpl<$Res>;
  @useResult
  $Res call({CountryTime country, int thresholdSeconds});

  $CountryTimeCopyWith<$Res> get country;
}

/// @nodoc
class __$$PassingCountryImplCopyWithImpl<$Res>
    extends _$CountryCardCopyWithImpl<$Res, _$PassingCountryImpl>
    implements _$$PassingCountryImplCopyWith<$Res> {
  __$$PassingCountryImplCopyWithImpl(
    _$PassingCountryImpl _value,
    $Res Function(_$PassingCountryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CountryCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? country = null, Object? thresholdSeconds = null}) {
    return _then(
      _$PassingCountryImpl(
        null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as CountryTime,
        thresholdSeconds: null == thresholdSeconds
            ? _value.thresholdSeconds
            : thresholdSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }

  /// Create a copy of CountryCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CountryTimeCopyWith<$Res> get country {
    return $CountryTimeCopyWith<$Res>(_value.country, (value) {
      return _then(_value.copyWith(country: value));
    });
  }
}

/// @nodoc

class _$PassingCountryImpl implements PassingCountry {
  const _$PassingCountryImpl(this.country, {required this.thresholdSeconds});

  @override
  final CountryTime country;
  @override
  final int thresholdSeconds;

  @override
  String toString() {
    return 'CountryCard.passing(country: $country, thresholdSeconds: $thresholdSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PassingCountryImpl &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.thresholdSeconds, thresholdSeconds) ||
                other.thresholdSeconds == thresholdSeconds));
  }

  @override
  int get hashCode => Object.hash(runtimeType, country, thresholdSeconds);

  /// Create a copy of CountryCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PassingCountryImplCopyWith<_$PassingCountryImpl> get copyWith =>
      __$$PassingCountryImplCopyWithImpl<_$PassingCountryImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CountryTime country) stopped,
    required TResult Function(CountryTime country, int thresholdSeconds)
    passing,
    required TResult Function(String code) unvisited,
  }) {
    return passing(country, thresholdSeconds);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CountryTime country)? stopped,
    TResult? Function(CountryTime country, int thresholdSeconds)? passing,
    TResult? Function(String code)? unvisited,
  }) {
    return passing?.call(country, thresholdSeconds);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CountryTime country)? stopped,
    TResult Function(CountryTime country, int thresholdSeconds)? passing,
    TResult Function(String code)? unvisited,
    required TResult orElse(),
  }) {
    if (passing != null) {
      return passing(country, thresholdSeconds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StoppedCountry value) stopped,
    required TResult Function(PassingCountry value) passing,
    required TResult Function(UnvisitedCountry value) unvisited,
  }) {
    return passing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StoppedCountry value)? stopped,
    TResult? Function(PassingCountry value)? passing,
    TResult? Function(UnvisitedCountry value)? unvisited,
  }) {
    return passing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StoppedCountry value)? stopped,
    TResult Function(PassingCountry value)? passing,
    TResult Function(UnvisitedCountry value)? unvisited,
    required TResult orElse(),
  }) {
    if (passing != null) {
      return passing(this);
    }
    return orElse();
  }
}

abstract class PassingCountry implements CountryCard {
  const factory PassingCountry(
    final CountryTime country, {
    required final int thresholdSeconds,
  }) = _$PassingCountryImpl;

  CountryTime get country;
  int get thresholdSeconds;

  /// Create a copy of CountryCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PassingCountryImplCopyWith<_$PassingCountryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnvisitedCountryImplCopyWith<$Res> {
  factory _$$UnvisitedCountryImplCopyWith(
    _$UnvisitedCountryImpl value,
    $Res Function(_$UnvisitedCountryImpl) then,
  ) = __$$UnvisitedCountryImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String code});
}

/// @nodoc
class __$$UnvisitedCountryImplCopyWithImpl<$Res>
    extends _$CountryCardCopyWithImpl<$Res, _$UnvisitedCountryImpl>
    implements _$$UnvisitedCountryImplCopyWith<$Res> {
  __$$UnvisitedCountryImplCopyWithImpl(
    _$UnvisitedCountryImpl _value,
    $Res Function(_$UnvisitedCountryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CountryCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? code = null}) {
    return _then(
      _$UnvisitedCountryImpl(
        null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$UnvisitedCountryImpl implements UnvisitedCountry {
  const _$UnvisitedCountryImpl(this.code);

  @override
  final String code;

  @override
  String toString() {
    return 'CountryCard.unvisited(code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnvisitedCountryImpl &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, code);

  /// Create a copy of CountryCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnvisitedCountryImplCopyWith<_$UnvisitedCountryImpl> get copyWith =>
      __$$UnvisitedCountryImplCopyWithImpl<_$UnvisitedCountryImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CountryTime country) stopped,
    required TResult Function(CountryTime country, int thresholdSeconds)
    passing,
    required TResult Function(String code) unvisited,
  }) {
    return unvisited(code);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CountryTime country)? stopped,
    TResult? Function(CountryTime country, int thresholdSeconds)? passing,
    TResult? Function(String code)? unvisited,
  }) {
    return unvisited?.call(code);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CountryTime country)? stopped,
    TResult Function(CountryTime country, int thresholdSeconds)? passing,
    TResult Function(String code)? unvisited,
    required TResult orElse(),
  }) {
    if (unvisited != null) {
      return unvisited(code);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StoppedCountry value) stopped,
    required TResult Function(PassingCountry value) passing,
    required TResult Function(UnvisitedCountry value) unvisited,
  }) {
    return unvisited(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StoppedCountry value)? stopped,
    TResult? Function(PassingCountry value)? passing,
    TResult? Function(UnvisitedCountry value)? unvisited,
  }) {
    return unvisited?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StoppedCountry value)? stopped,
    TResult Function(PassingCountry value)? passing,
    TResult Function(UnvisitedCountry value)? unvisited,
    required TResult orElse(),
  }) {
    if (unvisited != null) {
      return unvisited(this);
    }
    return orElse();
  }
}

abstract class UnvisitedCountry implements CountryCard {
  const factory UnvisitedCountry(final String code) = _$UnvisitedCountryImpl;

  String get code;

  /// Create a copy of CountryCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnvisitedCountryImplCopyWith<_$UnvisitedCountryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
