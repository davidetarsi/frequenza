// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorites_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FavoritesState {
  List<RadioStation> get stations => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSaving => throw _privateConstructorUsedError;
  bool get hasError => throw _privateConstructorUsedError;
  bool get hasLoaded => throw _privateConstructorUsedError;

  /// Create a copy of FavoritesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FavoritesStateCopyWith<FavoritesState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FavoritesStateCopyWith<$Res> {
  factory $FavoritesStateCopyWith(
    FavoritesState value,
    $Res Function(FavoritesState) then,
  ) = _$FavoritesStateCopyWithImpl<$Res, FavoritesState>;
  @useResult
  $Res call({
    List<RadioStation> stations,
    bool isLoading,
    bool isSaving,
    bool hasError,
    bool hasLoaded,
  });
}

/// @nodoc
class _$FavoritesStateCopyWithImpl<$Res, $Val extends FavoritesState>
    implements $FavoritesStateCopyWith<$Res> {
  _$FavoritesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FavoritesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stations = null,
    Object? isLoading = null,
    Object? isSaving = null,
    Object? hasError = null,
    Object? hasLoaded = null,
  }) {
    return _then(
      _value.copyWith(
            stations: null == stations
                ? _value.stations
                : stations // ignore: cast_nullable_to_non_nullable
                      as List<RadioStation>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSaving: null == isSaving
                ? _value.isSaving
                : isSaving // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasError: null == hasError
                ? _value.hasError
                : hasError // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasLoaded: null == hasLoaded
                ? _value.hasLoaded
                : hasLoaded // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FavoritesStateImplCopyWith<$Res>
    implements $FavoritesStateCopyWith<$Res> {
  factory _$$FavoritesStateImplCopyWith(
    _$FavoritesStateImpl value,
    $Res Function(_$FavoritesStateImpl) then,
  ) = __$$FavoritesStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<RadioStation> stations,
    bool isLoading,
    bool isSaving,
    bool hasError,
    bool hasLoaded,
  });
}

/// @nodoc
class __$$FavoritesStateImplCopyWithImpl<$Res>
    extends _$FavoritesStateCopyWithImpl<$Res, _$FavoritesStateImpl>
    implements _$$FavoritesStateImplCopyWith<$Res> {
  __$$FavoritesStateImplCopyWithImpl(
    _$FavoritesStateImpl _value,
    $Res Function(_$FavoritesStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FavoritesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stations = null,
    Object? isLoading = null,
    Object? isSaving = null,
    Object? hasError = null,
    Object? hasLoaded = null,
  }) {
    return _then(
      _$FavoritesStateImpl(
        stations: null == stations
            ? _value._stations
            : stations // ignore: cast_nullable_to_non_nullable
                  as List<RadioStation>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSaving: null == isSaving
            ? _value.isSaving
            : isSaving // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasError: null == hasError
            ? _value.hasError
            : hasError // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasLoaded: null == hasLoaded
            ? _value.hasLoaded
            : hasLoaded // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$FavoritesStateImpl extends _FavoritesState {
  const _$FavoritesStateImpl({
    final List<RadioStation> stations = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.hasError = false,
    this.hasLoaded = false,
  }) : _stations = stations,
       super._();

  final List<RadioStation> _stations;
  @override
  @JsonKey()
  List<RadioStation> get stations {
    if (_stations is EqualUnmodifiableListView) return _stations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stations);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSaving;
  @override
  @JsonKey()
  final bool hasError;
  @override
  @JsonKey()
  final bool hasLoaded;

  @override
  String toString() {
    return 'FavoritesState(stations: $stations, isLoading: $isLoading, isSaving: $isSaving, hasError: $hasError, hasLoaded: $hasLoaded)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FavoritesStateImpl &&
            const DeepCollectionEquality().equals(other._stations, _stations) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.hasLoaded, hasLoaded) ||
                other.hasLoaded == hasLoaded));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_stations),
    isLoading,
    isSaving,
    hasError,
    hasLoaded,
  );

  /// Create a copy of FavoritesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FavoritesStateImplCopyWith<_$FavoritesStateImpl> get copyWith =>
      __$$FavoritesStateImplCopyWithImpl<_$FavoritesStateImpl>(
        this,
        _$identity,
      );
}

abstract class _FavoritesState extends FavoritesState {
  const factory _FavoritesState({
    final List<RadioStation> stations,
    final bool isLoading,
    final bool isSaving,
    final bool hasError,
    final bool hasLoaded,
  }) = _$FavoritesStateImpl;
  const _FavoritesState._() : super._();

  @override
  List<RadioStation> get stations;
  @override
  bool get isLoading;
  @override
  bool get isSaving;
  @override
  bool get hasError;
  @override
  bool get hasLoaded;

  /// Create a copy of FavoritesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FavoritesStateImplCopyWith<_$FavoritesStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
