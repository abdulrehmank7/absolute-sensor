import 'dart:async';

import 'package:absolute_sensor/absolute_sensor.dart';
import 'package:flutter/services.dart';

import 'absolute_sensor_platform_interface.dart';

/// MethodChannel implementation of [AbsoluteSensorPlatform].
class MethodChannelAbsoluteSensor extends AbsoluteSensorPlatform {
  final MethodChannel _method = const MethodChannel('absolute_sensor/method');

  final EventChannel _accel = const EventChannel('absolute_sensor/accelerometer');
  final EventChannel _userAcc = const EventChannel('absolute_sensor/user_accelerometer');
  final EventChannel _gyro = const EventChannel('absolute_sensor/gyroscope');
  final EventChannel _mag = const EventChannel('absolute_sensor/magnetometer');
  final EventChannel _orient = const EventChannel('absolute_sensor/orientation');
  final EventChannel _absOrient = const EventChannel('absolute_sensor/absolute_orientation');
  final EventChannel _screenOrient = const EventChannel('absolute_sensor/screen_orientation');

  @override
  Future<bool> isSensorAvailable(int sensorType) async {
    return (await _method.invokeMethod<bool>(
          'isSensorAvailable',
          {'sensorType': sensorType},
        )) ??
        false;
  }

  @override
  Future<void> setSensorUpdateInterval(int sensorType, int intervalMicros) {
    return _method.invokeMethod<void>(
      'setSensorUpdateInterval',
      {'sensorType': sensorType, 'interval': intervalMicros},
    );
  }

  @override
  Stream<SensorData> get accelerometerStream => _accel.receiveBroadcastStream().cast<Map<dynamic, dynamic>>().map(SensorData.fromMap);

  @override
  Stream<SensorData> get userAccelerometerStream => _userAcc.receiveBroadcastStream().cast<Map<dynamic, dynamic>>().map(SensorData.fromMap);

  @override
  Stream<SensorData> get gyroscopeStream => _gyro.receiveBroadcastStream().cast<Map<dynamic, dynamic>>().map(SensorData.fromMap);

  @override
  Stream<SensorData> get magnetometerStream => _mag.receiveBroadcastStream().cast<Map<dynamic, dynamic>>().map(SensorData.fromMap);

  @override
  Stream<OrientationData> get orientationStream => _orient.receiveBroadcastStream().cast<Map<dynamic, dynamic>>().map(OrientationData.fromMap);

  @override
  Stream<OrientationData> get absoluteOrientationStream => _absOrient.receiveBroadcastStream().cast<Map<dynamic, dynamic>>().map(OrientationData.fromMap);

  @override
  Stream<double> get screenOrientationStream => _screenOrient.receiveBroadcastStream().cast<double>();
}
