/// How long a flight may take: see the "Segnale perso" rules in the design.
class FlightTiming {
  const FlightTiming({
    this.minimum = const Duration(seconds: 1),
    this.attemptTimeout = const Duration(seconds: 12),
    this.autoRetries = 2,
    this.signalLostPause = const Duration(milliseconds: 900),
  });

  final Duration minimum, attemptTimeout, signalLostPause;

  /// Extra random stations tried by Tune after a lost signal.
  final int autoRetries;
}
