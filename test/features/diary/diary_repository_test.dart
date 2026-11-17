import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/diary/data/diary_database.dart';
import 'package:frequenza/features/diary/data/drift_diary_repository.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';

const kexp = RadioStation(
  id: 'kexp',
  name: 'KEXP',
  streamUrl: 'https://kexp.example.com/live',
  country: 'The United States Of America',
  countryCode: 'US',
  faviconUrl: 'https://kexp.example.com/logo.png',
  codec: 'AAC',
  latitude: 47.6,
  longitude: -122.3,
);

void main() {
  late DiaryDatabase database;
  late DriftDiaryRepository repository;

  setUp(() {
    database = DiaryDatabase(NativeDatabase.memory());
    repository = DriftDiaryRepository(database);
  });
  tearDown(() => database.close());

  final noon = DateTime.utc(2026, 11, 17, 12);

  test('a listen saves its station and itself together', () async {
    final id = await repository.startListen(kexp, startedAt: noon, seconds: 30);

    final listen = (await repository.listens()).single;
    expect(listen.id, id);
    expect(listen.stationId, 'kexp');
    expect(listen.countryCode, 'US');
    expect(listen.startedAt, noon);
    expect(listen.startedAt.isUtc, isTrue);
    expect(listen.seconds, 30);

    final station = (await repository.stations()).single;
    expect(station.id, 'kexp');
    expect(station.faviconUrl, 'https://kexp.example.com/logo.png');
    expect(station.codec, 'AAC');
    expect(station.point?.latitude, 47.6);
  });

  test('a failed listen leaves no station behind', () async {
    await database.customStatement('DROP TABLE listens');
    await expectLater(
      repository.startListen(kexp, startedAt: noon, seconds: 30),
      throwsA(anything),
    );
    expect(await database.select(database.stations).get(), isEmpty);
  });

  test('setSeconds writes the total, twice is the same', () async {
    final id = await repository.startListen(kexp, startedAt: noon, seconds: 5);
    await repository.setSeconds(id, 60);
    await repository.setSeconds(id, 60);
    expect((await repository.listens()).single.seconds, 60);
  });

  test('a station heard again is updated, not duplicated', () async {
    await repository.startListen(kexp, startedAt: noon, seconds: 10);
    await repository.startListen(
      kexp.copyWith(name: 'KEXP 90.3'),
      startedAt: noon.add(const Duration(hours: 1)),
      seconds: 20,
    );
    expect(await repository.listens(), hasLength(2));
    expect((await repository.stations()).single.name, 'KEXP 90.3');
  });

  test('the schema is version 1, and its dump is in the repo', () {
    expect(database.schemaVersion, 1);
    expect(
      File('drift_schemas/diary/drift_schema_v1.json').existsSync(),
      isTrue,
    );
  });

  test('listens are indexed by start', () async {
    final indexes = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .map((row) => row.read<String>('name'))
        .get();
    expect(indexes, contains('listens_started_at'));
  });

  test('a listen of an unknown station is refused', () async {
    await expectLater(
      database
          .into(database.listens)
          .insert(
            ListensCompanion.insert(
              stationId: 'nowhere',
              countryCode: '',
              startedAt: noon,
              seconds: 10,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });
}
