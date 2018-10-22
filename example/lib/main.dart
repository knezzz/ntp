import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DateTime _currentTime;
  DateTime _ntpTime;
  int _ntpOffset;

  @override
  void initState() {
    super.initState();

    _updateTime();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Example of NTP library'),
        ),
        body: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _showData('Current time:', '$_currentTime'),
              _showData('NTP offset:', '$_ntpOffset ms'),
              _showData('NTP time:', '$_ntpTime'),
            ],
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          tooltip: 'Update time',
          child: const Icon(Icons.timer),
          onPressed: _updateTime,
        ),
      ),
    );
  }

  Widget _showData(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text(title,
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(fontWeight: FontWeight.w500, fontSize: 16.0)),
          new Text(value,
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(fontWeight: FontWeight.w300, fontSize: 16.0)),
        ],
      ),
    );
  }

  void _updateTime() async {
    _currentTime = DateTime.now();

    NTP.getNtpOffset().then((int value) {
      setState(() {
        _ntpOffset = value;
        _ntpTime = _currentTime.add(Duration(milliseconds: _ntpOffset));
      });
    });
  }
}
