import 'package:freezed_annotation/freezed_annotation.dart';

import '../../radio/domain/journey.dart';
import '../../radio/domain/radio_session.dart';
import '../../radio/domain/radio_station.dart';

part 'listening.freezed.dart';

/// The listen being counted, one state at a time.
@freezed
sealed class Listening with _$Listening {
  /// No station plays.
  const factory Listening.idle() = Idle;

  /// A station plays: the count runs from [since], less the stalls over.
  const factory Listening.counting(
    RadioStation station, {
    required Duration since,
    @Default(Duration.zero) Duration stalled,
    @Default(false) bool written,
    @Default(0) int lastSeconds,
  }) = Counting;

  /// The same station stalls (buffering, or a reconnect): the count stops
  /// at [stalledAt], and the listen waits [stallGrace] for it to play again.
  const factory Listening.stalled(
    RadioStation station, {
    required Duration since,
    required Duration stalledAt,
    @Default(Duration.zero) Duration stalled,
    @Default(false) bool written,
    @Default(0) int lastSeconds,
  }) = Stalled;
}

/// What happened, on the monotonic clock.
sealed class ListenEvent {
  const ListenEvent({required this.at});
  final Duration at;
}

/// The radio is now [session].
final class RadioChanged extends ListenEvent {
  const RadioChanged(this.session, {required super.at});
  final RadioSession session;
}

/// Time passes: the total may need writing.
final class ClockTicked extends ListenEvent {
  const ClockTicked({required super.at});
}

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

/// A listen is written from five seconds on.
const minimumListenSeconds = 5;

/// How long a stall on the same station may last without ending the listen.
const stallGrace = Duration(seconds: 30);

typedef ListenStep = ({Listening state, List<ListenWrite> writes});

/// The log's transitions. Only a station that really plays counts; a
/// listen is written from five seconds on, at the first tick or at its
/// end; a stall on the same station within [stallGrace] does not split it,
/// and its seconds are not counted.
///
/// | From     | Event                                   | To       | Writes                      |
/// |----------|-----------------------------------------|----------|-----------------------------|
/// | Idle     | RadioChanged(plays S)                   | Counting | —                           |
/// | Counting | ClockTicked, ≥ 5 s, not written         | Counting | StartListen                 |
/// | Counting | ClockTicked, total changed, written     | Counting | UpdateListen                |
/// | Counting | RadioChanged(same S buffering/reconnect)| Stalled  | —                           |
/// | Stalled  | RadioChanged(plays S) within grace      | Counting | —                           |
/// | Stalled  | ClockTicked past grace                  | Idle     | finish at the stall         |
/// | Counting | RadioChanged(anything else)             | Idle or  | finish: StartListen first   |
/// | Stalled  |                                         | Counting | if not written and ≥ 5 s,   |
/// |          |                                         | (new S)  | then FinishListen           |
/// | any      | every other pair                        | same     | —                           |
ListenStep nextListening(Listening state, ListenEvent event) {
  final now = event.at;
  switch ((state, event)) {
    case (Counting counting, ClockTicked()):
      return _tick(counting, now);
    case (Stalled stalled, ClockTicked())
        when now - stalled.stalledAt > stallGrace:
      return (state: const Listening.idle(), writes: _finish(stalled, now));
    case (_, ClockTicked()):
      return (state: state, writes: const []);
    case (_, RadioChanged(:final session)):
      final playing = switch (session) {
        OnAir(playback: OnAirPlayback.playing, :final station) => station,
        _ => null,
      };
      switch (state) {
        case Counting(:final station) when station.id == playing?.id:
          return (state: state, writes: const []);
        case Stalled(:final station) when station.id == playing?.id:
          return (state: _resume(state, now), writes: const []);
        case Counting(:final station) when _stalls(session, station):
          return (state: _stall(state, now), writes: const []);
        case Stalled(:final station, :final stalledAt)
            when _stalls(session, station) && now - stalledAt <= stallGrace:
          return (state: state, writes: const []);
        case Idle():
          return (state: _start(playing, now), writes: const []);
        default:
          return (state: _start(playing, now), writes: _finish(state, now));
      }
  }
}

Listening _start(RadioStation? playing, Duration now) => playing == null
    ? const Listening.idle()
    : Listening.counting(playing, since: now);

bool _stalls(RadioSession session, RadioStation station) => switch (session) {
  OnAir(playback: OnAirPlayback.buffering, station: final other) =>
    other.id == station.id,
  Flying(kind: FlightKind.reconnect) => true,
  _ => false,
};

Listening _stall(Counting counting, Duration now) => Listening.stalled(
  counting.station,
  since: counting.since,
  stalledAt: now,
  stalled: counting.stalled,
  written: counting.written,
  lastSeconds: counting.lastSeconds,
);

Listening _resume(Stalled stalled, Duration now) => Listening.counting(
  stalled.station,
  since: stalled.since,
  stalled: stalled.stalled + (now - stalled.stalledAt),
  written: stalled.written,
  lastSeconds: stalled.lastSeconds,
);

/// The seconds counted so far: a stall stops the count where it began.
int _seconds(Listening state, Duration now) => switch (state) {
  Idle() => 0,
  Counting(:final since, :final stalled) => (now - since - stalled).inSeconds,
  Stalled(:final since, :final stalled, :final stalledAt) =>
    (stalledAt - since - stalled).inSeconds,
};

ListenStep _tick(Counting counting, Duration now) {
  final seconds = _seconds(counting, now);
  if (!counting.written) {
    if (seconds < minimumListenSeconds) {
      return (state: counting, writes: const []);
    }
    return (
      state: counting.copyWith(written: true, lastSeconds: seconds),
      writes: [
        StartListen(counting.station, since: counting.since, seconds: seconds),
      ],
    );
  }
  if (seconds == counting.lastSeconds) {
    return (state: counting, writes: const []);
  }
  return (
    state: counting.copyWith(lastSeconds: seconds),
    writes: [UpdateListen(seconds)],
  );
}

List<ListenWrite> _finish(Listening state, Duration now) {
  final (station, since, written) = switch (state) {
    Idle() => (null, Duration.zero, false),
    Counting(:final station, :final since, :final written) ||
    Stalled(
      :final station,
      :final since,
      :final written,
    ) => (station, since, written),
  };
  if (station == null) return const [];
  final seconds = _seconds(state, now);
  if (!written && seconds < minimumListenSeconds) return const [];
  return [
    if (!written) StartListen(station, since: since, seconds: seconds),
    FinishListen(station, seconds: seconds),
  ];
}
