import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/preferences_favorites_repository.dart';
import '../domain/favorites_repository.dart';
import 'favorites_controller.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => PreferencesFavoritesRepository(),
);
final favoritesProvider =
    StateNotifierProvider<FavoritesController, FavoritesState>(
      (ref) => FavoritesController(ref.watch(favoritesRepositoryProvider)),
    );
