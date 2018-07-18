[![pub package](https://img.shields.io/pub/v/ntp.svg)](https://pub.dartlang.org/packages/ntp)

# ntp

Plugin that allows you to get precise time from Network Time Protocol (NTP).
Whole NTP protocol is implemented in dart.

By default lookup address for NTP is: pool.ntp.org

### How it works
Using int offset from getNtpTime()
- default localTime is DateTime.now()
- default lookUpAddress is 'pool.ntp.org'
- default port is 123
```dart
  DateTime startDate = new DateTime().now().toLocal();
  int offset = await NTP.getNtpTime(localTime: startDate);
  print('NTP DateTime offset align: ${startDate.add(new Duration(milliseconds: offset))}');
```

Using DateTime from now
```dart
  DateTime startDate = await NTP.now();
  print('NTP DateTime: ${startDate}');
```

### NTP Functions
```dart
  Future<int> getNtpTime({
    String lookUpAddress: 'pool.ntp.org',
    int port: 123,
    DateTime localTime,
  });
```
```dart
  Future<DateTime> now();
```