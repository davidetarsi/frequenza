import '../../radio/domain/radio_session.dart';
import 'app_event.dart';

/// The events of one step of the radio, from the session [before] to the
/// session [after]. Every way of flying goes through the same steps, so a
/// flight counts once whoever started it.
///
/// | Before                  | After                     | Event            |
/// |-------------------------|---------------------------|------------------|
/// | not a fresh flight      | Flying, attempt 0, signal | flight_started   |
/// | Flying(attempt n)       | OnAir                     | flight_landed    |
/// | Flying(attempt n)       | Failed                    | flight_failed    |
/// | OnAir, not broken       | OnAir, broken             | playback_broken  |
///
/// Two turns inside the same first attempt leave the same session: they
/// count as one flight.
List<AppEvent> radioEvents(RadioSession before, RadioSession after) {
  bool fresh(RadioSession session) =>
      session is Flying && session.attempt == 0 && !session.signalLost;
  return [
    if (fresh(after) && !fresh(before))
      AppEvent.flightStarted((after as Flying).kind),
    if ((before, after) case (Flying flight, OnAir(:final station)))
      AppEvent.flightLanded(
        station,
        kind: flight.kind,
        attempts: flight.attempt + 1,
      ),
    if ((before, after) case (Flying flight, Failed()))
      AppEvent.flightFailed(kind: flight.kind, attempts: flight.attempt + 1),
    if ((before, after) case (
      OnAir(playback: != OnAirPlayback.broken),
      OnAir(playback: OnAirPlayback.broken, :final station),
    ))
      AppEvent.playbackBroken(station),
  ];
}
