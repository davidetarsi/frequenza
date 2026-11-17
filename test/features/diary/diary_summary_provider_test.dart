import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/diary/application/diary_providers.dart';
import 'package:frequenza/features/diary/application/diary_summary_provider.dart';
import 'package:frequenza/features/diary/application/listen_recorder.dart';
import 'package:frequenza/features/diary/domain/diary_period.dart';
import 'package:frequenza/features/diary/domain/diary_summary.dart';

import '../radio/journey_test.dart' show station;
import 'listen_recorder_test.dart' show MemoryDiary;

void main() {
  test('the summary of a period reads only its listens', () async {
    final now = DateTime.utc(2026, 11, 17, 12);
    final diary = MemoryDiary();
    await diary.startListen(
      station(1, code: 'BR'),
      startedAt: now.subtract(const Duration(days: 3)),
      seconds: 600,
    );
    await diary.startListen(
      station(2, code: 'DE'),
      startedAt: now.subtract(const Duration(days: 20)),
      seconds: 900,
    );
    final container = ProviderContainer(
      overrides: [
        diaryRepositoryProvider.overrideWithValue(diary),
        diaryClockProvider.overrideWithValue((
          elapsed: () => Duration.zero,
          utcNow: () => now,
        )),
      ],
    );
    addTearDown(container.dispose);

    final week =
        await container.read(diarySummaryProvider(DiaryPeriod.week).future)
            as DiaryFilled;
    final month =
        await container.read(diarySummaryProvider(DiaryPeriod.month).future)
            as DiaryFilled;
    expect(week.countries.map((c) => c.code), ['BR']);
    expect(month.countries.map((c) => c.code), ['DE', 'BR']);
  });
}
