import 'package:flutter_test/flutter_test.dart';
import 'package:ntp/ntp.dart';

void main() {
  test('test NTP time', () async {
    expect(await NTP.getNtpOffset(), isNonZero);
  });

  test('test NTP wrong start time', () async {
    final DateTime startDate = new DateTime(2019);
    final int offset = await NTP.getNtpOffset(localTime: startDate);

    print('First: $startDate');
    print('NTP Align: ${startDate.add(new Duration(milliseconds: offset))}');

    expect(offset, isNonZero);
  });

  test('test NTP now', () async {
    final DateTime phoneTime = DateTime.now();
    final DateTime ntpTime = await NTP.now();
    final int offset = await NTP.getNtpOffset();

    print('Offset is: $offset');
    print('Difference is: ${ntpTime.difference(phoneTime).inMilliseconds}');

    expect(offset, lessThan(ntpTime.difference(phoneTime).inMilliseconds));
  });
}
