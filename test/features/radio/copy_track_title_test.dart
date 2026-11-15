import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frequenza/app/app.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import '../favorites/favorites_test.dart';
import 'radio_controller_test.dart';

/// Opens the radio on air at phone size and records what reaches the
/// clipboard.
Future<(FakeAudioService, List<String>)> onAir(WidgetTester tester) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final copied = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        copied.add((call.arguments as Map)['text'] as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  final audio = FakeAudioService();
  addTearDown(audio.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        radioRepositoryProvider.overrideWithValue(
          FakeRadioRepository()..stationToReturn = station,
        ),
        radioAudioServiceProvider.overrideWithValue(audio),
        favoritesRepositoryProvider.overrideWithValue(MemoryFavorites()),
      ],
      child: const StarterApp(locale: Locale('it')),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('tune-knob')));
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
  return (audio, copied);
}

/// Answers the native channel as an Android phone of [sdk] would.
void androidVersion(WidgetTester tester, int sdk) {
  const channel = MethodChannel('frequenza/tuning_sound');
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (call) async => call.method == 'sdkInt' ? sdk : null,
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      null,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('below Android 13 a long press copies the song and says so', (
    tester,
  ) async {
    androidVersion(tester, 32);
    final (audio, copied) = await onAir(tester);
    audio.trackTitles.add('Artista — Titolo');
    await tester.pumpAndSettle();
    await tester.longPress(find.text('Artista — Titolo'));
    await tester.pumpAndSettle();
    expect(copied, ['Artista — Titolo']);
    expect(find.text('Titolo copiato'), findsOneWidget);
  });

  testWidgets('from Android 13 the phone confirms the copy, not the app', (
    tester,
  ) async {
    androidVersion(tester, 33);
    final (audio, copied) = await onAir(tester);
    audio.trackTitles.add('Artista — Titolo');
    await tester.pumpAndSettle();
    await tester.longPress(find.text('Artista — Titolo'));
    await tester.pumpAndSettle();
    expect(copied, ['Artista — Titolo']);
    expect(find.text('Titolo copiato'), findsNothing);
  });

  testWidgets('without a song title a long press copies nothing', (
    tester,
  ) async {
    androidVersion(tester, 32);
    final (_, copied) = await onAir(tester);
    expect(find.text('Radio'), findsOneWidget);
    await tester.longPress(find.text('Radio'));
    await tester.pumpAndSettle();
    final detail = find.descendant(
      of: find.byKey(const ValueKey('radio-detail')),
      matching: find.byType(Text),
    );
    await tester.longPress(detail);
    await tester.pumpAndSettle();
    expect(copied, isEmpty);
    expect(find.text('Titolo copiato'), findsNothing);
  });
}
