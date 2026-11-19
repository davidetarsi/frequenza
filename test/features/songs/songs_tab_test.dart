import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/app.dart';
import 'package:frequenza/app/links/external_links.dart';
import 'package:frequenza/features/analytics/application/analytics_providers.dart';
import 'package:frequenza/features/analytics/domain/app_event.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:frequenza/features/songs/application/saved_songs.dart';
import 'package:frequenza/features/songs/application/installed_apps.dart';
import 'package:frequenza/features/songs/domain/saved_song.dart';
import 'package:frequenza/features/songs/domain/song_search.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../favorites/favorites_test.dart' show MemoryFavorites;
import '../radio/radio_controller_test.dart';
import '../analytics/recording_analytics.dart';
import 'saved_songs_test.dart' show MemorySongs, kexp, fip;

const tokyo = RadioStation(
  id: 'tokyo',
  name: 'J-Wave',
  streamUrl: 'https://jwave.example.com/live',
  country: '',
  countryCode: '',
);

SavedSong song(String title, RadioStation station, int day, {String? artist}) =>
    SavedSong(
      artist: artist,
      title: title,
      station: station,
      savedAt: DateTime(2026, 11, day, 21),
    );

class Harness {
  final songs = MemorySongs();
  final audio = FakeAudioService();
  final opened = <Uri>[];
  final analytics = RecordingAnalytics();
}

Future<Harness> openSongs(
  WidgetTester tester,
  List<SavedSong> saved, {
  Set<String> installed = const {},
  bool opensLinks = true,
}) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final h = Harness()..songs.items = List.of(saved);
  addTearDown(h.audio.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        radioRepositoryProvider.overrideWithValue(FakeRadioRepository()),
        radioAudioServiceProvider.overrideWithValue(h.audio),
        favoritesRepositoryProvider.overrideWithValue(MemoryFavorites()),
        songsRepositoryProvider.overrideWithValue(h.songs),
        installedSearchAppsProvider.overrideWith((ref) async => installed),
        analyticsProvider.overrideWithValue(h.analytics),
        openExternalProvider.overrideWithValue((uri) async {
          h.opened.add(uri);
          return opensLinks;
        }),
      ],
      child: const StarterApp(locale: Locale('it')),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('favorites-open')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Canzoni'));
  await tester.pumpAndSettle();
  return h;
}

Finder row(String title) =>
    find.ancestor(of: find.text(title), matching: find.byType(Dismissible));

Future<void> openMenu(WidgetTester tester, String title) async {
  await tester.tap(
    find.descendant(of: row(title), matching: find.byIcon(Icons.more_vert)),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('the sheet opens on Radio and switches to Songs', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final audio = FakeAudioService();
    addTearDown(audio.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          radioRepositoryProvider.overrideWithValue(FakeRadioRepository()),
          radioAudioServiceProvider.overrideWithValue(audio),
          favoritesRepositoryProvider.overrideWithValue(MemoryFavorites()),
          songsRepositoryProvider.overrideWithValue(MemorySongs()),
        ],
        child: const StarterApp(locale: Locale('it')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('favorites-open')));
    await tester.pumpAndSettle();
    expect(find.text('Posti in cui tornare.'), findsOneWidget);

    await tester.tap(find.text('Canzoni'));
    await tester.pumpAndSettle();

    expect(find.text('Canzoni trovate in viaggio.'), findsOneWidget);
    expect(find.textContaining('Ancora nessuna canzone.'), findsOneWidget);
  });

  testWidgets('songs are grouped by country, newest first', (tester) async {
    await openSongs(tester, [
      song('Old', kexp, 10, artist: 'A'),
      song('Paris', fip, 12),
      song('Nowhere', tokyo, 11),
      song('New', kexp, 14, artist: 'B'),
    ]);

    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    final us = top("Stati Uniti d'America");
    final france = top('Francia');
    final unknown = top('Paese sconosciuto');
    expect(us, lessThan(france));
    expect(france, lessThan(unknown));
    expect(top('New'), lessThan(top('Old')));
    expect(top('Old'), lessThan(france));
    expect(find.text('B · KEXP · Washington · 14 nov 2026'), findsOneWidget);
    expect(find.text('FIP · 12 nov 2026'), findsOneWidget);
  });

  testWidgets('the menu lists installed apps, then web, copy, tune, remove', (
    tester,
  ) async {
    await openSongs(
      tester,
      [song('Desfado', kexp, 14, artist: 'Ana Moura')],
      installed: {'com.google.android.youtube'},
    );

    await openMenu(tester, 'Desfado');

    final items = tester
        .widgetList<PopupMenuItem<Object>>(find.byType(PopupMenuItem<Object>))
        .map((item) => ((item.child! as dynamic).data ?? '') as String);
    expect(items, [
      'Cerca su YouTube',
      'Cerca sul web',
      'Copia',
      'Riaccendi KEXP',
      'Togli',
    ]);
  });

  testWidgets('a search opens the link outside the app', (tester) async {
    final h = await openSongs(
      tester,
      [song('Desfado', kexp, 14, artist: 'Ana Moura')],
      installed: {'com.google.android.youtube'},
    );

    await openMenu(tester, 'Desfado');
    await tester.tap(find.text('Cerca su YouTube'));
    await tester.pumpAndSettle();

    expect(h.opened, [
      Uri.parse(
        'https://www.youtube.com/results?search_query=Ana%20Moura%20Desfado',
      ),
    ]);
  });

  testWidgets('swiping left removes with undo', (tester) async {
    final h = await openSongs(tester, [
      song('A', kexp, 10),
      song('B', kexp, 11),
      song('C', kexp, 12),
    ]);

    await tester.drag(row('B'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(row('B'), findsNothing);
    expect(h.songs.items.map((s) => s.title), ['A', 'C']);
    expect(find.text('Canzone tolta'), findsOneWidget);

    await tester.tap(find.widgetWithText(SnackBarAction, 'Annulla'));
    await tester.pumpAndSettle();

    expect(h.songs.items.map((s) => s.title), ['A', 'B', 'C']);
    expect(row('B'), findsOneWidget);
  });

  testWidgets('removal feedback expires while the songs sheet stays open', (
    tester,
  ) async {
    final h = await openSongs(tester, [song('A', kexp, 10)]);
    await tester.drag(row('A'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Canzone tolta'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Canzone tolta'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Canzone tolta'), findsNothing);
    expect(h.songs.items, isEmpty);
    expect(find.byTooltip('Chiudi'), findsOneWidget);
  });

  testWidgets('remove from the menu shows the same undo', (tester) async {
    final h = await openSongs(tester, [
      song('A', kexp, 10),
      song('B', fip, 11),
    ]);

    await openMenu(tester, 'A');
    await tester.tap(find.text('Togli'));
    await tester.pumpAndSettle();

    expect(h.songs.items.map((s) => s.title), ['B']);
    expect(find.text('Canzone tolta'), findsOneWidget);
    await tester.tap(find.widgetWithText(SnackBarAction, 'Annulla'));
    await tester.pumpAndSettle();
    expect(h.songs.items.map((s) => s.title), ['A', 'B']);
  });

  testWidgets('tune again closes the sheet and flies to the station', (
    tester,
  ) async {
    final h = await openSongs(tester, [song('Desfado', kexp, 14)]);

    await openMenu(tester, 'Desfado');
    await tester.tap(find.text('Riaccendi KEXP'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Canzoni trovate in viaggio.'), findsNothing);
    expect(h.audio.lastPlayedStation?.id, 'kexp');
  });

  testWidgets('a failed song search uses the shared link error', (
    tester,
  ) async {
    await openSongs(
      tester,
      [song('Desfado', kexp, 14)],
      installed: {'com.spotify.music'},
      opensLinks: false,
    );
    await openMenu(tester, 'Desfado');
    await tester.tap(find.text('Cerca su Spotify'));
    await tester.pumpAndSettle();
    expect(find.text('Impossibile aprire il link'), findsOneWidget);
  });

  testWidgets('the menu counts searches, copies and tuning again', (
    tester,
  ) async {
    final h = await openSongs(
      tester,
      [song('Desfado', kexp, 14, artist: 'Ana Moura')],
      installed: {'com.spotify.music'},
    );

    await openMenu(tester, 'Desfado');
    await tester.tap(find.text('Cerca su Spotify'));
    await tester.pumpAndSettle();
    await openMenu(tester, 'Desfado');
    await tester.tap(find.text('Copia'));
    await tester.pumpAndSettle();
    await openMenu(tester, 'Desfado');
    await tester.tap(find.text('Riaccendi KEXP'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(h.analytics.events, [
      AppEvent.songSearchOpened(SearchService.spotify),
      AppEvent.songCopied(),
      AppEvent.stationRetuned(),
    ]);
  });
}
