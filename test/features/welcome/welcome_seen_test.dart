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
