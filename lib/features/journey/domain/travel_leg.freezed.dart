// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'travel_leg.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TravelLeg {
  StationPlace get from => throw _privateConstructorUsedError;
  StationPlace? get to => throw _privateConstructorUsedError;

  /// Create a copy of TravelLeg
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TravelLegCopyWith<TravelLeg> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TravelLegCopyWith<$Res> {
  factory $TravelLegCopyWith(TravelLeg value, $Res Function(TravelLeg) then) =
      _$TravelLegCopyWithImpl<$Res, TravelLeg>;
  @useResult
  $Res call({StationPlace from, StationPlace? to});

  $StationPlaceCopyWith<$Res> get from;
  $StationPlaceCopyWith<$Res>? get to;
}

/// @nodoc
class _$TravelLegCopyWithImpl<$Res, $Val extends TravelLeg>
    implements $TravelLegCopyWith<$Res> {
  _$TravelLegCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TravelLeg
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? from = null, Object? to = freezed}) {
    return _then(
      _value.copyWith(
            from: null == from
                ? _value.from
                : from // ignore: cast_nullable_to_non_nullable
                      as StationPlace,
            to: freezed == to
                ? _value.to
                : to // ignore: cast_nullable_to_non_nullable
                      as StationPlace?,
          )
          as $Val,
    );
  }

  /// Create a copy of TravelLeg
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StationPlaceCopyWith<$Res> get from {
    return $StationPlaceCopyWith<$Res>(_value.from, (value) {
      return _then(_value.copyWith(from: value) as $Val);
    });
  }

  /// Create a copy of TravelLeg
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StationPlaceCopyWith<$Res>? get to {
    if (_value.to == null) {
      return null;
    }

    return $StationPlaceCopyWith<$Res>(_value.to!, (value) {
      return _then(_value.copyWith(to: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TravelLegImplCopyWith<$Res>
    implements $TravelLegCopyWith<$Res> {
  factory _$$TravelLegImplCopyWith(
    _$TravelLegImpl value,
    $Res Function(_$TravelLegImpl) then,
  ) = __$$TravelLegImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({StationPlace from, StationPlace? to});

  @override
  $StationPlaceCopyWith<$Res> get from;
  @override
  $StationPlaceCopyWith<$Res>? get to;
}

/// @nodoc
class __$$TravelLegImplCopyWithImpl<$Res>
    extends _$TravelLegCopyWithImpl<$Res, _$TravelLegImpl>
    implements _$$TravelLegImplCopyWith<$Res> {
  __$$TravelLegImplCopyWithImpl(
    _$TravelLegImpl _value,
    $Res Function(_$TravelLegImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TravelLeg
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? from = null, Object? to = freezed}) {
    return _then(
      _$TravelLegImpl(
        from: null == from
            ? _value.from
            : from // ignore: cast_nullable_to_non_nullable
                  as StationPlace,
        to: freezed == to
            ? _value.to
            : to // ignore: cast_nullable_to_non_nullable
                  as StationPlace?,
      ),
    );
  }
}

/// @nodoc

class _$TravelLegImpl extends _TravelLeg {
  const _$TravelLegImpl({required this.from, required this.to}) : super._();

  @override
  final StationPlace from;
  @override
  final StationPlace? to;

  @override
  String toString() {
    return 'TravelLeg(from: $from, to: $to)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TravelLegImpl &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to));
  }

  @override
  int get hashCode => Object.hash(runtimeType, from, to);

  /// Create a copy of TravelLeg
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TravelLegImplCopyWith<_$TravelLegImpl> get copyWith =>
      __$$TravelLegImplCopyWithImpl<_$TravelLegImpl>(this, _$identity);
}

abstract class _TravelLeg extends TravelLeg {
  const factory _TravelLeg({
    required final StationPlace from,
    required final StationPlace? to,
  }) = _$TravelLegImpl;
  const _TravelLeg._() : super._();

  @override
  StationPlace get from;
  @override
  StationPlace? get to;

  /// Create a copy of TravelLeg
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TravelLegImplCopyWith<_$TravelLegImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
