# ntp

Get local clock offset in milliseconds from NTP services

Add offset from getNtpTime

example:

```dart
  NTP ntp = new NTP();
  
  DateTime startDate = new DateTime().now().toLocal();
  
  int offset = await ntp.getNtpTime(localTime: startDate);
  
  print('NTP Align: ${startDate.add(new Duration(milliseconds: offset))}');
```