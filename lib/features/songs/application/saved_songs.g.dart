// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_songs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$songsRepositoryHash() => r'38ddecdd3d330636763e023d0f24d20be8506c96';

/// See also [songsRepository].
@ProviderFor(songsRepository)
final songsRepositoryProvider = Provider<SongsRepository>.internal(
  songsRepository,
  name: r'songsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$songsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SongsRepositoryRef = ProviderRef<SongsRepository>;
String _$savedSongsHash() => r'8b8e41cf837bb979d2eb7c5e02b8f26f433870b1';

/// The songs saved from the radio, in the order they were saved.
///
/// Copied from [SavedSongs].
@ProviderFor(SavedSongs)
final savedSongsProvider =
    AsyncNotifierProvider<SavedSongs, List<SavedSong>>.internal(
      SavedSongs.new,
      name: r'savedSongsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$savedSongsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SavedSongs = AsyncNotifier<List<SavedSong>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
