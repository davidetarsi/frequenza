import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/network/domain/https_uri.dart';

void main() {
  test(
    'HTTPS validation rejects credentials, invalid ports and hostless URLs',
    () {
      for (final value in [
        'http://host.test',
        'https://',
        'https:radio',
        'https://user:password@host.test/live',
        'https://host.test:70000',
        'https://host.test:0',
        'https://host.test\n.invalid',
        'javascript:alert(1)',
      ]) {
        expect(httpsUri(value), isNull, reason: value);
      }
      expect(
        httpsUri('HTTPS://host.test:8443/live?token=a%2Bb')?.host,
        'host.test',
      );
      expect(httpsUri('https://host.test/${'x' * 8192}'), isNull);
    },
  );
}
