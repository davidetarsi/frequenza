import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'radio_journey_page_test.dart';

/// Real Roboto metrics: the default test font is about twice as wide.
Future<void> loadRoboto() async {
  final fonts =
      '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts';
  final loader = FontLoader('Roboto');
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    final bytes = await File('$fonts/Roboto-$weight.ttf').readAsBytes();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadRoboto);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('distance and local time are never cut', (tester) async {
    const kexp = RadioStation(
      id: 'kexp',
      name: 'KEXP',
      streamUrl: 'https://example.com/kexp',
      country: 'The United States Of America',
      countryCode: 'US',
    );
    for (final (size, scale) in [
      (const Size(360, 740), 1.0),
      (const Size(320, 640), 2.0),
    ]) {
      final audio = await openRadio(tester, kexp, size: size, textScale: scale);
      await tester.tap(find.byKey(const ValueKey('tune-knob')));
      await tester.pump();
      await landFlight(tester, audio);
      for (final text in [
        find.textContaining('KM'),
        find.textContaining(':'),
        find.text('In ascolto'),
      ]) {
        final paragraph = tester.renderObject<RenderParagraph>(text.first);
        expect(paragraph.didExceedMaxLines, isFalse, reason: '$text at $size');
      }
      await tester.pumpWidget(const SizedBox());
    }
  });
}
