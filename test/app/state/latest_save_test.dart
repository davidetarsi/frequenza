import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/state/latest_save.dart';

/// A minimal notifier that saves a number through [LatestSave].
class Counter extends AsyncNotifier<int> {
  final save = LatestSave();

  @override
  Future<int> build() async {
    save.start(ref);
    return 1;
  }

  Future<AsyncValue<int>> set(Future<int> Function() action) =>
      save.run(shown: state, emit: (value) => state = value, action: action);
}

final counterProvider = AsyncNotifierProvider<Counter, int>(Counter.new);

void main() {
  late ProviderContainer container;
  setUp(() async {
    container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(counterProvider.future);
  });

  Counter counter() => container.read(counterProvider.notifier);
  AsyncValue<int> state() => container.read(counterProvider);

  test('saving shows loading over the previous value', () async {
    final pending = Completer<int>();
    final saving = counter().set(() => pending.future);
    expect(state().isLoading, isTrue);
    expect(state().valueOrNull, 1);
    pending.complete(2);
    await saving;
  });

  test('the result lands over the previous value', () async {
    final result = await counter().set(() async => 2);
    expect(result.valueOrNull, 2);
    expect(state(), isA<AsyncData<int>>());
    expect(state().value, 2);
  });

  test('an error keeps the previous value visible', () async {
    final result = await counter().set(() async => throw StateError('disk'));
    expect(result.hasError, isTrue);
    expect(state().hasError, isTrue);
    expect(state().valueOrNull, 1);
    expect(state().isLoading, isFalse);
  });

  test('a rebuild during the save drops the stale result', () async {
    final pending = Completer<int>();
    final saving = counter().set(() => pending.future);
    container.invalidate(counterProvider);
    await container.read(counterProvider.future);
    pending.complete(2);
    final result = await saving;
    expect(result.valueOrNull, 2, reason: 'the caller still learns it');
    expect(state().value, 1);
    expect(state().isLoading, isFalse);
  });
}
