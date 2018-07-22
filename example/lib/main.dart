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
        body: new Column(
          children: <Widget>[
            new Text('Current Time: $_currentTime'),
            new Text('Ntp time: $_ntpTime'),
          ],
        ),
        floatingActionButton: new FloatingActionButton(
          tooltip: 'Update time',
          child: const Icon(Icons.timer),
          onPressed: _updateTime,
        ),
      ),
    );
  }

  void _updateTime() async {
    _currentTime = DateTime.now();
    _ntpTime = await NTP.now();
  }
}