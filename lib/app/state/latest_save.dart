import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Saves through an [AsyncValue]: while saving the previous value stays
/// visible, and the result lands only if the provider was not rebuilt in
/// the meantime.
class LatestSave {
  Object? _generation;

  /// Called in `build()`: a rebuild makes earlier saves stale.
  void start(Ref ref) {
    final generation = Object();
    _generation = generation;
    ref.onDispose(() {
      if (_generation == generation) _generation = null;
    });
  }

  /// Runs [action] and returns its result, applied with [emit] over
  /// [shown] unless a rebuild came in between.
  Future<AsyncValue<T>> run<T>({
    required AsyncValue<T> shown,
    required void Function(AsyncValue<T> value) emit,
    required Future<T> Function() action,
  }) async {
    final generation = _generation;
    emit(AsyncLoading<T>().copyWithPrevious(shown));
    final result = await AsyncValue.guard(action);
    if (generation != null && _generation == generation) {
      emit(result.copyWithPrevious(shown));
    }
    return result;
  }
}
