import 'package:freezed_annotation/freezed_annotation.dart';

import '../../radio/domain/radio_station.dart';

part 'favorites_state.freezed.dart';

@freezed
class FavoritesState with _$FavoritesState {
  const FavoritesState._();

  const factory FavoritesState(List<RadioStation> stations) = _FavoritesState;

  bool contains(String id) => stations.any((station) => station.id == id);
}
