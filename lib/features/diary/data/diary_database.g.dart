// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_database.dart';

// ignore_for_file: type=lint
class $StationsTable extends Stations
    with TableInfo<$StationsTable, StationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stations';
  @override
  VerificationContext validateIntegrity(
    Insertable<StationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $StationsTable createAlias(String alias) {
    return $StationsTable(attachedDatabase, alias);
  }
}

class StationRow extends DataClass implements Insertable<StationRow> {
  final String id;

  /// The `RadioStation` as `toJson` writes it.
  final String json;
  const StationRow({required this.id, required this.json});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json'] = Variable<String>(json);
    return map;
  }

  StationsCompanion toCompanion(bool nullToAbsent) {
    return StationsCompanion(id: Value(id), json: Value(json));
  }

  factory StationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StationRow(
      id: serializer.fromJson<String>(json['id']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'json': serializer.toJson<String>(json),
    };
  }

  StationRow copyWith({String? id, String? json}) =>
      StationRow(id: id ?? this.id, json: json ?? this.json);
  StationRow copyWithCompanion(StationsCompanion data) {
    return StationRow(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StationRow(')
          ..write('id: $id, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StationRow && other.id == this.id && other.json == this.json);
}

class StationsCompanion extends UpdateCompanion<StationRow> {
  final Value<String> id;
  final Value<String> json;
  final Value<int> rowid;
  const StationsCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StationsCompanion.insert({
    required String id,
    required String json,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       json = Value(json);
  static Insertable<StationRow> custom({
    Expression<String>? id,
    Expression<String>? json,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StationsCompanion copyWith({
    Value<String>? id,
    Value<String>? json,
    Value<int>? rowid,
  }) {
    return StationsCompanion(
      id: id ?? this.id,
      json: json ?? this.json,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StationsCompanion(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ListensTable extends Listens with TableInfo<$ListensTable, ListenRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _stationIdMeta = const VerificationMeta(
    'stationId',
  );
  @override
  late final GeneratedColumn<String> stationId = GeneratedColumn<String>(
    'station_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stations (id)',
    ),
  );
  static const VerificationMeta _countryCodeMeta = const VerificationMeta(
    'countryCode',
  );
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
    'country_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secondsMeta = const VerificationMeta(
    'seconds',
  );
  @override
  late final GeneratedColumn<int> seconds = GeneratedColumn<int>(
    'seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stationId,
    countryCode,
    startedAt,
    seconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'listens';
  @override
  VerificationContext validateIntegrity(
    Insertable<ListenRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('station_id')) {
      context.handle(
        _stationIdMeta,
        stationId.isAcceptableOrUnknown(data['station_id']!, _stationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stationIdMeta);
    }
    if (data.containsKey('country_code')) {
      context.handle(
        _countryCodeMeta,
        countryCode.isAcceptableOrUnknown(
          data['country_code']!,
          _countryCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_countryCodeMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('seconds')) {
      context.handle(
        _secondsMeta,
        seconds.isAcceptableOrUnknown(data['seconds']!, _secondsMeta),
      );
    } else if (isInserting) {
      context.missing(_secondsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListenRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListenRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      stationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}station_id'],
      )!,
      countryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_code'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      seconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seconds'],
      )!,
    );
  }

  @override
  $ListensTable createAlias(String alias) {
    return $ListensTable(attachedDatabase, alias);
  }
}

class ListenRow extends DataClass implements Insertable<ListenRow> {
  final int id;
  final String stationId;
  final String countryCode;
  final DateTime startedAt;
  final int seconds;
  const ListenRow({
    required this.id,
    required this.stationId,
    required this.countryCode,
    required this.startedAt,
    required this.seconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['station_id'] = Variable<String>(stationId);
    map['country_code'] = Variable<String>(countryCode);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['seconds'] = Variable<int>(seconds);
    return map;
  }

  ListensCompanion toCompanion(bool nullToAbsent) {
    return ListensCompanion(
      id: Value(id),
      stationId: Value(stationId),
      countryCode: Value(countryCode),
      startedAt: Value(startedAt),
      seconds: Value(seconds),
    );
  }

  factory ListenRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListenRow(
      id: serializer.fromJson<int>(json['id']),
      stationId: serializer.fromJson<String>(json['stationId']),
      countryCode: serializer.fromJson<String>(json['countryCode']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      seconds: serializer.fromJson<int>(json['seconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'stationId': serializer.toJson<String>(stationId),
      'countryCode': serializer.toJson<String>(countryCode),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'seconds': serializer.toJson<int>(seconds),
    };
  }

  ListenRow copyWith({
    int? id,
    String? stationId,
    String? countryCode,
    DateTime? startedAt,
    int? seconds,
  }) => ListenRow(
    id: id ?? this.id,
    stationId: stationId ?? this.stationId,
    countryCode: countryCode ?? this.countryCode,
    startedAt: startedAt ?? this.startedAt,
    seconds: seconds ?? this.seconds,
  );
  ListenRow copyWithCompanion(ListensCompanion data) {
    return ListenRow(
      id: data.id.present ? data.id.value : this.id,
      stationId: data.stationId.present ? data.stationId.value : this.stationId,
      countryCode: data.countryCode.present
          ? data.countryCode.value
          : this.countryCode,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      seconds: data.seconds.present ? data.seconds.value : this.seconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListenRow(')
          ..write('id: $id, ')
          ..write('stationId: $stationId, ')
          ..write('countryCode: $countryCode, ')
          ..write('startedAt: $startedAt, ')
          ..write('seconds: $seconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, stationId, countryCode, startedAt, seconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListenRow &&
          other.id == this.id &&
          other.stationId == this.stationId &&
          other.countryCode == this.countryCode &&
          other.startedAt == this.startedAt &&
          other.seconds == this.seconds);
}

class ListensCompanion extends UpdateCompanion<ListenRow> {
  final Value<int> id;
  final Value<String> stationId;
  final Value<String> countryCode;
  final Value<DateTime> startedAt;
  final Value<int> seconds;
  const ListensCompanion({
    this.id = const Value.absent(),
    this.stationId = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.seconds = const Value.absent(),
  });
  ListensCompanion.insert({
    this.id = const Value.absent(),
    required String stationId,
    required String countryCode,
    required DateTime startedAt,
    required int seconds,
  }) : stationId = Value(stationId),
       countryCode = Value(countryCode),
       startedAt = Value(startedAt),
       seconds = Value(seconds);
  static Insertable<ListenRow> custom({
    Expression<int>? id,
    Expression<String>? stationId,
    Expression<String>? countryCode,
    Expression<DateTime>? startedAt,
    Expression<int>? seconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stationId != null) 'station_id': stationId,
      if (countryCode != null) 'country_code': countryCode,
      if (startedAt != null) 'started_at': startedAt,
      if (seconds != null) 'seconds': seconds,
    });
  }

  ListensCompanion copyWith({
    Value<int>? id,
    Value<String>? stationId,
    Value<String>? countryCode,
    Value<DateTime>? startedAt,
    Value<int>? seconds,
  }) {
    return ListensCompanion(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      countryCode: countryCode ?? this.countryCode,
      startedAt: startedAt ?? this.startedAt,
      seconds: seconds ?? this.seconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (stationId.present) {
      map['station_id'] = Variable<String>(stationId.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (seconds.present) {
      map['seconds'] = Variable<int>(seconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListensCompanion(')
          ..write('id: $id, ')
          ..write('stationId: $stationId, ')
          ..write('countryCode: $countryCode, ')
          ..write('startedAt: $startedAt, ')
          ..write('seconds: $seconds')
          ..write(')'))
        .toString();
  }
}

abstract class _$DiaryDatabase extends GeneratedDatabase {
  _$DiaryDatabase(QueryExecutor e) : super(e);
  $DiaryDatabaseManager get managers => $DiaryDatabaseManager(this);
  late final $StationsTable stations = $StationsTable(this);
  late final $ListensTable listens = $ListensTable(this);
  late final Index listensStartedAt = Index(
    'listens_started_at',
    'CREATE INDEX listens_started_at ON listens (started_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    stations,
    listens,
    listensStartedAt,
  ];
}

typedef $$StationsTableCreateCompanionBuilder =
    StationsCompanion Function({
      required String id,
      required String json,
      Value<int> rowid,
    });
typedef $$StationsTableUpdateCompanionBuilder =
    StationsCompanion Function({
      Value<String> id,
      Value<String> json,
      Value<int> rowid,
    });

final class $$StationsTableReferences
    extends BaseReferences<_$DiaryDatabase, $StationsTable, StationRow> {
  $$StationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ListensTable, List<ListenRow>> _listensRefsTable(
    _$DiaryDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.listens,
    aliasName: $_aliasNameGenerator(db.stations.id, db.listens.stationId),
  );

  $$ListensTableProcessedTableManager get listensRefs {
    final manager = $$ListensTableTableManager(
      $_db,
      $_db.listens,
    ).filter((f) => f.stationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_listensRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StationsTableFilterComposer
    extends Composer<_$DiaryDatabase, $StationsTable> {
  $$StationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> listensRefs(
    Expression<bool> Function($$ListensTableFilterComposer f) f,
  ) {
    final $$ListensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.listens,
      getReferencedColumn: (t) => t.stationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ListensTableFilterComposer(
            $db: $db,
            $table: $db.listens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StationsTableOrderingComposer
    extends Composer<_$DiaryDatabase, $StationsTable> {
  $$StationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StationsTableAnnotationComposer
    extends Composer<_$DiaryDatabase, $StationsTable> {
  $$StationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  Expression<T> listensRefs<T extends Object>(
    Expression<T> Function($$ListensTableAnnotationComposer a) f,
  ) {
    final $$ListensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.listens,
      getReferencedColumn: (t) => t.stationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ListensTableAnnotationComposer(
            $db: $db,
            $table: $db.listens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StationsTableTableManager
    extends
        RootTableManager<
          _$DiaryDatabase,
          $StationsTable,
          StationRow,
          $$StationsTableFilterComposer,
          $$StationsTableOrderingComposer,
          $$StationsTableAnnotationComposer,
          $$StationsTableCreateCompanionBuilder,
          $$StationsTableUpdateCompanionBuilder,
          (StationRow, $$StationsTableReferences),
          StationRow,
          PrefetchHooks Function({bool listensRefs})
        > {
  $$StationsTableTableManager(_$DiaryDatabase db, $StationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StationsCompanion(id: id, json: json, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String json,
                Value<int> rowid = const Value.absent(),
              }) => StationsCompanion.insert(id: id, json: json, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({listensRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (listensRefs) db.listens],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (listensRefs)
                    await $_getPrefetchedData<
                      StationRow,
                      $StationsTable,
                      ListenRow
                    >(
                      currentTable: table,
                      referencedTable: $$StationsTableReferences
                          ._listensRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StationsTableReferences(db, table, p0).listensRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.stationId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StationsTableProcessedTableManager =
    ProcessedTableManager<
      _$DiaryDatabase,
      $StationsTable,
      StationRow,
      $$StationsTableFilterComposer,
      $$StationsTableOrderingComposer,
      $$StationsTableAnnotationComposer,
      $$StationsTableCreateCompanionBuilder,
      $$StationsTableUpdateCompanionBuilder,
      (StationRow, $$StationsTableReferences),
      StationRow,
      PrefetchHooks Function({bool listensRefs})
    >;
typedef $$ListensTableCreateCompanionBuilder =
    ListensCompanion Function({
      Value<int> id,
      required String stationId,
      required String countryCode,
      required DateTime startedAt,
      required int seconds,
    });
typedef $$ListensTableUpdateCompanionBuilder =
    ListensCompanion Function({
      Value<int> id,
      Value<String> stationId,
      Value<String> countryCode,
      Value<DateTime> startedAt,
      Value<int> seconds,
    });

final class $$ListensTableReferences
    extends BaseReferences<_$DiaryDatabase, $ListensTable, ListenRow> {
  $$ListensTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StationsTable _stationIdTable(_$DiaryDatabase db) => db.stations
      .createAlias($_aliasNameGenerator(db.listens.stationId, db.stations.id));

  $$StationsTableProcessedTableManager get stationId {
    final $_column = $_itemColumn<String>('station_id')!;

    final manager = $$StationsTableTableManager(
      $_db,
      $_db.stations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ListensTableFilterComposer
    extends Composer<_$DiaryDatabase, $ListensTable> {
  $$ListensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seconds => $composableBuilder(
    column: $table.seconds,
    builder: (column) => ColumnFilters(column),
  );

  $$StationsTableFilterComposer get stationId {
    final $$StationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationId,
      referencedTable: $db.stations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationsTableFilterComposer(
            $db: $db,
            $table: $db.stations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListensTableOrderingComposer
    extends Composer<_$DiaryDatabase, $ListensTable> {
  $$ListensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seconds => $composableBuilder(
    column: $table.seconds,
    builder: (column) => ColumnOrderings(column),
  );

  $$StationsTableOrderingComposer get stationId {
    final $$StationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationId,
      referencedTable: $db.stations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationsTableOrderingComposer(
            $db: $db,
            $table: $db.stations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListensTableAnnotationComposer
    extends Composer<_$DiaryDatabase, $ListensTable> {
  $$ListensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get seconds =>
      $composableBuilder(column: $table.seconds, builder: (column) => column);

  $$StationsTableAnnotationComposer get stationId {
    final $$StationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationId,
      referencedTable: $db.stations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationsTableAnnotationComposer(
            $db: $db,
            $table: $db.stations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListensTableTableManager
    extends
        RootTableManager<
          _$DiaryDatabase,
          $ListensTable,
          ListenRow,
          $$ListensTableFilterComposer,
          $$ListensTableOrderingComposer,
          $$ListensTableAnnotationComposer,
          $$ListensTableCreateCompanionBuilder,
          $$ListensTableUpdateCompanionBuilder,
          (ListenRow, $$ListensTableReferences),
          ListenRow,
          PrefetchHooks Function({bool stationId})
        > {
  $$ListensTableTableManager(_$DiaryDatabase db, $ListensTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> stationId = const Value.absent(),
                Value<String> countryCode = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> seconds = const Value.absent(),
              }) => ListensCompanion(
                id: id,
                stationId: stationId,
                countryCode: countryCode,
                startedAt: startedAt,
                seconds: seconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String stationId,
                required String countryCode,
                required DateTime startedAt,
                required int seconds,
              }) => ListensCompanion.insert(
                id: id,
                stationId: stationId,
                countryCode: countryCode,
                startedAt: startedAt,
                seconds: seconds,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ListensTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (stationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.stationId,
                                referencedTable: $$ListensTableReferences
                                    ._stationIdTable(db),
                                referencedColumn: $$ListensTableReferences
                                    ._stationIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ListensTableProcessedTableManager =
    ProcessedTableManager<
      _$DiaryDatabase,
      $ListensTable,
      ListenRow,
      $$ListensTableFilterComposer,
      $$ListensTableOrderingComposer,
      $$ListensTableAnnotationComposer,
      $$ListensTableCreateCompanionBuilder,
      $$ListensTableUpdateCompanionBuilder,
      (ListenRow, $$ListensTableReferences),
      ListenRow,
      PrefetchHooks Function({bool stationId})
    >;

class $DiaryDatabaseManager {
  final _$DiaryDatabase _db;
  $DiaryDatabaseManager(this._db);
  $$StationsTableTableManager get stations =>
      $$StationsTableTableManager(_db, _db.stations);
  $$ListensTableTableManager get listens =>
      $$ListensTableTableManager(_db, _db.listens);
}
