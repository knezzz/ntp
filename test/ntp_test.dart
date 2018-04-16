import 'package:test/test.dart';

import 'package:ntp/ntp.dart';

void main() {
  test('test NTP time', () async {
    NTP ntp = new NTP();
    expect(await ntp.getNtpTime(), isNonZero);
  });
}
