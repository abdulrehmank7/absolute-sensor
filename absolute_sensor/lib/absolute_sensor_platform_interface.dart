import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'absolute_sensor.dart';
import 'absolute_sensor_method_channel.dart'; // brings in SensorData & OrientationData

/// Base interface for the AbsoluteSensor plugin.
abstract class AbsoluteSensorPlatform extends PlatformInterface {
  AbsoluteSensorPlatform() : super(token: _token);
  static final Object _token = Object();

  static AbsoluteSensorPlatform _instance = MethodChannelAbsoluteSensor();

  /// The current default instance.
  static AbsoluteSensorPlatform get instance => _instance;

  /// Platform implementations must set this to register themselves.
  static set instance(AbsoluteSensorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> isSensorAvailable(int sensorType);

  Future<void> setSensorUpdateInterval(int sensorType, int intervalMicros);

  Stream<SensorData> get accelerometerStream;

  Stream<SensorData> get userAccelerometerStream;

  Stream<SensorData> get gyroscopeStream;

  Stream<SensorData> get magnetometerStream;

  Stream<OrientationData> get orientationStream;

  Stream<OrientationData> get absoluteOrientationStream;

  Stream<double> get screenOrientationStream;
}
