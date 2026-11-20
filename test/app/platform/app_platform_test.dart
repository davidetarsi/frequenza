import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/links/app_version.dart';
import 'package:frequenza/app/links/external_links.dart';
import 'package:frequenza/app/platform/application/app_platform_provider.dart';
import 'package:frequenza/app/platform/data/method_channel_app_platform.dart';
import 'package:frequenza/app/platform/data/native_channel.dart';
import 'package:frequenza/app/platform/domain/app_platform.dart';
import 'package:frequenza/features/songs/application/installed_apps.dart';

class FakePlatform implements AppPlatform {
  @override
  String get deviceLanguageCode => "en";
  @override
  Future<void> updateNotificationChannel(String id, String name) async {}
  int installationsRead = 0;
  Uri? opened;
  @override
  Future<String> appVersion() async => '0.4.1+6';
  @override
  Future<String> deviceDescription() async => 'Test phone';
  @override
  Future<int> androidSdk() async => 33;
  @override
  Future<Set<String>> installedPackages(Iterable<String> packages) async {
    installationsRead++;
    return {'com.spotify.music'};
  }

  @override
  Future<Uri?> notificationArtwork() async => null;
  @override
  Future<bool> copyText(String text) async => true;
  @override
  Future<bool> openExternal(Uri uri) async {
    opened = uri;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'application reads and external links use the injected platform',
    () async {
      final platform = FakePlatform();
      final container = ProviderContainer(
        overrides: [appPlatformProvider.overrideWithValue(platform)],
      );
      addTearDown(container.dispose);
      expect(await container.read(appVersionProvider.future), '0.4.1+6');
      expect(await container.read(deviceInfoProvider.future), 'Test phone');
      expect(await container.read(installedSearchAppsProvider.future), {
        'com.spotify.music',
      });
      await container.read(installedSearchAppsProvider.future);
      expect(platform.installationsRead, 1);
      final link = Uri.parse('https://example.com/');
      expect(await container.read(openExternalProvider)(link), isTrue);
      expect(platform.opened, link);
    },
  );

  test(
    'malformed native information falls back without leaking unknown packages',
    () async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(nativeChannel, (call) async {
        if (call.method == 'sdkInt') {
          return 'invalid';
        }
        if (call.method == 'installedApps') {
          return ['com.spotify.music', 'unrequested.app'];
        }
        throw PlatformException(code: 'unavailable');
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(nativeChannel, null),
      );
      final platform = MethodChannelAppPlatform();
      expect(await platform.androidSdk(), 0);
      expect(await platform.appVersion(), isEmpty);
      expect(await platform.installedPackages(['com.spotify.music']), {
        'com.spotify.music',
      });
    },
  );

  test(
    'external launches reject unsupported schemes before reaching a plugin',
    () async {
      final platform = MethodChannelAppPlatform();
      for (final raw in [
        'javascript:alert(1)',
        'file:///tmp/private',
        'http://example.com',
        'https://',
      ]) {
        expect(
          await platform.openExternal(Uri.parse(raw)),
          isFalse,
          reason: raw,
        );
      }
    },
  );
}
