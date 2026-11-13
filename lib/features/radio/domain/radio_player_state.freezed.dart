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
  FlightPhase get flight => throw _privateConstructorUsedError;

  /// Where the next flight leaves from: the last placed landing.
  StationPlace get departure => throw _privateConstructorUsedError;

  /// The leg that brought the radio to [station].
  TravelLeg? get leg => throw _privateConstructorUsedError;

  /// The last placed legs of this session, oldest first.
  List<TravelLeg> get history => throw _privateConstructorUsedError;
  int get trips => throw _privateConstructorUsedError;

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
    FlightPhase flight,
    StationPlace departure,
    TravelLeg? leg,
    List<TravelLeg> history,
    int trips,
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
    Object? flight = null,
    Object? departure = null,
    Object? leg = freezed,
    Object? history = null,
    Object? trips = null,
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
    FlightPhase flight,
    StationPlace departure,
    TravelLeg? leg,
    List<TravelLeg> history,
    int trips,
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
    Object? flight = null,
    Object? departure = null,
    Object? leg = freezed,
    Object? history = null,
    Object? trips = null,
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
    this.flight = FlightPhase.grounded,
    this.departure = homePlace,
    this.leg,
    final List<TravelLeg> history = const <TravelLeg>[],
    this.trips = 0,
  }) : _history = history,
       super._();

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

  @override
  String toString() {
    return 'RadioPlayerState(status: $status, station: $station, errorMessage: $errorMessage, trackTitle: $trackTitle, flight: $flight, departure: $departure, leg: $leg, history: $history, trips: $trips)';
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
                other.trackTitle == trackTitle) &&
            (identical(other.flight, flight) || other.flight == flight) &&
            (identical(other.departure, departure) ||
                other.departure == departure) &&
            (identical(other.leg, leg) || other.leg == leg) &&
            const DeepCollectionEquality().equals(other._history, _history) &&
            (identical(other.trips, trips) || other.trips == trips));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    station,
    errorMessage,
    trackTitle,
    flight,
    departure,
    leg,
    const DeepCollectionEquality().hash(_history),
    trips,
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
    final String? errorMessage,
    final String? trackTitle,
    final FlightPhase flight,
    final StationPlace departure,
    final TravelLeg? leg,
    final List<TravelLeg> history,
    final int trips,
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

  /// Create a copy of RadioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RadioPlayerStateImplCopyWith<_$RadioPlayerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
