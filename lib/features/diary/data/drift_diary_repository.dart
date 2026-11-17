import 'dart:convert';

import 'package:drift/drift.dart';

import '../../radio/domain/radio_station.dart';
import '../domain/diary_repository.dart';
import '../domain/listen.dart';
import 'diary_database.dart';

class DriftDiaryRepository implements DiaryRepository {
  DriftDiaryRepository(this._db);

  final DiaryDatabase _db;

  @override
  Future<int> startListen(
    RadioStation station, {
    required DateTime startedAt,
    required int seconds,
  }) => _db.transaction(() async {
    await _db
        .into(_db.stations)
        .insertOnConflictUpdate(
          StationsCompanion.insert(
            id: station.id,
            json: jsonEncode(station.toJson()),
          ),
        );
    return _db
        .into(_db.listens)
        .insert(
          ListensCompanion.insert(
            stationId: station.id,
            countryCode: station.countryCode,
            startedAt: startedAt.toUtc(),
            seconds: seconds,
          ),
        );
  });

  @override
  Future<void> setSeconds(int listenId, int seconds) async {
    await (_db.update(_db.listens)..where((row) => row.id.equals(listenId)))
        .write(ListensCompanion(seconds: Value(seconds)));
  }

  @override
  Future<List<Listen>> listens() async => [
    for (final row in await _db.select(_db.listens).get())
      Listen(
        id: row.id,
        stationId: row.stationId,
        countryCode: row.countryCode,
        startedAt: row.startedAt.toUtc(),
        seconds: row.seconds,
      ),
  ];

  @override
  Future<List<RadioStation>> stations() async => [
    for (final row in await _db.select(_db.stations).get())
      RadioStation.fromJson(jsonDecode(row.json) as Map<String, dynamic>),
  ];
}
