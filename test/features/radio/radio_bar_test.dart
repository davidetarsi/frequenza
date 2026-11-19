import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/config/app_localization.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/radio/application/radio_controller.dart';
import 'package:frequenza/features/radio/domain/journey.dart';
import 'package:frequenza/features/radio/domain/radio_session.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:frequenza/features/radio/presentation/radio_bar.dart';
import 'package:frequenza/features/songs/application/saved_songs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../favorites/favorites_test.dart' show MemoryFavorites;
import '../songs/saved_songs_test.dart' show MemorySongs, kexp;

/// A radio set by hand that records what the bar asks of it.
class BarRadio extends RadioController {
  BarRadio(this.initial);
  final RadioSession initial;
  final calls = <String>[];

  @override
  RadioSession build() => initial;

  @override
  Future<void> pause() async => calls.add('pause');

  @override
  Future<void> play() async => calls.add('play');

  @override
  Future<void> tuneRandom({Set<String>? countries}) async {
    calls.add(
      countries == null ? 'tuneRandom' : 'tuneRandom:${countries.join(',')}',
    );
    state = RadioSession.flying(state.journey, kind: FlightKind.forward);
  }

  @override
  Future<void> tuneTo(RadioStation station) async {
    calls.add('tuneTo:${station.id}');
    state = RadioSession.flying(state.journey, kind: FlightKind.forward);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  RadioSession onAir(OnAirPlayback playback, {String? title}) =>
      RadioSession.onAir(
        const Journey(landed: kexp, trips: 1),
        kexp,
        playback: playback,
        trackTitle: title,
      );

  late BarRadio radio;
  late MemoryFavorites favorites;
  late MemorySongs songs;
  var backs = 0;

  Future<void> show(WidgetTester tester, RadioSession session) async {
    radio = BarRadio(session);
    favorites = MemoryFavorites();
    songs = MemorySongs();
    backs = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          radioControllerProvider.overrideWith(() => radio),
          favoritesRepositoryProvider.overrideWithValue(favorites),
          songsRepositoryProvider.overrideWithValue(songs),
        ],
        child: AppLocalization(
          startLocale: const Locale('it'),
          child: Builder(
            builder: (context) => MaterialApp(
              locale: context.locale,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              home: Scaffold(
                bottomNavigationBar: RadioBar(onBackToRadio: () => backs++),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('on air with a title: heart, bookmark and pause', (tester) async {
    await show(
      tester,
      onAir(OnAirPlayback.playing, title: 'Ana Moura - Desfado'),
    );
    expect(find.text("KEXP · Stati Uniti d'America"), findsOneWidget);
    expect(find.text('Ana Moura — Desfado'), findsOneWidget);
    expect(find.byTooltip('Salva la stazione'), findsOneWidget);
    expect(find.byTooltip('Salva canzone'), findsOneWidget);
    await tester.tap(find.byTooltip('Pausa'));
    expect(radio.calls, ['pause']);
  });

  testWidgets('without a title there is no bookmark', (tester) async {
    await show(tester, onAir(OnAirPlayback.playing));
    expect(find.byTooltip('Salva canzone'), findsNothing);
    expect(find.byTooltip('Salva la stazione'), findsOneWidget);
  });

  testWidgets('paused: play resumes', (tester) async {
    await show(
      tester,
      onAir(OnAirPlayback.paused, title: 'Ana Moura - Desfado'),
    );
    await tester.tap(find.byTooltip('Riprendi'));
    expect(radio.calls, ['play']);
  });

  testWidgets('in flight: no heart, no bookmark, the key is off', (
    tester,
  ) async {
    await show(
      tester,
      const RadioSession.flying(Journey(), kind: FlightKind.forward),
    );
    expect(find.text('In volo…'), findsOneWidget);
    expect(find.byTooltip('Salva la stazione'), findsNothing);
    expect(find.byTooltip('Salva canzone'), findsNothing);
    // As on the radio: the play key shows play, and is off.
    final key = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.play_arrow),
    );
    expect(key.onPressed, isNull);
  });

  testWidgets('a failed flight: retry flies again', (tester) async {
    await show(tester, const RadioSession.failed(Journey()));
    expect(find.text('Nessun segnale'), findsOneWidget);
    await tester.tap(find.byTooltip('Riprova'));
    expect(radio.calls, ['tuneRandom']);
  });

  testWidgets('off: there is no bar', (tester) async {
    await show(tester, const RadioSession.off(Journey()));
    expect(find.byTooltip('Pausa'), findsNothing);
    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('touching the station goes back to the radio', (tester) async {
    await show(tester, onAir(OnAirPlayback.playing));
    await tester.tap(find.bySemanticsLabel(RegExp('Torna alla radio')));
    expect(backs, 1);
  });

  testWidgets('the heart saves the station, the bookmark the song', (
    tester,
  ) async {
    await show(
      tester,
      onAir(OnAirPlayback.playing, title: 'Ana Moura - Desfado'),
    );
    await tester.tap(find.byTooltip('Salva la stazione'));
    await tester.pumpAndSettle();
    expect(favorites.items.map((s) => s.id), ['kexp']);
    expect(find.byTooltip('Togli dai preferiti'), findsOneWidget);
    await tester.tap(find.byTooltip('Salva canzone'));
    await tester.pumpAndSettle();
    expect(songs.items.single.title, 'Desfado');
    expect(find.text('Canzone salvata'), findsOneWidget);
  });
}
