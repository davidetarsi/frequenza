import 'package:freezed_annotation/freezed_annotation.dart';

part 'diary_duration.freezed.dart';

/// A time in the diary, as it is told: under a minute, minutes, or hours.
@freezed
sealed class DiaryDuration with _$DiaryDuration {
  const factory DiaryDuration.underAMinute() = UnderAMinute;
  const factory DiaryDuration.minutes(int minutes) = DiaryMinutes;
  const factory DiaryDuration.hours(int hours) = DiaryHours;
}

/// Rounded to the nearest unit: 1 h 29 is 1 h, 1 h 31 is 2 h; 59.5 minutes
/// is already an hour.
DiaryDuration diaryDurationOf(int seconds) {
  if (seconds < 60) return const DiaryDuration.underAMinute();
  final minutes = (seconds / 60).round();
  if (minutes < 60) return DiaryDuration.minutes(minutes);
  return DiaryDuration.hours((seconds / 3600).round());
}
