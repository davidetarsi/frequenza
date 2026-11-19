import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/welcome/domain/welcome_session.dart';

void main() {
  test('the three explanations lead to recording and then completion', () {
    var session = const WelcomeSession.radio();
    session = nextWelcome(session, const WelcomeEvent.advance());
    expect(session, const WelcomeSession.favorites());
    session = nextWelcome(session, const WelcomeEvent.advance());
    expect(session, const WelcomeSession.diary());
    session = nextWelcome(session, const WelcomeEvent.advance());
    expect(session, const WelcomeSession.closing(WelcomeStep.diary));
    session = nextWelcome(session, const WelcomeEvent.completionRecorded());
    expect(session, const WelcomeSession.completed(WelcomeStep.diary));
  });

  for (final session in [
    const WelcomeSession.radio(),
    const WelcomeSession.favorites(),
    const WelcomeSession.diary(),
  ]) {
    test(
      'back from ${session.step.name} preserves the displayed explanation',
      () {
        expect(
          nextWelcome(session, const WelcomeEvent.dismiss()),
          WelcomeSession.closing(session.step),
        );
        expect(
          nextWelcome(session, const WelcomeEvent.completionRecorded()),
          same(session),
          reason: 'Only a guide already closing may complete',
        );
      },
    );
  }

  for (final session in [
    const WelcomeSession.closing(WelcomeStep.favorites),
    const WelcomeSession.completed(WelcomeStep.favorites),
  ]) {
    test('taps and back are ignored in $session', () {
      expect(session.isClosing, isTrue);
      expect(nextWelcome(session, const WelcomeEvent.advance()), same(session));
      expect(nextWelcome(session, const WelcomeEvent.dismiss()), same(session));
    });
  }
}
