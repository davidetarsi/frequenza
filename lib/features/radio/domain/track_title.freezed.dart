// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track_title.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TrackTitle {
  String get title => throw _privateConstructorUsedError;
  String? get artist => throw _privateConstructorUsedError;

  /// Create a copy of TrackTitle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackTitleCopyWith<TrackTitle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackTitleCopyWith<$Res> {
  factory $TrackTitleCopyWith(
    TrackTitle value,
    $Res Function(TrackTitle) then,
  ) = _$TrackTitleCopyWithImpl<$Res, TrackTitle>;
  @useResult
  $Res call({String title, String? artist});
}

/// @nodoc
class _$TrackTitleCopyWithImpl<$Res, $Val extends TrackTitle>
    implements $TrackTitleCopyWith<$Res> {
  _$TrackTitleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrackTitle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? title = null, Object? artist = freezed}) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            artist: freezed == artist
                ? _value.artist
                : artist // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrackTitleImplCopyWith<$Res>
    implements $TrackTitleCopyWith<$Res> {
  factory _$$TrackTitleImplCopyWith(
    _$TrackTitleImpl value,
    $Res Function(_$TrackTitleImpl) then,
  ) = __$$TrackTitleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, String? artist});
}

/// @nodoc
class __$$TrackTitleImplCopyWithImpl<$Res>
    extends _$TrackTitleCopyWithImpl<$Res, _$TrackTitleImpl>
    implements _$$TrackTitleImplCopyWith<$Res> {
  __$$TrackTitleImplCopyWithImpl(
    _$TrackTitleImpl _value,
    $Res Function(_$TrackTitleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrackTitle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? title = null, Object? artist = freezed}) {
    return _then(
      _$TrackTitleImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        artist: freezed == artist
            ? _value.artist
            : artist // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$TrackTitleImpl extends _TrackTitle {
  const _$TrackTitleImpl({required this.title, this.artist}) : super._();

  @override
  final String title;
  @override
  final String? artist;

  @override
  String toString() {
    return 'TrackTitle(title: $title, artist: $artist)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackTitleImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artist, artist) || other.artist == artist));
  }

  @override
  int get hashCode => Object.hash(runtimeType, title, artist);

  /// Create a copy of TrackTitle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackTitleImplCopyWith<_$TrackTitleImpl> get copyWith =>
      __$$TrackTitleImplCopyWithImpl<_$TrackTitleImpl>(this, _$identity);
}

abstract class _TrackTitle extends TrackTitle {
  const factory _TrackTitle({
    required final String title,
    final String? artist,
  }) = _$TrackTitleImpl;
  const _TrackTitle._() : super._();

  @override
  String get title;
  @override
  String? get artist;

  /// Create a copy of TrackTitle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackTitleImplCopyWith<_$TrackTitleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
