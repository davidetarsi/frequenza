// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'journey.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Journey {
  /// Where the next flight leaves from: the last placed landing.
  StationPlace get departure => throw _privateConstructorUsedError;

  /// The leg that brought the radio to the station on air.
  TravelLeg? get leg => throw _privateConstructorUsedError;

  /// The last placed legs of this session, oldest first.
  List<TravelLeg> get history => throw _privateConstructorUsedError;
  int get trips => throw _privateConstructorUsedError;

  /// Stations left behind by forward flights, oldest first: where the
  /// notification's back key returns.
  List<RadioStation> get previous => throw _privateConstructorUsedError;

  /// The last station that landed, kept while a back or reconnect flight
  /// hides it.
  RadioStation? get landed => throw _privateConstructorUsedError;

  /// Create a copy of Journey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JourneyCopyWith<Journey> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JourneyCopyWith<$Res> {
  factory $JourneyCopyWith(Journey value, $Res Function(Journey) then) =
      _$JourneyCopyWithImpl<$Res, Journey>;
  @useResult
  $Res call({
    StationPlace departure,
    TravelLeg? leg,
    List<TravelLeg> history,
    int trips,
    List<RadioStation> previous,
    RadioStation? landed,
  });

  $StationPlaceCopyWith<$Res> get departure;
  $TravelLegCopyWith<$Res>? get leg;
  $RadioStationCopyWith<$Res>? get landed;
}

/// @nodoc
class _$JourneyCopyWithImpl<$Res, $Val extends Journey>
    implements $JourneyCopyWith<$Res> {
  _$JourneyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Journey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? departure = null,
    Object? leg = freezed,
    Object? history = null,
    Object? trips = null,
    Object? previous = null,
    Object? landed = freezed,
  }) {
    return _then(
      _value.copyWith(
            departure: null == departure
                ? _value.departure
                : departure // ignore: cast_nullable_to_non_nullable
                      as StationPlace,
            leg: freezed == leg
                ? _value.leg
                : leg // ignore: cast_nullable_to_non_nullable
                      as TravelLeg?,
            history: null == history
                ? _value.history
                : history // ignore: cast_nullable_to_non_nullable
                      as List<TravelLeg>,
            trips: null == trips
                ? _value.trips
                : trips // ignore: cast_nullable_to_non_nullable
                      as int,
            previous: null == previous
                ? _value.previous
                : previous // ignore: cast_nullable_to_non_nullable
                      as List<RadioStation>,
            landed: freezed == landed
                ? _value.landed
                : landed // ignore: cast_nullable_to_non_nullable
                      as RadioStation?,
          )
          as $Val,
    );
  }

  /// Create a copy of Journey
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StationPlaceCopyWith<$Res> get departure {
    return $StationPlaceCopyWith<$Res>(_value.departure, (value) {
      return _then(_value.copyWith(departure: value) as $Val);
    });
  }

  /// Create a copy of Journey
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TravelLegCopyWith<$Res>? get leg {
    if (_value.leg == null) {
      return null;
    }

    return $TravelLegCopyWith<$Res>(_value.leg!, (value) {
      return _then(_value.copyWith(leg: value) as $Val);
    });
  }

  /// Create a copy of Journey
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RadioStationCopyWith<$Res>? get landed {
    if (_value.landed == null) {
      return null;
    }

    return $RadioStationCopyWith<$Res>(_value.landed!, (value) {
      return _then(_value.copyWith(landed: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$JourneyImplCopyWith<$Res> implements $JourneyCopyWith<$Res> {
  factory _$$JourneyImplCopyWith(
    _$JourneyImpl value,
    $Res Function(_$JourneyImpl) then,
  ) = __$$JourneyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    StationPlace departure,
    TravelLeg? leg,
    List<TravelLeg> history,
    int trips,
    List<RadioStation> previous,
    RadioStation? landed,
  });

  @override
  $StationPlaceCopyWith<$Res> get departure;
  @override
  $TravelLegCopyWith<$Res>? get leg;
  @override
  $RadioStationCopyWith<$Res>? get landed;
}

/// @nodoc
class __$$JourneyImplCopyWithImpl<$Res>
    extends _$JourneyCopyWithImpl<$Res, _$JourneyImpl>
    implements _$$JourneyImplCopyWith<$Res> {
  __$$JourneyImplCopyWithImpl(
    _$JourneyImpl _value,
    $Res Function(_$JourneyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Journey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? departure = null,
    Object? leg = freezed,
    Object? history = null,
    Object? trips = null,
    Object? previous = null,
    Object? landed = freezed,
  }) {
    return _then(
      _$JourneyImpl(
        departure: null == departure
            ? _value.departure
            : departure // ignore: cast_nullable_to_non_nullable
                  as StationPlace,
        leg: freezed == leg
            ? _value.leg
            : leg // ignore: cast_nullable_to_non_nullable
                  as TravelLeg?,
        history: null == history
            ? _value._history
            : history // ignore: cast_nullable_to_non_nullable
                  as List<TravelLeg>,
        trips: null == trips
            ? _value.trips
            : trips // ignore: cast_nullable_to_non_nullable
                  as int,
        previous: null == previous
            ? _value._previous
            : previous // ignore: cast_nullable_to_non_nullable
                  as List<RadioStation>,
        landed: freezed == landed
            ? _value.landed
            : landed // ignore: cast_nullable_to_non_nullable
                  as RadioStation?,
      ),
    );
  }
}

/// @nodoc

class _$JourneyImpl extends _Journey {
  const _$JourneyImpl({
    this.departure = homePlace,
    this.leg,
    final List<TravelLeg> history = const <TravelLeg>[],
    this.trips = 0,
    final List<RadioStation> previous = const <RadioStation>[],
    this.landed,
  }) : _history = history,
       _previous = previous,
       super._();

  /// Where the next flight leaves from: the last placed landing.
  @override
  @JsonKey()
  final StationPlace departure;

  /// The leg that brought the radio to the station on air.
  @override
  final TravelLeg? leg;

  /// The last placed legs of this session, oldest first.
  final List<TravelLeg> _history;

  /// The last placed legs of this session, oldest first.
  @override
  @JsonKey()
  List<TravelLeg> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  @override
  @JsonKey()
  final int trips;

  /// Stations left behind by forward flights, oldest first: where the
  /// notification's back key returns.
  final List<RadioStation> _previous;

  /// Stations left behind by forward flights, oldest first: where the
  /// notification's back key returns.
  @override
  @JsonKey()
  List<RadioStation> get previous {
    if (_previous is EqualUnmodifiableListView) return _previous;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_previous);
  }

  /// The last station that landed, kept while a back or reconnect flight
  /// hides it.
  @override
  final RadioStation? landed;

  @override
  String toString() {
    return 'Journey(departure: $departure, leg: $leg, history: $history, trips: $trips, previous: $previous, landed: $landed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JourneyImpl &&
            (identical(other.departure, departure) ||
                other.departure == departure) &&
            (identical(other.leg, leg) || other.leg == leg) &&
            const DeepCollectionEquality().equals(other._history, _history) &&
            (identical(other.trips, trips) || other.trips == trips) &&
            const DeepCollectionEquality().equals(other._previous, _previous) &&
            (identical(other.landed, landed) || other.landed == landed));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    departure,
    leg,
    const DeepCollectionEquality().hash(_history),
    trips,
    const DeepCollectionEquality().hash(_previous),
    landed,
  );

  /// Create a copy of Journey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JourneyImplCopyWith<_$JourneyImpl> get copyWith =>
      __$$JourneyImplCopyWithImpl<_$JourneyImpl>(this, _$identity);
}

abstract class _Journey extends Journey {
  const factory _Journey({
    final StationPlace departure,
    final TravelLeg? leg,
    final List<TravelLeg> history,
    final int trips,
    final List<RadioStation> previous,
    final RadioStation? landed,
  }) = _$JourneyImpl;
  const _Journey._() : super._();

  /// Where the next flight leaves from: the last placed landing.
  @override
  StationPlace get departure;

  /// The leg that brought the radio to the station on air.
  @override
  TravelLeg? get leg;

  /// The last placed legs of this session, oldest first.
  @override
  List<TravelLeg> get history;
  @override
  int get trips;

  /// Stations left behind by forward flights, oldest first: where the
  /// notification's back key returns.
  @override
  List<RadioStation> get previous;

  /// The last station that landed, kept while a back or reconnect flight
  /// hides it.
  @override
  RadioStation? get landed;

  /// Create a copy of Journey
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JourneyImplCopyWith<_$JourneyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
