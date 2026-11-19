// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'radio_display.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DisplayText {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String key) translated,
    required TResult Function(String text) verbatim,
    required TResult Function(String code, String? fallback) country,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String key)? translated,
    TResult? Function(String text)? verbatim,
    TResult? Function(String code, String? fallback)? country,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String key)? translated,
    TResult Function(String text)? verbatim,
    TResult Function(String code, String? fallback)? country,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Translated value) translated,
    required TResult Function(Verbatim value) verbatim,
    required TResult Function(CountryText value) country,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Translated value)? translated,
    TResult? Function(Verbatim value)? verbatim,
    TResult? Function(CountryText value)? country,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Translated value)? translated,
    TResult Function(Verbatim value)? verbatim,
    TResult Function(CountryText value)? country,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DisplayTextCopyWith<$Res> {
  factory $DisplayTextCopyWith(
    DisplayText value,
    $Res Function(DisplayText) then,
  ) = _$DisplayTextCopyWithImpl<$Res, DisplayText>;
}

/// @nodoc
class _$DisplayTextCopyWithImpl<$Res, $Val extends DisplayText>
    implements $DisplayTextCopyWith<$Res> {
  _$DisplayTextCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DisplayText
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$TranslatedImplCopyWith<$Res> {
  factory _$$TranslatedImplCopyWith(
    _$TranslatedImpl value,
    $Res Function(_$TranslatedImpl) then,
  ) = __$$TranslatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String key});
}

/// @nodoc
class __$$TranslatedImplCopyWithImpl<$Res>
    extends _$DisplayTextCopyWithImpl<$Res, _$TranslatedImpl>
    implements _$$TranslatedImplCopyWith<$Res> {
  __$$TranslatedImplCopyWithImpl(
    _$TranslatedImpl _value,
    $Res Function(_$TranslatedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DisplayText
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? key = null}) {
    return _then(
      _$TranslatedImpl(
        null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$TranslatedImpl implements Translated {
  const _$TranslatedImpl(this.key);

  @override
  final String key;

  @override
  String toString() {
    return 'DisplayText.translated(key: $key)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranslatedImpl &&
            (identical(other.key, key) || other.key == key));
  }

  @override
  int get hashCode => Object.hash(runtimeType, key);

  /// Create a copy of DisplayText
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TranslatedImplCopyWith<_$TranslatedImpl> get copyWith =>
      __$$TranslatedImplCopyWithImpl<_$TranslatedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String key) translated,
    required TResult Function(String text) verbatim,
    required TResult Function(String code, String? fallback) country,
  }) {
    return translated(key);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String key)? translated,
    TResult? Function(String text)? verbatim,
    TResult? Function(String code, String? fallback)? country,
  }) {
    return translated?.call(key);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String key)? translated,
    TResult Function(String text)? verbatim,
    TResult Function(String code, String? fallback)? country,
    required TResult orElse(),
  }) {
    if (translated != null) {
      return translated(key);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Translated value) translated,
    required TResult Function(Verbatim value) verbatim,
    required TResult Function(CountryText value) country,
  }) {
    return translated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Translated value)? translated,
    TResult? Function(Verbatim value)? verbatim,
    TResult? Function(CountryText value)? country,
  }) {
    return translated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Translated value)? translated,
    TResult Function(Verbatim value)? verbatim,
    TResult Function(CountryText value)? country,
    required TResult orElse(),
  }) {
    if (translated != null) {
      return translated(this);
    }
    return orElse();
  }
}

abstract class Translated implements DisplayText {
  const factory Translated(final String key) = _$TranslatedImpl;

  String get key;

  /// Create a copy of DisplayText
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TranslatedImplCopyWith<_$TranslatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VerbatimImplCopyWith<$Res> {
  factory _$$VerbatimImplCopyWith(
    _$VerbatimImpl value,
    $Res Function(_$VerbatimImpl) then,
  ) = __$$VerbatimImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String text});
}

/// @nodoc
class __$$VerbatimImplCopyWithImpl<$Res>
    extends _$DisplayTextCopyWithImpl<$Res, _$VerbatimImpl>
    implements _$$VerbatimImplCopyWith<$Res> {
  __$$VerbatimImplCopyWithImpl(
    _$VerbatimImpl _value,
    $Res Function(_$VerbatimImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DisplayText
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? text = null}) {
    return _then(
      _$VerbatimImpl(
        null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$VerbatimImpl implements Verbatim {
  const _$VerbatimImpl(this.text);

  @override
  final String text;

  @override
  String toString() {
    return 'DisplayText.verbatim(text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerbatimImpl &&
            (identical(other.text, text) || other.text == text));
  }

  @override
  int get hashCode => Object.hash(runtimeType, text);

  /// Create a copy of DisplayText
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerbatimImplCopyWith<_$VerbatimImpl> get copyWith =>
      __$$VerbatimImplCopyWithImpl<_$VerbatimImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String key) translated,
    required TResult Function(String text) verbatim,
    required TResult Function(String code, String? fallback) country,
  }) {
    return verbatim(text);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String key)? translated,
    TResult? Function(String text)? verbatim,
    TResult? Function(String code, String? fallback)? country,
  }) {
    return verbatim?.call(text);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String key)? translated,
    TResult Function(String text)? verbatim,
    TResult Function(String code, String? fallback)? country,
    required TResult orElse(),
  }) {
    if (verbatim != null) {
      return verbatim(text);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Translated value) translated,
    required TResult Function(Verbatim value) verbatim,
    required TResult Function(CountryText value) country,
  }) {
    return verbatim(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Translated value)? translated,
    TResult? Function(Verbatim value)? verbatim,
    TResult? Function(CountryText value)? country,
  }) {
    return verbatim?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Translated value)? translated,
    TResult Function(Verbatim value)? verbatim,
    TResult Function(CountryText value)? country,
    required TResult orElse(),
  }) {
    if (verbatim != null) {
      return verbatim(this);
    }
    return orElse();
  }
}

abstract class Verbatim implements DisplayText {
  const factory Verbatim(final String text) = _$VerbatimImpl;

  String get text;

  /// Create a copy of DisplayText
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerbatimImplCopyWith<_$VerbatimImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CountryTextImplCopyWith<$Res> {
  factory _$$CountryTextImplCopyWith(
    _$CountryTextImpl value,
    $Res Function(_$CountryTextImpl) then,
  ) = __$$CountryTextImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String code, String? fallback});
}

/// @nodoc
class __$$CountryTextImplCopyWithImpl<$Res>
    extends _$DisplayTextCopyWithImpl<$Res, _$CountryTextImpl>
    implements _$$CountryTextImplCopyWith<$Res> {
  __$$CountryTextImplCopyWithImpl(
    _$CountryTextImpl _value,
    $Res Function(_$CountryTextImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DisplayText
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? code = null, Object? fallback = freezed}) {
    return _then(
      _$CountryTextImpl(
        null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        fallback: freezed == fallback
            ? _value.fallback
            : fallback // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$CountryTextImpl implements CountryText {
  const _$CountryTextImpl(this.code, {this.fallback});

  @override
  final String code;
  @override
  final String? fallback;

  @override
  String toString() {
    return 'DisplayText.country(code: $code, fallback: $fallback)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CountryTextImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.fallback, fallback) ||
                other.fallback == fallback));
  }

  @override
  int get hashCode => Object.hash(runtimeType, code, fallback);

  /// Create a copy of DisplayText
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CountryTextImplCopyWith<_$CountryTextImpl> get copyWith =>
      __$$CountryTextImplCopyWithImpl<_$CountryTextImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String key) translated,
    required TResult Function(String text) verbatim,
    required TResult Function(String code, String? fallback) country,
  }) {
    return country(code, fallback);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String key)? translated,
    TResult? Function(String text)? verbatim,
    TResult? Function(String code, String? fallback)? country,
  }) {
    return country?.call(code, fallback);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String key)? translated,
    TResult Function(String text)? verbatim,
    TResult Function(String code, String? fallback)? country,
    required TResult orElse(),
  }) {
    if (country != null) {
      return country(code, fallback);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Translated value) translated,
    required TResult Function(Verbatim value) verbatim,
    required TResult Function(CountryText value) country,
  }) {
    return country(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Translated value)? translated,
    TResult? Function(Verbatim value)? verbatim,
    TResult? Function(CountryText value)? country,
  }) {
    return country?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Translated value)? translated,
    TResult Function(Verbatim value)? verbatim,
    TResult Function(CountryText value)? country,
    required TResult orElse(),
  }) {
    if (country != null) {
      return country(this);
    }
    return orElse();
  }
}

abstract class CountryText implements DisplayText {
  const factory CountryText(final String code, {final String? fallback}) =
      _$CountryTextImpl;

  String get code;
  String? get fallback;

  /// Create a copy of DisplayText
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CountryTextImplCopyWith<_$CountryTextImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RadioDisplay {
  DisplayText get title => throw _privateConstructorUsedError;
  DisplayText get country => throw _privateConstructorUsedError;
  String get statusKey => throw _privateConstructorUsedError;
  String get knobKey => throw _privateConstructorUsedError;
  FlightPhase get phase => throw _privateConstructorUsedError;
  RadioStation? get station => throw _privateConstructorUsedError;
  TravelLeg? get leg => throw _privateConstructorUsedError;
  TrackTitle? get track => throw _privateConstructorUsedError;
  bool get busy => throw _privateConstructorUsedError;
  bool get flying => throw _privateConstructorUsedError;
  bool get playing => throw _privateConstructorUsedError;
  bool get knobEnabled => throw _privateConstructorUsedError;
  bool get playKeyEnabled => throw _privateConstructorUsedError;
  bool get playKeyOn => throw _privateConstructorUsedError;
  bool get playKeyDown => throw _privateConstructorUsedError;
  bool get saveEnabled => throw _privateConstructorUsedError;
  bool get nextStopPending => throw _privateConstructorUsedError;

  /// Create a copy of RadioDisplay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RadioDisplayCopyWith<RadioDisplay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RadioDisplayCopyWith<$Res> {
  factory $RadioDisplayCopyWith(
    RadioDisplay value,
    $Res Function(RadioDisplay) then,
  ) = _$RadioDisplayCopyWithImpl<$Res, RadioDisplay>;
  @useResult
  $Res call({
    DisplayText title,
    DisplayText country,
    String statusKey,
    String knobKey,
    FlightPhase phase,
    RadioStation? station,
    TravelLeg? leg,
    TrackTitle? track,
    bool busy,
    bool flying,
    bool playing,
    bool knobEnabled,
    bool playKeyEnabled,
    bool playKeyOn,
    bool playKeyDown,
    bool saveEnabled,
    bool nextStopPending,
  });

  $DisplayTextCopyWith<$Res> get title;
  $DisplayTextCopyWith<$Res> get country;
  $RadioStationCopyWith<$Res>? get station;
  $TravelLegCopyWith<$Res>? get leg;
  $TrackTitleCopyWith<$Res>? get track;
}

/// @nodoc
class _$RadioDisplayCopyWithImpl<$Res, $Val extends RadioDisplay>
    implements $RadioDisplayCopyWith<$Res> {
  _$RadioDisplayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RadioDisplay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? country = null,
    Object? statusKey = null,
    Object? knobKey = null,
    Object? phase = null,
    Object? station = freezed,
    Object? leg = freezed,
    Object? track = freezed,
    Object? busy = null,
    Object? flying = null,
    Object? playing = null,
    Object? knobEnabled = null,
    Object? playKeyEnabled = null,
    Object? playKeyOn = null,
    Object? playKeyDown = null,
    Object? saveEnabled = null,
    Object? nextStopPending = null,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as DisplayText,
            country: null == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as DisplayText,
            statusKey: null == statusKey
                ? _value.statusKey
                : statusKey // ignore: cast_nullable_to_non_nullable
                      as String,
            knobKey: null == knobKey
                ? _value.knobKey
                : knobKey // ignore: cast_nullable_to_non_nullable
                      as String,
            phase: null == phase
                ? _value.phase
                : phase // ignore: cast_nullable_to_non_nullable
                      as FlightPhase,
            station: freezed == station
                ? _value.station
                : station // ignore: cast_nullable_to_non_nullable
                      as RadioStation?,
            leg: freezed == leg
                ? _value.leg
                : leg // ignore: cast_nullable_to_non_nullable
                      as TravelLeg?,
            track: freezed == track
                ? _value.track
                : track // ignore: cast_nullable_to_non_nullable
                      as TrackTitle?,
            busy: null == busy
                ? _value.busy
                : busy // ignore: cast_nullable_to_non_nullable
                      as bool,
            flying: null == flying
                ? _value.flying
                : flying // ignore: cast_nullable_to_non_nullable
                      as bool,
            playing: null == playing
                ? _value.playing
                : playing // ignore: cast_nullable_to_non_nullable
                      as bool,
            knobEnabled: null == knobEnabled
                ? _value.knobEnabled
                : knobEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            playKeyEnabled: null == playKeyEnabled
                ? _value.playKeyEnabled
                : playKeyEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            playKeyOn: null == playKeyOn
                ? _value.playKeyOn
                : playKeyOn // ignore: cast_nullable_to_non_nullable
                      as bool,
            playKeyDown: null == playKeyDown
                ? _value.playKeyDown
                : playKeyDown // ignore: cast_nullable_to_non_nullable
                      as bool,
            saveEnabled: null == saveEnabled
                ? _value.saveEnabled
                : saveEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            nextStopPending: null == nextStopPending
                ? _value.nextStopPending
                : nextStopPending // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of RadioDisplay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DisplayTextCopyWith<$Res> get title {
    return $DisplayTextCopyWith<$Res>(_value.title, (value) {
      return _then(_value.copyWith(title: value) as $Val);
    });
  }

  /// Create a copy of RadioDisplay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DisplayTextCopyWith<$Res> get country {
    return $DisplayTextCopyWith<$Res>(_value.country, (value) {
      return _then(_value.copyWith(country: value) as $Val);
    });
  }

  /// Create a copy of RadioDisplay
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

  /// Create a copy of RadioDisplay
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

  /// Create a copy of RadioDisplay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrackTitleCopyWith<$Res>? get track {
    if (_value.track == null) {
      return null;
    }

    return $TrackTitleCopyWith<$Res>(_value.track!, (value) {
      return _then(_value.copyWith(track: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RadioDisplayImplCopyWith<$Res>
    implements $RadioDisplayCopyWith<$Res> {
  factory _$$RadioDisplayImplCopyWith(
    _$RadioDisplayImpl value,
    $Res Function(_$RadioDisplayImpl) then,
  ) = __$$RadioDisplayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DisplayText title,
    DisplayText country,
    String statusKey,
    String knobKey,
    FlightPhase phase,
    RadioStation? station,
    TravelLeg? leg,
    TrackTitle? track,
    bool busy,
    bool flying,
    bool playing,
    bool knobEnabled,
    bool playKeyEnabled,
    bool playKeyOn,
    bool playKeyDown,
    bool saveEnabled,
    bool nextStopPending,
  });

  @override
  $DisplayTextCopyWith<$Res> get title;
  @override
  $DisplayTextCopyWith<$Res> get country;
  @override
  $RadioStationCopyWith<$Res>? get station;
  @override
  $TravelLegCopyWith<$Res>? get leg;
  @override
  $TrackTitleCopyWith<$Res>? get track;
}

/// @nodoc
class __$$RadioDisplayImplCopyWithImpl<$Res>
    extends _$RadioDisplayCopyWithImpl<$Res, _$RadioDisplayImpl>
    implements _$$RadioDisplayImplCopyWith<$Res> {
  __$$RadioDisplayImplCopyWithImpl(
    _$RadioDisplayImpl _value,
    $Res Function(_$RadioDisplayImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioDisplay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? country = null,
    Object? statusKey = null,
    Object? knobKey = null,
    Object? phase = null,
    Object? station = freezed,
    Object? leg = freezed,
    Object? track = freezed,
    Object? busy = null,
    Object? flying = null,
    Object? playing = null,
    Object? knobEnabled = null,
    Object? playKeyEnabled = null,
    Object? playKeyOn = null,
    Object? playKeyDown = null,
    Object? saveEnabled = null,
    Object? nextStopPending = null,
  }) {
    return _then(
      _$RadioDisplayImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as DisplayText,
        country: null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as DisplayText,
        statusKey: null == statusKey
            ? _value.statusKey
            : statusKey // ignore: cast_nullable_to_non_nullable
                  as String,
        knobKey: null == knobKey
            ? _value.knobKey
            : knobKey // ignore: cast_nullable_to_non_nullable
                  as String,
        phase: null == phase
            ? _value.phase
            : phase // ignore: cast_nullable_to_non_nullable
                  as FlightPhase,
        station: freezed == station
            ? _value.station
            : station // ignore: cast_nullable_to_non_nullable
                  as RadioStation?,
        leg: freezed == leg
            ? _value.leg
            : leg // ignore: cast_nullable_to_non_nullable
                  as TravelLeg?,
        track: freezed == track
            ? _value.track
            : track // ignore: cast_nullable_to_non_nullable
                  as TrackTitle?,
        busy: null == busy
            ? _value.busy
            : busy // ignore: cast_nullable_to_non_nullable
                  as bool,
        flying: null == flying
            ? _value.flying
            : flying // ignore: cast_nullable_to_non_nullable
                  as bool,
        playing: null == playing
            ? _value.playing
            : playing // ignore: cast_nullable_to_non_nullable
                  as bool,
        knobEnabled: null == knobEnabled
            ? _value.knobEnabled
            : knobEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        playKeyEnabled: null == playKeyEnabled
            ? _value.playKeyEnabled
            : playKeyEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        playKeyOn: null == playKeyOn
            ? _value.playKeyOn
            : playKeyOn // ignore: cast_nullable_to_non_nullable
                  as bool,
        playKeyDown: null == playKeyDown
            ? _value.playKeyDown
            : playKeyDown // ignore: cast_nullable_to_non_nullable
                  as bool,
        saveEnabled: null == saveEnabled
            ? _value.saveEnabled
            : saveEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        nextStopPending: null == nextStopPending
            ? _value.nextStopPending
            : nextStopPending // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$RadioDisplayImpl extends _RadioDisplay {
  const _$RadioDisplayImpl({
    required this.title,
    required this.country,
    required this.statusKey,
    required this.knobKey,
    required this.phase,
    this.station,
    this.leg,
    this.track,
    this.busy = false,
    this.flying = false,
    this.playing = false,
    this.knobEnabled = true,
    this.playKeyEnabled = false,
    this.playKeyOn = false,
    this.playKeyDown = false,
    this.saveEnabled = false,
    this.nextStopPending = false,
  }) : super._();

  @override
  final DisplayText title;
  @override
  final DisplayText country;
  @override
  final String statusKey;
  @override
  final String knobKey;
  @override
  final FlightPhase phase;
  @override
  final RadioStation? station;
  @override
  final TravelLeg? leg;
  @override
  final TrackTitle? track;
  @override
  @JsonKey()
  final bool busy;
  @override
  @JsonKey()
  final bool flying;
  @override
  @JsonKey()
  final bool playing;
  @override
  @JsonKey()
  final bool knobEnabled;
  @override
  @JsonKey()
  final bool playKeyEnabled;
  @override
  @JsonKey()
  final bool playKeyOn;
  @override
  @JsonKey()
  final bool playKeyDown;
  @override
  @JsonKey()
  final bool saveEnabled;
  @override
  @JsonKey()
  final bool nextStopPending;

  @override
  String toString() {
    return 'RadioDisplay(title: $title, country: $country, statusKey: $statusKey, knobKey: $knobKey, phase: $phase, station: $station, leg: $leg, track: $track, busy: $busy, flying: $flying, playing: $playing, knobEnabled: $knobEnabled, playKeyEnabled: $playKeyEnabled, playKeyOn: $playKeyOn, playKeyDown: $playKeyDown, saveEnabled: $saveEnabled, nextStopPending: $nextStopPending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RadioDisplayImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.statusKey, statusKey) ||
                other.statusKey == statusKey) &&
            (identical(other.knobKey, knobKey) || other.knobKey == knobKey) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.station, station) || other.station == station) &&
            (identical(other.leg, leg) || other.leg == leg) &&
            (identical(other.track, track) || other.track == track) &&
            (identical(other.busy, busy) || other.busy == busy) &&
            (identical(other.flying, flying) || other.flying == flying) &&
            (identical(other.playing, playing) || other.playing == playing) &&
            (identical(other.knobEnabled, knobEnabled) ||
                other.knobEnabled == knobEnabled) &&
            (identical(other.playKeyEnabled, playKeyEnabled) ||
                other.playKeyEnabled == playKeyEnabled) &&
            (identical(other.playKeyOn, playKeyOn) ||
                other.playKeyOn == playKeyOn) &&
            (identical(other.playKeyDown, playKeyDown) ||
                other.playKeyDown == playKeyDown) &&
            (identical(other.saveEnabled, saveEnabled) ||
                other.saveEnabled == saveEnabled) &&
            (identical(other.nextStopPending, nextStopPending) ||
                other.nextStopPending == nextStopPending));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    country,
    statusKey,
    knobKey,
    phase,
    station,
    leg,
    track,
    busy,
    flying,
    playing,
    knobEnabled,
    playKeyEnabled,
    playKeyOn,
    playKeyDown,
    saveEnabled,
    nextStopPending,
  );

  /// Create a copy of RadioDisplay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RadioDisplayImplCopyWith<_$RadioDisplayImpl> get copyWith =>
      __$$RadioDisplayImplCopyWithImpl<_$RadioDisplayImpl>(this, _$identity);
}

abstract class _RadioDisplay extends RadioDisplay {
  const factory _RadioDisplay({
    required final DisplayText title,
    required final DisplayText country,
    required final String statusKey,
    required final String knobKey,
    required final FlightPhase phase,
    final RadioStation? station,
    final TravelLeg? leg,
    final TrackTitle? track,
    final bool busy,
    final bool flying,
    final bool playing,
    final bool knobEnabled,
    final bool playKeyEnabled,
    final bool playKeyOn,
    final bool playKeyDown,
    final bool saveEnabled,
    final bool nextStopPending,
  }) = _$RadioDisplayImpl;
  const _RadioDisplay._() : super._();

  @override
  DisplayText get title;
  @override
  DisplayText get country;
  @override
  String get statusKey;
  @override
  String get knobKey;
  @override
  FlightPhase get phase;
  @override
  RadioStation? get station;
  @override
  TravelLeg? get leg;
  @override
  TrackTitle? get track;
  @override
  bool get busy;
  @override
  bool get flying;
  @override
  bool get playing;
  @override
  bool get knobEnabled;
  @override
  bool get playKeyEnabled;
  @override
  bool get playKeyOn;
  @override
  bool get playKeyDown;
  @override
  bool get saveEnabled;
  @override
  bool get nextStopPending;

  /// Create a copy of RadioDisplay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RadioDisplayImplCopyWith<_$RadioDisplayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
