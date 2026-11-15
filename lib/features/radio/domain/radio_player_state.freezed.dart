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
  String? get trackTitle => throw _privateConstructorUsedError;
  FlightPhase get flight => throw _privateConstructorUsedError;

  /// Where the next flight leaves from: the last placed landing.
  StationPlace get departure => throw _privateConstructorUsedError;

  /// The leg that brought the radio to [station].
  TravelLeg? get leg => throw _privateConstructorUsedError;

  /// The last placed legs of this session, oldest first.
  List<TravelLeg> get history => throw _privateConstructorUsedError;
  int get trips => throw _privateConstructorUsedError;

  /// Stations left behind by forward flights, oldest first: where the
  /// notification's back key returns.
  List<RadioStation> get previous => throw _privateConstructorUsedError;

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
    String? trackTitle,
    FlightPhase flight,
    StationPlace departure,
    TravelLeg? leg,
    List<TravelLeg> history,
    int trips,
    List<RadioStation> previous,
  });

  $RadioStationCopyWith<$Res>? get station;
  $StationPlaceCopyWith<$Res> get departure;
  $TravelLegCopyWith<$Res>? get leg;
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
    Object? trackTitle = freezed,
    Object? flight = null,
    Object? departure = null,
    Object? leg = freezed,
    Object? history = null,
    Object? trips = null,
    Object? previous = null,
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
            trackTitle: freezed == trackTitle
                ? _value.trackTitle
                : trackTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            flight: null == flight
                ? _value.flight
                : flight // ignore: cast_nullable_to_non_nullable
                      as FlightPhase,
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

  /// Create a copy of RadioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StationPlaceCopyWith<$Res> get departure {
    return $StationPlaceCopyWith<$Res>(_value.departure, (value) {
      return _then(_value.copyWith(departure: value) as $Val);
    });
  }

  /// Create a copy of RadioPlayerState
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
    String? trackTitle,
    FlightPhase flight,
    StationPlace departure,
    TravelLeg? leg,
    List<TravelLeg> history,
    int trips,
    List<RadioStation> previous,
  });

  @override
  $RadioStationCopyWith<$Res>? get station;
  @override
  $StationPlaceCopyWith<$Res> get departure;
  @override
  $TravelLegCopyWith<$Res>? get leg;
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
    Object? trackTitle = freezed,
    Object? flight = null,
    Object? departure = null,
    Object? leg = freezed,
    Object? history = null,
    Object? trips = null,
    Object? previous = null,
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
        trackTitle: freezed == trackTitle
            ? _value.trackTitle
            : trackTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        flight: null == flight
            ? _value.flight
            : flight // ignore: cast_nullable_to_non_nullable
                  as FlightPhase,
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
      ),
    );
  }
}

/// @nodoc

class _$RadioPlayerStateImpl extends _RadioPlayerState {
  const _$RadioPlayerStateImpl({
    this.status = PlaybackStatus.idle,
    this.station,
    this.trackTitle,
    this.flight = FlightPhase.grounded,
    this.departure = homePlace,
    this.leg,
    final List<TravelLeg> history = const <TravelLeg>[],
    this.trips = 0,
    final List<RadioStation> previous = const <RadioStation>[],
  }) : _history = history,
       _previous = previous,
       super._();

  @override
  @JsonKey()
  final PlaybackStatus status;
  @override
  final RadioStation? station;
  @override
  final String? trackTitle;
  @override
  @JsonKey()
  final FlightPhase flight;

  /// Where the next flight leaves from: the last placed landing.
  @override
  @JsonKey()
  final StationPlace departure;

  /// The leg that brought the radio to [station].
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

  @override
  String toString() {
    return 'RadioPlayerState(status: $status, station: $station, trackTitle: $trackTitle, flight: $flight, departure: $departure, leg: $leg, history: $history, trips: $trips, previous: $previous)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RadioPlayerStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.station, station) || other.station == station) &&
            (identical(other.trackTitle, trackTitle) ||
                other.trackTitle == trackTitle) &&
            (identical(other.flight, flight) || other.flight == flight) &&
            (identical(other.departure, departure) ||
                other.departure == departure) &&
            (identical(other.leg, leg) || other.leg == leg) &&
            const DeepCollectionEquality().equals(other._history, _history) &&
            (identical(other.trips, trips) || other.trips == trips) &&
            const DeepCollectionEquality().equals(other._previous, _previous));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    station,
    trackTitle,
    flight,
    departure,
    leg,
    const DeepCollectionEquality().hash(_history),
    trips,
    const DeepCollectionEquality().hash(_previous),
  );

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
    final String? trackTitle,
    final FlightPhase flight,
    final StationPlace departure,
    final TravelLeg? leg,
    final List<TravelLeg> history,
    final int trips,
    final List<RadioStation> previous,
  }) = _$RadioPlayerStateImpl;
  const _RadioPlayerState._() : super._();

  @override
  PlaybackStatus get status;
  @override
  RadioStation? get station;
  @override
  String? get trackTitle;
  @override
  FlightPhase get flight;

  /// Where the next flight leaves from: the last placed landing.
  @override
  StationPlace get departure;

  /// The leg that brought the radio to [station].
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

  /// Create a copy of RadioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RadioPlayerStateImplCopyWith<_$RadioPlayerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
