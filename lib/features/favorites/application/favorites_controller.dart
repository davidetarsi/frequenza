import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../radio/domain/radio_station.dart';
import '../domain/favorites_state.dart';
import 'favorites_providers.dart';

part 'favorites_controller.g.dart';

@Riverpod(keepAlive: true)
class Favorites extends _$Favorites {
  Object? _generation;
  late Future<void> ready;

  @override
  FavoritesState build() {
    ref.watch(favoritesRepositoryProvider);
    final generation = Object();
    _generation = generation;
    ref.onDispose(() => _generation = null);
    const initial = FavoritesState(isLoading: true);
    ready = Future.microtask(() async {
      if (_generation == generation) await _load(generation, initial);
    });
    return initial;
  }

  Future<void> load() async {
    if (state.isLoading || state.isSaving) return;
    final previous = state;
    state = previous.copyWith(isLoading: true, hasError: false);
    await _load(_generation, previous);
  }

  Future<void> _load(Object? generation, FavoritesState previous) async {
    try {
      final items = await ref.read(favoritesRepositoryProvider).load();
      if (_generation == generation) {
        state = FavoritesState(
          stations: List.unmodifiable(items),
          hasLoaded: true,
        );
      }
    } catch (_) {
      if (_generation == generation) {
        state = FavoritesState(
          stations: previous.stations,
          hasLoaded: previous.hasLoaded,
          hasError: true,
        );
      }
    }
  }

  Future<void> toggle(RadioStation station) async {
    if (!state.hasLoaded || state.isLoading || state.isSaving) return;
    final generation = _generation;
    final previous = state.stations;
    final next = state.contains(station.id)
        ? previous.where((s) => s.id != station.id).toList()
        : [...previous, station];
    state = FavoritesState(stations: previous, isSaving: true, hasLoaded: true);
    try {
      await ref.read(favoritesRepositoryProvider).save(next);
      if (_generation == generation) {
        state = FavoritesState(
          stations: List.unmodifiable(next),
          hasLoaded: true,
        );
      }
    } catch (_) {
      if (_generation == generation) {
        state = FavoritesState(
          stations: previous,
          hasLoaded: true,
          hasError: true,
        );
      }
    }
  }
}
