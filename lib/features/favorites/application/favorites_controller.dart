import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../radio/domain/radio_station.dart';
import '../domain/favorites_repository.dart';

class FavoritesState {
  const FavoritesState({
    this.stations = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.hasError = false,
    this.hasLoaded = false,
  });
  final List<RadioStation> stations;
  final bool isLoading, isSaving, hasError, hasLoaded;
  bool contains(String id) => stations.any((s) => s.id == id);
}

class FavoritesController extends StateNotifier<FavoritesState> {
  FavoritesController(this._repository) : super(const FavoritesState()) {
    ready = load();
  }
  final FavoritesRepository _repository;
  late final Future<void> ready;

  Future<void> load() async {
    if (state.isLoading || state.isSaving) return;
    final previous = state;
    state = FavoritesState(
      stations: previous.stations,
      isLoading: true,
      hasLoaded: previous.hasLoaded,
    );
    try {
      final items = await _repository.load();
      if (mounted) {
        state = FavoritesState(
          stations: List.unmodifiable(items),
          hasLoaded: true,
        );
      }
    } catch (_) {
      if (mounted) {
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
    final previous = state.stations;
    final next = state.contains(station.id)
        ? previous.where((s) => s.id != station.id).toList()
        : [...previous, station];
    state = FavoritesState(stations: previous, isSaving: true, hasLoaded: true);
    try {
      await _repository.save(next);
      if (mounted) {
        state = FavoritesState(
          stations: List.unmodifiable(next),
          hasLoaded: true,
        );
      }
    } catch (_) {
      if (mounted) {
        state = FavoritesState(
          stations: previous,
          hasLoaded: true,
          hasError: true,
        );
      }
    }
  }
}
