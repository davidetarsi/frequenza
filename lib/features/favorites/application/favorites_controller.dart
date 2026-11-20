import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/state/latest_save.dart';
import '../../radio/domain/radio_station.dart';
import '../../analytics/application/analytics_providers.dart';
import '../../analytics/domain/app_event.dart';
import '../domain/favorites_state.dart';
import 'favorites_providers.dart';

part 'favorites_controller.g.dart';

@Riverpod(keepAlive: true)
class Favorites extends _$Favorites {
  final _save = LatestSave();
  Future<void>? _pendingWrite;

  @override
  Future<FavoritesState> build() {
    final repository = ref.watch(favoritesRepositoryProvider);
    _save.start(ref);
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
    final removing = current.contains(station.id);
    final next = removing
        ? current.stations.where((s) => s.id != station.id).toList()
        : [...current.stations, station];
    await _update(() async {
      await ref.read(favoritesRepositoryProvider).save(next);
      return FavoritesState(next);
    });
    if (state.hasError) return;
    ref
        .read(analyticsProvider)
        .track(
          removing
              ? AppEvent.favoriteRemoved(station)
              : AppEvent.favoriteAdded(station),
        );
  }

  /// Undo restores the original order without overwriting other changes or
  /// removing a station that has already been saved again.
  Future<void> restore(RadioStation station, int index) async {
    // Another favorite may be saving when Undo is pressed. Read the list only
    // after that write completes, and recheck if another write has started.
    while (state.isLoading) {
      final pending = _pendingWrite;
      if (pending == null) return;
      await pending;
    }
    final current = state.valueOrNull;
    if (current == null || current.contains(station.id)) return;
    final next = [...current.stations]
      ..insert(index.clamp(0, current.stations.length), station);
    await _update(() async {
      await ref.read(favoritesRepositoryProvider).save(next);
      return FavoritesState(next);
    });
  }

  Future<void> _update(Future<FavoritesState> Function() action) {
    final pending = _save
        .run(shown: state, emit: (value) => state = value, action: action)
        .then<void>((_) {});
    _pendingWrite = pending;
    return pending.whenComplete(() {
      if (identical(_pendingWrite, pending)) _pendingWrite = null;
    });
  }
}
