import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../radio/domain/radio_station.dart';
import '../domain/favorites_state.dart';
import 'favorites_providers.dart';

part 'favorites_controller.g.dart';

@Riverpod(keepAlive: true)
class Favorites extends _$Favorites {
  Object? _generation;

  @override
  Future<FavoritesState> build() {
    final repository = ref.watch(favoritesRepositoryProvider);
    _generation = Object();
    ref.onDispose(() => _generation = null);
    return repository.load().then(FavoritesState.new);
  }

  Future<void> load() async {
    if (state.isLoading) return;
    await _update(() async {
      final items = await ref.read(favoritesRepositoryProvider).load();
      return FavoritesState(items);
    });
  }

  Future<void> toggle(RadioStation station) async {
    final current = state.valueOrNull;
    if (current == null || state.isLoading) return;
    final next = current.contains(station.id)
        ? current.stations.where((s) => s.id != station.id).toList()
        : [...current.stations, station];
    await _update(() async {
      await ref.read(favoritesRepositoryProvider).save(next);
      return FavoritesState(next);
    });
  }

  Future<void> _update(Future<FavoritesState> Function() action) async {
    final generation = _generation;
    final previous = state;
    state = const AsyncLoading<FavoritesState>().copyWithPrevious(previous);
    final result = await AsyncValue.guard(action);
    if (_generation == generation) state = result.copyWithPrevious(previous);
  }
}
