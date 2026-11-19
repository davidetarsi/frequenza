// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AppEvent {
  String get name => throw _privateConstructorUsedError;
  Map<String, Object> get properties => throw _privateConstructorUsedError;

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppEventCopyWith<AppEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppEventCopyWith<$Res> {
  factory $AppEventCopyWith(AppEvent value, $Res Function(AppEvent) then) =
      _$AppEventCopyWithImpl<$Res, AppEvent>;
  @useResult
  $Res call({String name, Map<String, Object> properties});
}

/// @nodoc
class _$AppEventCopyWithImpl<$Res, $Val extends AppEvent>
    implements $AppEventCopyWith<$Res> {
  _$AppEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? properties = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            properties: null == properties
                ? _value.properties
                : properties // ignore: cast_nullable_to_non_nullable
                      as Map<String, Object>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppEventImplCopyWith<$Res>
    implements $AppEventCopyWith<$Res> {
  factory _$$AppEventImplCopyWith(
    _$AppEventImpl value,
    $Res Function(_$AppEventImpl) then,
  ) = __$$AppEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, Map<String, Object> properties});
}

/// @nodoc
class __$$AppEventImplCopyWithImpl<$Res>
    extends _$AppEventCopyWithImpl<$Res, _$AppEventImpl>
    implements _$$AppEventImplCopyWith<$Res> {
  __$$AppEventImplCopyWithImpl(
    _$AppEventImpl _value,
    $Res Function(_$AppEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? properties = null}) {
    return _then(
      _$AppEventImpl(
        null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        null == properties
            ? _value._properties
            : properties // ignore: cast_nullable_to_non_nullable
                  as Map<String, Object>,
      ),
    );
  }
}

/// @nodoc

class _$AppEventImpl extends _AppEvent {
  const _$AppEventImpl(
    this.name, [
    final Map<String, Object> properties = const {},
  ]) : _properties = properties,
       super._();

  @override
  final String name;
  final Map<String, Object> _properties;
  @override
  @JsonKey()
  Map<String, Object> get properties {
    if (_properties is EqualUnmodifiableMapView) return _properties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_properties);
  }

  @override
  String toString() {
    return 'AppEvent(name: $name, properties: $properties)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppEventImpl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other._properties,
              _properties,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    const DeepCollectionEquality().hash(_properties),
  );

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppEventImplCopyWith<_$AppEventImpl> get copyWith =>
      __$$AppEventImplCopyWithImpl<_$AppEventImpl>(this, _$identity);
}

abstract class _AppEvent extends AppEvent {
  const factory _AppEvent(
    final String name, [
    final Map<String, Object> properties,
  ]) = _$AppEventImpl;
  const _AppEvent._() : super._();

  @override
  String get name;
  @override
  Map<String, Object> get properties;

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppEventImplCopyWith<_$AppEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
