import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/data/radio_browser_repository.dart';
import 'package:frequenza/features/radio/domain/station_input.dart';
import 'package:frequenza/features/radio/domain/station_record.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'radio_browser_repository_test.dart' show rawStation;

class StreamingClient extends http.BaseClient {
  StreamingClient(this.respond);
  final Future<http.StreamedResponse> Function(http.BaseRequest) respond;
  bool closed = false;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      respond(request);
  @override
  void close() => closed = true;
}

void main() {
  test(
    'a declared oversized response is cancelled and the next mirror works',
    () async {
      var cancelled = false;
      final body = StreamController<List<int>>(
        onCancel: () => cancelled = true,
      );
      final hosts = <String>[];
      final client = StreamingClient((request) async {
        hosts.add(request.url.host);
        if (hosts.length == 1) {
          return http.StreamedResponse(body.stream, 200, contentLength: 100);
        }
        return http.StreamedResponse(Stream.value(utf8.encode('[]')), 200);
      });
      final repository = RadioBrowserRepository(
        client: client,
        mirrors: ['https://first.test', 'https://second.test'],
        maxResponseBytes: 16,
      );
      addTearDown(repository.close);
      expect(await repository.getCandidates(), isEmpty);
      expect(hosts, ['first.test', 'second.test']);
      expect(cancelled, isTrue);
      await body.close();
    },
  );

  test('a chunked response cannot evade the size limit', () async {
    final client = StreamingClient(
      (request) async => http.StreamedResponse(
        Stream.fromIterable([
          utf8.encode('['),
          utf8.encode(' ' * 32),
          utf8.encode(']'),
        ]),
        200,
      ),
    );
    final repository = RadioBrowserRepository(
      client: client,
      mirrors: ['https://mirror.test'],
      maxResponseBytes: 16,
    );
    addTearDown(repository.close);
    await expectLater(
      repository.getCandidates(),
      throwsA(isA<http.ClientException>()),
    );
  });

  test(
    'closing aborts a pending request and never tries another mirror',
    () async {
      final started = Completer<void>();
      final pending = Completer<http.StreamedResponse>();
      var calls = 0;
      final client = StreamingClient((request) {
        calls++;
        (request as http.AbortableRequest).abortTrigger!.then((_) {
          pending.completeError(http.RequestAbortedException(request.url));
        });
        started.complete();
        return pending.future;
      });
      final repository = RadioBrowserRepository(
        client: client,
        mirrors: ['https://first.test', 'https://second.test'],
      );
      final result = expectLater(
        repository.getCandidates(),
        throwsA(isA<http.RequestAbortedException>()),
      );
      await started.future;
      repository.close();
      await result;
      expect(calls, 1);
      expect(
        client.closed,
        isFalse,
        reason: 'The caller owns an injected transport',
      );
      await expectLater(repository.getCandidates(), throwsStateError);
    },
  );

  test('a stalled response is aborted before fallback', () async {
    var aborted = false;
    var calls = 0;
    final stalled = StreamController<List<int>>();
    final client = StreamingClient((request) async {
      calls++;
      if (calls == 1) {
        (request as http.AbortableRequest).abortTrigger!.then((_) {
          aborted = true;
          stalled.addError(http.RequestAbortedException(request.url));
          unawaited(stalled.close());
        });
        return http.StreamedResponse(stalled.stream, 200);
      }
      return http.StreamedResponse(Stream.value(utf8.encode('[]')), 200);
    });
    final repository = RadioBrowserRepository(
      client: client,
      mirrors: ['https://first.test', 'https://second.test'],
      timeout: const Duration(milliseconds: 20),
    );
    addTearDown(repository.close);
    expect(await repository.getCandidates(), isEmpty);
    expect(aborted, isTrue);
    expect(calls, 2);
  });

  test('insecure mirror configuration never sends a request', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return http.Response('[]', 200);
    });
    final repository = RadioBrowserRepository(
      client: client,
      mirrors: ['http://insecure.test'],
    );
    addTearDown(repository.close);
    await expectLater(repository.getCandidates(), throwsFormatException);
    expect(calls, 0);
  });

  test(
    'catalogue and saved records reject the same malformed stream URLs',
    () async {
      final urls = [
        'https://',
        'https:///missing',
        'https://user:password@host.test/live',
        'https://host.test:70000/live',
        'http://host.test/live',
      ];
      final data = [
        for (var i = 0; i < urls.length; i++)
          {...rawStation('$i', 'IT'), 'url_resolved': urls[i]},
        rawStation('valid', 'IT'),
      ];
      final repository = RadioBrowserRepository(
        client: MockClient((_) async => http.Response(jsonEncode(data), 200)),
        mirrors: ['https://mirror.test'],
      );
      addTearDown(repository.close);
      expect((await repository.getCandidates()).map((s) => s.id), ['valid']);
      for (final url in urls) {
        expect(
          stationFromRecord({'id': 'id', 'name': 'Name', 'url': url}),
          isNull,
          reason: url,
        );
      }
    },
  );

  test(
    'oversized names are rejected and optional metadata is bounded',
    () async {
      final data = [
        {...rawStation('bad', 'IT'), 'name': 'x' * (StationInput.name + 1)},
        {
          ...rawStation('valid', 'IT'),
          'country': 'x' * 300,
          'codec': 'x' * 100,
          'favicon': 'https://',
          'tags': '${'x' * 65},jazz,chill',
        },
      ];
      final repository = RadioBrowserRepository(
        client: MockClient((_) async => http.Response(jsonEncode(data), 200)),
        mirrors: ['https://mirror.test'],
      );
      addTearDown(repository.close);
      final station = (await repository.getCandidates()).single;
      expect(station.id, 'valid');
      expect(station.country, isEmpty);
      expect(station.codec, isNull);
      expect(station.faviconUrl, isNull);
      expect(station.tags, ['jazz', 'chill']);
    },
  );

  test(
    'the resolved app identity is used without a stale hardcoded version',
    () async {
      String? sent;
      final repository = RadioBrowserRepository(
        client: MockClient((request) async {
          sent = request.headers['User-Agent'];
          return http.Response('[]', 200);
        }),
        mirrors: ['https://mirror.test'],
        resolvedUserAgent: Future.value(
          'Frequenza/0.4.1+6 (it.davidetarsi.frequenza)',
        ),
      );
      addTearDown(repository.close);
      await repository.getCandidates();
      expect(sent, 'Frequenza/0.4.1+6 (it.davidetarsi.frequenza)');
    },
  );
  test('diary snapshots share validation and preserve full metadata', () {
    final snapshot = {
      'id': 'radio',
      'name': 'Radio',
      'url': 'https://stream.test/live',
      'country': 'Italy',
      'code': 'IT',
      'codec': 'MP3',
      'bitrate': 128,
      'faviconUrl': 'https://image.test/radio.png',
      'tags': ['jazz'],
    };
    final station = stationFromSnapshot(snapshot)!;
    expect(station.codec, 'MP3');
    expect(station.faviconUrl, 'https://image.test/radio.png');
    expect(stationFromSnapshot({...snapshot, 'url': 'https://'}), isNull);
    expect(stationFromSnapshot({...snapshot, 'name': 'x' * 513}), isNull);
  });
  test(
    'catalogue redirects never downgrade transport or bypass mirror fallback',
    () async {
      final hosts = <String>[];
      final client = MockClient((request) async {
        hosts.add(request.url.host);
        expect(request.followRedirects, isFalse);
        if (hosts.length == 1) {
          return http.Response(
            '',
            302,
            headers: {'location': 'http://insecure.test/'},
          );
        }
        return http.Response('[]', 200);
      });
      final repository = RadioBrowserRepository(
        client: client,
        mirrors: ['https://first.test', 'https://second.test'],
      );
      addTearDown(repository.close);
      expect(await repository.getCandidates(), isEmpty);
      expect(hosts, ['first.test', 'second.test']);
    },
  );
  test('saved records keep the canonical URL that passed validation', () {
    final station = stationFromRecord({
      'id': 'id',
      'name': 'Radio',
      'url': ' HTTPS://stream.test/live  ',
    });
    expect(station?.streamUrl, 'https://stream.test/live');
  });
}
