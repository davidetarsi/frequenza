import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'diary_database.g.dart';

/// Every station heard, whole, so it can be tuned in again offline.
@DataClassName('StationRow')
class Stations extends Table {
  TextColumn get id => text()();

  /// The `RadioStation` as `toJson` writes it.
  TextColumn get json => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One row per continuous listen.
@DataClassName('ListenRow')
@TableIndex(name: 'listens_started_at', columns: {#startedAt})
class Listens extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get stationId => text().references(Stations, #id)();
  TextColumn get countryCode => text()();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get seconds => integer()();
}

@DriftDatabase(tables: [Stations, Listens])
class DiaryDatabase extends _$DiaryDatabase {
  DiaryDatabase(super.executor);

  /// The file `frequenza.sqlite` in the app's data folder.
  DiaryDatabase.onPhone() : super(driftDatabase(name: 'frequenza'));

  @override
  int get schemaVersion => 1;
}
