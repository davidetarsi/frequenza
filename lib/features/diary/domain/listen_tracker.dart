import '../../radio/domain/journey.dart';
import '../../radio/domain/radio_session.dart';
import '../../radio/domain/radio_station.dart';

/// What the log must write: always the whole total, never an increment.
sealed class ListenWrite {
  const ListenWrite();
}

/// A new listen of [station], begun at [since] on the monotonic clock.
final class StartListen extends ListenWrite {
  const StartListen(this.station, {required this.since, required this.seconds});
  final RadioStation station;
  final Duration since;
  final int seconds;

  @override
  bool operator ==(Object other) =>
      other is StartListen &&
      other.station.id == station.id &&
      other.since == since &&
      other.seconds == seconds;

  @override
  int get hashCode => Object.hash(station.id, since, seconds);

  @override
  String toString() => 'StartListen(${station.id}, $since, $seconds)';
}

/// The current listen's total so far.
final class UpdateListen extends ListenWrite {
  const UpdateListen(this.seconds);
  final int seconds;

  @override
  bool operator ==(Object other) =>
      other is UpdateListen && other.seconds == seconds;

  @override
  int get hashCode => seconds.hashCode;

  @override
  String toString() => 'UpdateListen($seconds)';
}

/// The current listen's final total: it is closed.
final class FinishListen extends ListenWrite {
  const FinishListen(this.station, {required this.seconds});
  final RadioStation station;
  final int seconds;

  @override
  bool operator ==(Object other) =>
      other is FinishListen &&
      other.station.id == station.id &&
      other.seconds == seconds;

  @override
  int get hashCode => Object.hash(station.id, seconds);

  @override
  String toString() => 'FinishListen(${station.id}, $seconds)';
}

/// Decides, in memory and without I/O, when a listen starts, grows and
/// ends. Only a station that really plays counts; a listen is written
/// from five seconds on, at the first tick or at its end. A short network
/// stall on the same station (buffering, or a reconnect that lands back)
/// does not split the listen: its seconds are not counted, and past
/// [stallGrace] the listen ends where the stall began.
///
/// | Now                                 | Listening? | Writes                 |
/// |-------------------------------------|------------|------------------------|
/// | plays a station                     | no         | none; the count starts |
/// | tick, 5 s or more, not written      | yes        | StartListen            |
/// | tick, total changed, written        | yes        | UpdateListen           |
/// | stalls on the same station          | yes        | none; the count stops  |
/// | plays again within the grace        | stalled    | none; the count goes on|
/// | tick past the grace                 | stalled    | FinishListen           |
/// | stops playing / other station       | yes        | FinishListen (with a   |
/// |                                     |            | StartListen first if   |
/// |                                     |            | not written, 5 s +)    |
class ListenTracker {
  static const minimumSeconds = 5;
  static const stallGrace = Duration(seconds: 30);

  _Current? _current;

  /// The radio is now [session], at [now] on the monotonic clock.
  List<ListenWrite> observe(RadioSession session, Duration now) {
    final playing = switch (session) {
      OnAir(playback: OnAirPlayback.playing, :final station) => station,
      _ => null,
    };
    final current = _current;
    if (current != null) {
      if (current.station.id == playing?.id) {
        current.resume(now);
        return const [];
      }
      if (_stalls(session, current) && !current.stalledTooLong(now)) {
        current.stalledAt ??= now;
        return const [];
      }
    }
    final writes = current == null ? <ListenWrite>[] : _finish(current, now);
    _current = playing == null ? null : _Current(playing, since: now);
    return writes;
  }

  /// Time passes: the total is written when it should be.
  List<ListenWrite> tick(Duration now) {
    final current = _current;
    if (current == null) return const [];
    if (current.stalledAt != null) {
      if (!current.stalledTooLong(now)) return const [];
      _current = null;
      return _finish(current, now);
    }
    final seconds = current.secondsAt(now);
    if (!current.written) {
      if (seconds < minimumSeconds) return const [];
      current
        ..written = true
        ..lastSeconds = seconds;
      return [
        StartListen(current.station, since: current.since, seconds: seconds),
      ];
    }
    if (seconds == current.lastSeconds) return const [];
    current.lastSeconds = seconds;
    return [UpdateListen(seconds)];
  }

  static bool _stalls(RadioSession session, _Current current) =>
      switch (session) {
        OnAir(playback: OnAirPlayback.buffering, :final station) =>
          station.id == current.station.id,
        Flying(kind: FlightKind.reconnect) => true,
        _ => false,
      };

  List<ListenWrite> _finish(_Current current, Duration now) {
    final seconds = current.secondsAt(now);
    if (!current.written && seconds < minimumSeconds) return const [];
    return [
      if (!current.written)
        StartListen(current.station, since: current.since, seconds: seconds),
      FinishListen(current.station, seconds: seconds),
    ];
  }
}

class _Current {
  _Current(this.station, {required this.since});
  final RadioStation station;
  final Duration since;
  bool written = false;
  int lastSeconds = 0;

  /// When the current stall began, on the monotonic clock.
  Duration? stalledAt;

  /// The stalls already over, not counted.
  Duration stalled = Duration.zero;

  bool stalledTooLong(Duration now) =>
      stalledAt != null && now - stalledAt! > ListenTracker.stallGrace;

  void resume(Duration now) {
    if (stalledAt case final began?) stalled += now - began;
    stalledAt = null;
  }

  int secondsAt(Duration now) =>
      ((stalledAt ?? now) - since - stalled).inSeconds;
}
