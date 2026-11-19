// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_save_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SongSaveResult {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() saved,
    required TResult Function() duplicate,
    required TResult Function() unavailable,
    required TResult Function() failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? saved,
    TResult? Function()? duplicate,
    TResult? Function()? unavailable,
    TResult? Function()? failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? saved,
    TResult Function()? duplicate,
    TResult Function()? unavailable,
    TResult Function()? failed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SongSaved value) saved,
    required TResult Function(SongDuplicate value) duplicate,
    required TResult Function(SongsUnavailable value) unavailable,
    required TResult Function(SongSaveFailed value) failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SongSaved value)? saved,
    TResult? Function(SongDuplicate value)? duplicate,
    TResult? Function(SongsUnavailable value)? unavailable,
    TResult? Function(SongSaveFailed value)? failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SongSaved value)? saved,
    TResult Function(SongDuplicate value)? duplicate,
    TResult Function(SongsUnavailable value)? unavailable,
    TResult Function(SongSaveFailed value)? failed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SongSaveResultCopyWith<$Res> {
  factory $SongSaveResultCopyWith(
    SongSaveResult value,
    $Res Function(SongSaveResult) then,
  ) = _$SongSaveResultCopyWithImpl<$Res, SongSaveResult>;
}

/// @nodoc
class _$SongSaveResultCopyWithImpl<$Res, $Val extends SongSaveResult>
    implements $SongSaveResultCopyWith<$Res> {
  _$SongSaveResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SongSaveResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SongSavedImplCopyWith<$Res> {
  factory _$$SongSavedImplCopyWith(
    _$SongSavedImpl value,
    $Res Function(_$SongSavedImpl) then,
  ) = __$$SongSavedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SongSavedImplCopyWithImpl<$Res>
    extends _$SongSaveResultCopyWithImpl<$Res, _$SongSavedImpl>
    implements _$$SongSavedImplCopyWith<$Res> {
  __$$SongSavedImplCopyWithImpl(
    _$SongSavedImpl _value,
    $Res Function(_$SongSavedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SongSaveResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SongSavedImpl implements SongSaved {
  const _$SongSavedImpl();

  @override
  String toString() {
    return 'SongSaveResult.saved()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SongSavedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() saved,
    required TResult Function() duplicate,
    required TResult Function() unavailable,
    required TResult Function() failed,
  }) {
    return saved();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? saved,
    TResult? Function()? duplicate,
    TResult? Function()? unavailable,
    TResult? Function()? failed,
  }) {
    return saved?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? saved,
    TResult Function()? duplicate,
    TResult Function()? unavailable,
    TResult Function()? failed,
    required TResult orElse(),
  }) {
    if (saved != null) {
      return saved();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SongSaved value) saved,
    required TResult Function(SongDuplicate value) duplicate,
    required TResult Function(SongsUnavailable value) unavailable,
    required TResult Function(SongSaveFailed value) failed,
  }) {
    return saved(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SongSaved value)? saved,
    TResult? Function(SongDuplicate value)? duplicate,
    TResult? Function(SongsUnavailable value)? unavailable,
    TResult? Function(SongSaveFailed value)? failed,
  }) {
    return saved?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SongSaved value)? saved,
    TResult Function(SongDuplicate value)? duplicate,
    TResult Function(SongsUnavailable value)? unavailable,
    TResult Function(SongSaveFailed value)? failed,
    required TResult orElse(),
  }) {
    if (saved != null) {
      return saved(this);
    }
    return orElse();
  }
}

abstract class SongSaved implements SongSaveResult {
  const factory SongSaved() = _$SongSavedImpl;
}

/// @nodoc
abstract class _$$SongDuplicateImplCopyWith<$Res> {
  factory _$$SongDuplicateImplCopyWith(
    _$SongDuplicateImpl value,
    $Res Function(_$SongDuplicateImpl) then,
  ) = __$$SongDuplicateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SongDuplicateImplCopyWithImpl<$Res>
    extends _$SongSaveResultCopyWithImpl<$Res, _$SongDuplicateImpl>
    implements _$$SongDuplicateImplCopyWith<$Res> {
  __$$SongDuplicateImplCopyWithImpl(
    _$SongDuplicateImpl _value,
    $Res Function(_$SongDuplicateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SongSaveResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SongDuplicateImpl implements SongDuplicate {
  const _$SongDuplicateImpl();

  @override
  String toString() {
    return 'SongSaveResult.duplicate()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SongDuplicateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() saved,
    required TResult Function() duplicate,
    required TResult Function() unavailable,
    required TResult Function() failed,
  }) {
    return duplicate();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? saved,
    TResult? Function()? duplicate,
    TResult? Function()? unavailable,
    TResult? Function()? failed,
  }) {
    return duplicate?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? saved,
    TResult Function()? duplicate,
    TResult Function()? unavailable,
    TResult Function()? failed,
    required TResult orElse(),
  }) {
    if (duplicate != null) {
      return duplicate();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SongSaved value) saved,
    required TResult Function(SongDuplicate value) duplicate,
    required TResult Function(SongsUnavailable value) unavailable,
    required TResult Function(SongSaveFailed value) failed,
  }) {
    return duplicate(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SongSaved value)? saved,
    TResult? Function(SongDuplicate value)? duplicate,
    TResult? Function(SongsUnavailable value)? unavailable,
    TResult? Function(SongSaveFailed value)? failed,
  }) {
    return duplicate?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SongSaved value)? saved,
    TResult Function(SongDuplicate value)? duplicate,
    TResult Function(SongsUnavailable value)? unavailable,
    TResult Function(SongSaveFailed value)? failed,
    required TResult orElse(),
  }) {
    if (duplicate != null) {
      return duplicate(this);
    }
    return orElse();
  }
}

abstract class SongDuplicate implements SongSaveResult {
  const factory SongDuplicate() = _$SongDuplicateImpl;
}

/// @nodoc
abstract class _$$SongsUnavailableImplCopyWith<$Res> {
  factory _$$SongsUnavailableImplCopyWith(
    _$SongsUnavailableImpl value,
    $Res Function(_$SongsUnavailableImpl) then,
  ) = __$$SongsUnavailableImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SongsUnavailableImplCopyWithImpl<$Res>
    extends _$SongSaveResultCopyWithImpl<$Res, _$SongsUnavailableImpl>
    implements _$$SongsUnavailableImplCopyWith<$Res> {
  __$$SongsUnavailableImplCopyWithImpl(
    _$SongsUnavailableImpl _value,
    $Res Function(_$SongsUnavailableImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SongSaveResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SongsUnavailableImpl implements SongsUnavailable {
  const _$SongsUnavailableImpl();

  @override
  String toString() {
    return 'SongSaveResult.unavailable()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SongsUnavailableImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() saved,
    required TResult Function() duplicate,
    required TResult Function() unavailable,
    required TResult Function() failed,
  }) {
    return unavailable();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? saved,
    TResult? Function()? duplicate,
    TResult? Function()? unavailable,
    TResult? Function()? failed,
  }) {
    return unavailable?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? saved,
    TResult Function()? duplicate,
    TResult Function()? unavailable,
    TResult Function()? failed,
    required TResult orElse(),
  }) {
    if (unavailable != null) {
      return unavailable();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SongSaved value) saved,
    required TResult Function(SongDuplicate value) duplicate,
    required TResult Function(SongsUnavailable value) unavailable,
    required TResult Function(SongSaveFailed value) failed,
  }) {
    return unavailable(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SongSaved value)? saved,
    TResult? Function(SongDuplicate value)? duplicate,
    TResult? Function(SongsUnavailable value)? unavailable,
    TResult? Function(SongSaveFailed value)? failed,
  }) {
    return unavailable?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SongSaved value)? saved,
    TResult Function(SongDuplicate value)? duplicate,
    TResult Function(SongsUnavailable value)? unavailable,
    TResult Function(SongSaveFailed value)? failed,
    required TResult orElse(),
  }) {
    if (unavailable != null) {
      return unavailable(this);
    }
    return orElse();
  }
}

abstract class SongsUnavailable implements SongSaveResult {
  const factory SongsUnavailable() = _$SongsUnavailableImpl;
}

/// @nodoc
abstract class _$$SongSaveFailedImplCopyWith<$Res> {
  factory _$$SongSaveFailedImplCopyWith(
    _$SongSaveFailedImpl value,
    $Res Function(_$SongSaveFailedImpl) then,
  ) = __$$SongSaveFailedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SongSaveFailedImplCopyWithImpl<$Res>
    extends _$SongSaveResultCopyWithImpl<$Res, _$SongSaveFailedImpl>
    implements _$$SongSaveFailedImplCopyWith<$Res> {
  __$$SongSaveFailedImplCopyWithImpl(
    _$SongSaveFailedImpl _value,
    $Res Function(_$SongSaveFailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SongSaveResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SongSaveFailedImpl implements SongSaveFailed {
  const _$SongSaveFailedImpl();

  @override
  String toString() {
    return 'SongSaveResult.failed()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SongSaveFailedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() saved,
    required TResult Function() duplicate,
    required TResult Function() unavailable,
    required TResult Function() failed,
  }) {
    return failed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? saved,
    TResult? Function()? duplicate,
    TResult? Function()? unavailable,
    TResult? Function()? failed,
  }) {
    return failed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? saved,
    TResult Function()? duplicate,
    TResult Function()? unavailable,
    TResult Function()? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SongSaved value) saved,
    required TResult Function(SongDuplicate value) duplicate,
    required TResult Function(SongsUnavailable value) unavailable,
    required TResult Function(SongSaveFailed value) failed,
  }) {
    return failed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SongSaved value)? saved,
    TResult? Function(SongDuplicate value)? duplicate,
    TResult? Function(SongsUnavailable value)? unavailable,
    TResult? Function(SongSaveFailed value)? failed,
  }) {
    return failed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SongSaved value)? saved,
    TResult Function(SongDuplicate value)? duplicate,
    TResult Function(SongsUnavailable value)? unavailable,
    TResult Function(SongSaveFailed value)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(this);
    }
    return orElse();
  }
}

abstract class SongSaveFailed implements SongSaveResult {
  const factory SongSaveFailed() = _$SongSaveFailedImpl;
}
