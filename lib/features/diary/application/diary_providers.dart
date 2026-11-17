import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/diary_database.dart';
import '../data/drift_diary_repository.dart';
import '../domain/diary_repository.dart';

part 'diary_providers.g.dart';

/// The log on the phone, open for the whole life of the app.
@Riverpod(keepAlive: true)
DiaryRepository diaryRepository(Ref ref) {
  final database = DiaryDatabase.onPhone();
  ref.onDispose(database.close);
  return DriftDiaryRepository(database);
}
