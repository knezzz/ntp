import 'package:test/test.dart';

import 'package:ntp/ntp.dart';

void main() {
  test('test NTP time', () async {
    NTP ntp = new NTP();
    expect(await ntp.getNtpTime(), isNonZero);
  });

  test('test NTP wrong start time', () async {
    NTP ntp = new NTP();

    DateTime startDate = new DateTime(2017);

    int offset = await ntp.getNtpTime(localTime: startDate);

    print('First: $startDate');
    print('NTP Align: ${startDate.add(new Duration(milliseconds: offset))}');
  });
}
