import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Runs mutations in order. Each task reads the latest data when its turn
/// starts. Rebuild/disposal cancels queued tasks and invalidates old results.
class SerialTasks {
  Object? _generation;
  Future<void> _tail = Future.value();

  void start(Ref ref) {
    final generation = Object();
    _generation = generation;
    ref.onDispose(() {
      if (_generation == generation) _generation = null;
    });
  }

  Future<void> get settled => _tail;

  Future<T?> run<T>(Future<T> Function(bool Function() current) action) {
    final generation = _generation;
    bool current() => generation != null && _generation == generation;
    final result = Completer<T?>();
    _tail = _tail.then((_) async {
      if (!current()) {
        result.complete(null);
        return;
      }
      try {
        final value = await action(current);
        result.complete(current() ? value : null);
      } catch (error, stack) {
        result.completeError(error, stack);
      }
    });
    return result.future;
  }
}
