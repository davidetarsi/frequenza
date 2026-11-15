import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/bootstrap.dart';

void main() {
  test('the paused notification can be swiped away', () {
    final config = radioServiceConfig(channelName: 'x');
    expect(config.androidNotificationOngoing, isFalse);
    expect(config.androidStopForegroundOnPause, isTrue);
  });
}
