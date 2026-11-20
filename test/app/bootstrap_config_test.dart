import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/bootstrap.dart';

void main() {
  test('the service stays in the foreground while paused', () {
    // Android forbids going back to the foreground from the background:
    // a play from the headphones after a pause would leave the radio
    // without its service, muted and then frozen by the system.
    final config = radioServiceConfig(channelName: 'x');
    expect(config.androidStopForegroundOnPause, isFalse);
    expect(config.androidNotificationOngoing, isFalse);
    expect(config.androidResumeOnClick, isFalse);
  });
}
