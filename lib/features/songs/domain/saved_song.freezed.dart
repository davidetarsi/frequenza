// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_song.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SavedSong _$SavedSongFromJson(Map<String, dynamic> json) {
  return _SavedSong.fromJson(json);
}

/// @nodoc
mixin _$SavedSong {
  @JsonKey(fromJson: _text)
  String? get artist => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @StationRecordConverter()
  RadioStation get station => throw _privateConstructorUsedError;
  @JsonKey(name: 'at', toJson: _utc)
  DateTime get savedAt => throw _privateConstructorUsedError;

  /// Serializes this SavedSong to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SavedSong
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SavedSongCopyWith<SavedSong> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavedSongCopyWith<$Res> {
  factory $SavedSongCopyWith(SavedSong value, $Res Function(SavedSong) then) =
      _$SavedSongCopyWithImpl<$Res, SavedSong>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _text) String? artist,
    String title,
    @StationRecordConverter() RadioStation station,
    @JsonKey(name: 'at', toJson: _utc) DateTime savedAt,
  });

  $RadioStationCopyWith<$Res> get station;
}

/// @nodoc
class _$SavedSongCopyWithImpl<$Res, $Val extends SavedSong>
    implements $SavedSongCopyWith<$Res> {
  _$SavedSongCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SavedSong
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? artist = freezed,
    Object? title = null,
    Object? station = null,
    Object? savedAt = null,
  }) {
    return _then(
      _value.copyWith(
            artist: freezed == artist
                ? _value.artist
                : artist // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            station: null == station
                ? _value.station
                : station // ignore: cast_nullable_to_non_nullable
                      as RadioStation,
            savedAt: null == savedAt
                ? _value.savedAt
                : savedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of SavedSong
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
abstract class _$$SavedSongImplCopyWith<$Res>
    implements $SavedSongCopyWith<$Res> {
  factory _$$SavedSongImplCopyWith(
    _$SavedSongImpl value,
    $Res Function(_$SavedSongImpl) then,
  ) = __$$SavedSongImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _text) String? artist,
    String title,
    @StationRecordConverter() RadioStation station,
    @JsonKey(name: 'at', toJson: _utc) DateTime savedAt,
  });

  @override
  $RadioStationCopyWith<$Res> get station;
}

/// @nodoc
class __$$SavedSongImplCopyWithImpl<$Res>
    extends _$SavedSongCopyWithImpl<$Res, _$SavedSongImpl>
    implements _$$SavedSongImplCopyWith<$Res> {
  __$$SavedSongImplCopyWithImpl(
    _$SavedSongImpl _value,
    $Res Function(_$SavedSongImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SavedSong
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? artist = freezed,
    Object? title = null,
    Object? station = null,
    Object? savedAt = null,
  }) {
    return _then(
      _$SavedSongImpl(
        artist: freezed == artist
            ? _value.artist
            : artist // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        station: null == station
            ? _value.station
            : station // ignore: cast_nullable_to_non_nullable
                  as RadioStation,
        savedAt: null == savedAt
            ? _value.savedAt
            : savedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$SavedSongImpl extends _SavedSong {
  const _$SavedSongImpl({
    @JsonKey(fromJson: _text) this.artist,
    required this.title,
    @StationRecordConverter() required this.station,
    @JsonKey(name: 'at', toJson: _utc) required this.savedAt,
  }) : super._();

  factory _$SavedSongImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavedSongImplFromJson(json);

  @override
  @JsonKey(fromJson: _text)
  final String? artist;
  @override
  final String title;
  @override
  @StationRecordConverter()
  final RadioStation station;
  @override
  @JsonKey(name: 'at', toJson: _utc)
  final DateTime savedAt;

  @override
  String toString() {
    return 'SavedSong(artist: $artist, title: $title, station: $station, savedAt: $savedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavedSongImpl &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.station, station) || other.station == station) &&
            (identical(other.savedAt, savedAt) || other.savedAt == savedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, artist, title, station, savedAt);

  /// Create a copy of SavedSong
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SavedSongImplCopyWith<_$SavedSongImpl> get copyWith =>
      __$$SavedSongImplCopyWithImpl<_$SavedSongImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SavedSongImplToJson(this);
  }
}

abstract class _SavedSong extends SavedSong {
  const factory _SavedSong({
    @JsonKey(fromJson: _text) final String? artist,
    required final String title,
    @StationRecordConverter() required final RadioStation station,
    @JsonKey(name: 'at', toJson: _utc) required final DateTime savedAt,
  }) = _$SavedSongImpl;
  const _SavedSong._() : super._();

  factory _SavedSong.fromJson(Map<String, dynamic> json) =
      _$SavedSongImpl.fromJson;

  @override
  @JsonKey(fromJson: _text)
  String? get artist;
  @override
  String get title;
  @override
  @StationRecordConverter()
  RadioStation get station;
  @override
  @JsonKey(name: 'at', toJson: _utc)
  DateTime get savedAt;

  /// Create a copy of SavedSong
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SavedSongImplCopyWith<_$SavedSongImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
