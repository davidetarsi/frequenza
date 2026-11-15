/// How long a flight may take: see the "Segnale perso" rules in the design.
class FlightTiming {
  const FlightTiming({
    this.minimum = const Duration(seconds: 1),
    this.attemptTimeout = const Duration(seconds: 12),
    this.autoRetries = 2,
    this.signalLostPause = const Duration(milliseconds: 900),
    this.stallTimeout = const Duration(seconds: 10),
    this.pauseTimeout = const Duration(minutes: 10),
  });

  final Duration minimum, attemptTimeout, signalLostPause;

  /// How long a station on air may stay silent before reconnecting.
  final Duration stallTimeout;

  /// How long a pause may last before the stream and its notification
  /// close: a live radio would resume from now anyway.
  final Duration pauseTimeout;

  /// Extra random stations tried by Tune after a lost signal.
  final int autoRetries;
}
