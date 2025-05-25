import 'dart:async';

import 'absolute_sensor_platform_interface.dart';

/// Represents 3-axis sensor data: [x], [y], [z].
class SensorData {
  final double x;
  final double y;
  final double z;

  SensorData({required this.x, required this.y, required this.z});

  factory SensorData.fromMap(Map<dynamic, dynamic> map) => SensorData(
        x: map['x'] as double,
        y: map['y'] as double,
        z: map['z'] as double,
      );

  @override
  String toString() => 'SensorData(x: $x, y: $y, z: $z)';
}

/// Represents device orientation angles in radians.
class OrientationData {
  /// Rotation about the device’s X-axis.
  final double roll;

  /// Rotation about the device’s Y-axis.
  final double yaw;

  /// Rotation about the device’s Z-axis.
  final double pitch;

  OrientationData({required this.roll, required this.yaw, required this.pitch});

  factory OrientationData.fromMap(Map<dynamic, dynamic> map) => OrientationData(
        roll: map['roll'] as double,
        yaw: map['yaw'] as double,
        pitch: map['pitch'] as double,
      );

  @override
  String toString() => 'OrientationData(roll: $roll, yaw: $yaw, pitch: $pitch)';
}

/// High-level API for accessing device motion sensors.
class AbsoluteSensor {
  /// Returns true if [sensorType] is available.
  static Future<bool> isSensorAvailable(int sensorType) => AbsoluteSensorPlatform.instance.isSensorAvailable(sensorType);

  /// Sets the update interval (microseconds) for [sensorType].
  static Future<void> setSensorUpdateInterval(int sensorType, int intervalMicros) => AbsoluteSensorPlatform.instance.setSensorUpdateInterval(sensorType, intervalMicros);

  /// Stream of accelerometer [SensorData].
  static Stream<SensorData> get accelerometerEvents => AbsoluteSensorPlatform.instance.accelerometerStream;

  /// Stream of user accelerometer [SensorData].
  static Stream<SensorData> get userAccelerometerEvents => AbsoluteSensorPlatform.instance.userAccelerometerStream;

  /// Stream of gyroscope [SensorData].
  static Stream<SensorData> get gyroscopeEvents => AbsoluteSensorPlatform.instance.gyroscopeStream;

  /// Stream of magnetometer [SensorData].
  static Stream<SensorData> get magnetometerEvents => AbsoluteSensorPlatform.instance.magnetometerStream;

  /// Stream of device orientation [OrientationData].
  static Stream<OrientationData> get orientationEvents => AbsoluteSensorPlatform.instance.orientationStream;

  /// Stream of magnetic-north orientation [OrientationData].
  static Stream<OrientationData> get absoluteOrientationEvents => AbsoluteSensorPlatform.instance.absoluteOrientationStream;

  /// Stream of screen rotation angles (0, 90, 180, –90).
  static Stream<double> get screenOrientationEvents => AbsoluteSensorPlatform.instance.screenOrientationStream;
}
