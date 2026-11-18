import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/welcome/application/welcome_seen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

/// Preferences that cannot be read, as on a broken storage.
class BrokenStore extends SharedPreferencesStorePlatform {
  @override
  Future<Map<String, Object>> getAll() => throw StateError('Broken storage');

  @override
  Future<bool> clear() async => false;

  @override
  Future<bool> remove(String key) async => false;

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final entry in <String, (Map<String, Object>, bool)>{
    'a new install': ({}, false),
    'the legacy guide only': ({'app.welcomeSeen': true}, false),
    'an older revision': ({WelcomeSeen.revisionKey: 1}, false),
    'this revision': (
      {WelcomeSeen.revisionKey: WelcomeSeen.currentRevision},
      true,
    ),
    'a future revision after a downgrade': (
      {WelcomeSeen.revisionKey: WelcomeSeen.currentRevision + 1},
      true,
    ),
  }.entries) {
    test('${entry.key} selects the right guide', () async {
      SharedPreferences.setMockInitialValues(entry.value.$1);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(await container.read(welcomeSeenProvider.future), entry.value.$2);
    });
  }

  for (final legacy in [false, true]) {
    test('completion survives restarts (legacy user: $legacy)', () async {
      SharedPreferences.setMockInitialValues({
        if (legacy) 'app.welcomeSeen': true,
        'app.language': 'it',
      });
      final first = ProviderContainer();
      addTearDown(first.dispose);
      expect(await first.read(welcomeSeenProvider.future), isFalse);
      expect(
        await first.read(welcomeSeenProvider.notifier).hasSeenAnyGuide(),
        legacy,
      );
      await first.read(welcomeSeenProvider.notifier).markSeen();
      final restarted = ProviderContainer();
      addTearDown(restarted.dispose);
      expect(await restarted.read(welcomeSeenProvider.future), isTrue);
      expect(
        await restarted.read(welcomeSeenProvider.notifier).hasSeenAnyGuide(),
        isTrue,
      );
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('app.language'), 'it');
    });
  }

  test('unreadable preferences open the radio instead of blocking', () async {
    final previous = SharedPreferencesStorePlatform.instance;
    SharedPreferencesStorePlatform.instance = BrokenStore();
    SharedPreferences.resetStatic();
    addTearDown(() {
      SharedPreferencesStorePlatform.instance = previous;
      SharedPreferences.resetStatic();
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(await container.read(welcomeSeenProvider.future), isTrue);
  });
}
