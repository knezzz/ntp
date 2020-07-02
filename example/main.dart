import 'package:ntp/ntp.dart';

Future<void> main() async {
  DateTime _myTime;
  DateTime _ntpTime;

  /// Or you could get NTP current (It will call DateTime.now() and add NTP offset to it)
  _myTime = await NTP.now();

  /// Or get NTP offset (in milliseconds) and add it yourself
  final int offset = await NTP.getNtpOffset(localTime: DateTime.now());
  _ntpTime = _myTime.add(Duration(milliseconds: offset));

  print('My time: $_myTime');
  print('NTP time: $_ntpTime');
  print('Difference: ${_myTime.difference(_ntpTime).inMilliseconds}ms');
}
