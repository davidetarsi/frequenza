import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/data/native_channel.dart';
import 'package:frequenza/features/songs/data/installed_apps.dart';
import 'package:frequenza/features/songs/domain/song_search.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final everyApp = {
    for (final service in SearchService.values) ?service.package,
  };

  test('builds the four links with the query encoded', () {
    final links = SongSearch.links('Ana Moura Desfado', everyApp);
    expect(links, [
      (
        SearchService.spotify,
        Uri.parse('spotify:search:Ana%20Moura%20Desfado'),
      ),
      (
        SearchService.youtube,
        Uri.parse(
          'https://www.youtube.com/results?search_query=Ana%20Moura%20Desfado',
        ),
      ),
      (
        SearchService.amazonMusic,
        Uri.parse('https://music.amazon.com/search/Ana%20Moura%20Desfado'),
      ),
      (
        SearchService.web,
        Uri.parse('https://www.google.com/search?q=Ana%20Moura%20Desfado'),
      ),
    ]);
  });

  test('shows only installed apps, the web always', () {
    final links = SongSearch.links('Desfado', {'com.google.android.youtube'});
    expect(links.map((link) => link.$1), [
      SearchService.youtube,
      SearchService.web,
    ]);
  });

  test('the packages to ask about are the three apps', () {
    expect(everyApp, {
      'com.spotify.music',
      'com.google.android.youtube',
      'com.amazon.mp3',
    });
  });

  test('the phone answers which apps are installed', () async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(nativeChannel, (call) async {
      expect(call.method, 'installedApps');
      return ['com.spotify.music'];
    });
    addTearDown(() => messenger.setMockMethodCallHandler(nativeChannel, null));
    expect(await installedPackages(everyApp), {'com.spotify.music'});
  });

  test('no channel means no apps', () async {
    expect(await installedPackages(everyApp), <String>{});
  });

  test('a channel error means no apps', () async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      nativeChannel,
      (call) async => throw PlatformException(code: 'boom'),
    );
    addTearDown(() => messenger.setMockMethodCallHandler(nativeChannel, null));
    expect(await installedPackages(everyApp), <String>{});
  });
}
