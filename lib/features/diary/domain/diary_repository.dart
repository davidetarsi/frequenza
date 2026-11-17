import '../../radio/domain/radio_station.dart';
import 'listen.dart';

/// The log of listens, on the phone only.
abstract interface class DiaryRepository {
  /// Saves [station] and a new listen together; the listen's id.
  Future<int> startListen(
    RadioStation station, {
    required DateTime startedAt,
    required int seconds,
  });

  /// Writes the listen's total: the same total twice changes nothing.
  Future<void> setSeconds(int listenId, int seconds);

  Future<List<Listen>> listens();

  /// The listens begun at or after [since] (all when null), again every
  /// time the log changes.
  Stream<List<Listen>> watchListensSince(DateTime? since);

  Future<List<RadioStation>> stations();
}
