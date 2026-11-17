import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/diary_period.dart';
import '../domain/diary_summary.dart';
import 'diary_providers.dart';
import 'listen_recorder.dart';

part 'diary_summary_provider.g.dart';

/// The diary of [period], computed again every time the log writes.
@riverpod
Stream<DiarySummary> diarySummary(Ref ref, DiaryPeriod period) {
  final diary = ref.watch(diaryRepositoryProvider);
  final since = period.since(ref.watch(diaryClockProvider).utcNow());
  return diary
      .watchListensSince(since)
      .asyncMap(
        (listens) async => summarize(listens, {
          for (final station in await diary.stations()) station.id: station,
        }),
      );
}
