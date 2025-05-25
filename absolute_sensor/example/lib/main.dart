import 'dart:async';

import 'package:absolute_sensor/absolute_sensor.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _text = 'Waiting…';
  late StreamSubscription<SensorData> _accelSub;

  @override
  void initState() {
    super.initState();
    AbsoluteSensor.isSensorAvailable(1).then((ok) {
      if (ok) {
        _accelSub = AbsoluteSensor.accelerometerEvents.listen((d) {
          setState(() {
            _text = 'x:${d.x.toStringAsFixed(1)}, '
                'y:${d.y.toStringAsFixed(1)}, '
                'z:${d.z.toStringAsFixed(1)}';
          });
        });
      } else {
        setState(() => _text = 'No accelerometer');
      }
    });
  }

  @override
  void dispose() {
    _accelSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('AbsoluteSensor Demo')),
        body: Center(child: Text(_text, style: const TextStyle(fontSize: 24))),
      ),
    );
  }
}
