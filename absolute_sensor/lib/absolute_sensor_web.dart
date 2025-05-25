// ignore_for_file: unnecessary_null_comparison
import 'dart:async';
import 'dart:html' as html;

import 'package:absolute_sensor/absolute_sensor.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'absolute_sensor_platform_interface.dart';

/// Web implementation of [AbsoluteSensorPlatform].
class AbsoluteSensorWeb extends AbsoluteSensorPlatform {
  /// Registers this implementation.
  static void registerWith(Registrar registrar) {
    AbsoluteSensorPlatform.instance = AbsoluteSensorWeb();
  }

  final double _deg2rad = 3.1415926535897932 / 180.0;

  StreamController<SensorData>? _accelCtrl;
  StreamController<SensorData>? _gyroCtrl;
  StreamController<SensorData>? _magCtrl;
  StreamController<OrientationData>? _orientCtrl;
  StreamController<OrientationData>? _absOrientCtrl;
  StreamController<double>? _screenOrientCtrl;

  AbsoluteSensorWeb() {
    _initDeviceMotion();
    _initDeviceOrientation();
    _initScreenOrientation();
  }

  @override
  Future<bool> isSensorAvailable(int sensorType) async {
    if (sensorType == 1 || sensorType == 10) {
      return html.window.onDeviceMotion != null;
    }
    if (sensorType == 4) {
      return html.window.onDeviceMotion != null;
    }
    if (sensorType == 11 || sensorType == 15) {
      return html.window.onDeviceOrientation != null;
    }
    return false;
  }

  @override
  Future<void> setSensorUpdateInterval(int sensorType, int intervalMicros) async {
    // no-op on web
  }

  @override
  Stream<SensorData> get accelerometerStream {
    _accelCtrl ??= StreamController<SensorData>.broadcast();
    return _accelCtrl!.stream;
  }

  @override
  Stream<SensorData> get userAccelerometerStream => accelerometerStream;

  @override
  Stream<SensorData> get gyroscopeStream {
    _gyroCtrl ??= StreamController<SensorData>.broadcast();
    return _gyroCtrl!.stream;
  }

  @override
  Stream<SensorData> get magnetometerStream {
    _magCtrl ??= StreamController<SensorData>.broadcast();
    return _magCtrl!.stream;
  }

  @override
  Stream<OrientationData> get orientationStream {
    _orientCtrl ??= StreamController<OrientationData>.broadcast();
    return _orientCtrl!.stream;
  }

  @override
  Stream<OrientationData> get absoluteOrientationStream {
    _absOrientCtrl ??= StreamController<OrientationData>.broadcast();
    return _absOrientCtrl!.stream;
  }

  @override
  Stream<double> get screenOrientationStream {
    _screenOrientCtrl ??= StreamController<double>.broadcast();
    return _screenOrientCtrl!.stream;
  }

  void _initDeviceMotion() {
    html.window.onDeviceMotion.listen((event) {
      final a = event.acceleration;
      if (a != null) {
        _accelCtrl?.add(SensorData(x: a.x?.toDouble() ?? 0, y: a.y?.toDouble() ?? 0, z: a.z?.toDouble() ?? 0));
      }
    });
    html.window.onDeviceMotion.listen((event) {
      final r = event.rotationRate;
      if (r != null) {
        _gyroCtrl?.add(SensorData(x: r.alpha?.toDouble() ?? 0, y: r.beta?.toDouble() ?? 0, z: r.gamma?.toDouble() ?? 0));
      }
    });
  }

  void _initDeviceOrientation() {
    html.window.onDeviceOrientation.listen((event) {
      final roll = (event.beta ?? 0) * _deg2rad;
      final yaw = (event.gamma ?? 0) * _deg2rad;
      final pitch = (event.alpha ?? 0) * _deg2rad;
      final data = OrientationData(roll: roll, yaw: yaw, pitch: pitch);
      _orientCtrl?.add(data);
      _absOrientCtrl?.add(data);
    });
  }

  void _initScreenOrientation() {
    html.window.screen?.orientation?.onChange.listen((_) {
      final angle = html.window.screen?.orientation?.angle ?? 0;
      _screenOrientCtrl?.add(angle.toDouble());
    });
  }
}
