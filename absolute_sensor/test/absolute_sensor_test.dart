import 'package:absolute_sensor/absolute_sensor.dart';
import 'package:absolute_sensor/absolute_sensor_method_channel.dart';
import 'package:absolute_sensor/absolute_sensor_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A mock platform implementation for testing.
class MockAbsoluteSensorPlatform with MockPlatformInterfaceMixin implements AbsoluteSensorPlatform {
  @override
  Future<bool> isSensorAvailable(int sensorType) async => sensorType == 1;

  @override
  Future<void> setSensorUpdateInterval(int sensorType, int intervalMicros) async {
    // no-op
  }

  @override
  Stream<SensorData> get accelerometerStream => Stream.value(SensorData(x: 1, y: 2, z: 3));

  @override
  Stream<SensorData> get userAccelerometerStream => Stream.value(SensorData(x: 4, y: 5, z: 6));

  @override
  Stream<SensorData> get gyroscopeStream => Stream.value(SensorData(x: 7, y: 8, z: 9));

  @override
  Stream<SensorData> get magnetometerStream => Stream.value(SensorData(x: 9, y: 8, z: 7));

  @override
  Stream<OrientationData> get orientationStream => Stream.value(OrientationData(roll: 0.1, yaw: 0.2, pitch: 0.3));

  @override
  Stream<OrientationData> get absoluteOrientationStream => Stream.value(OrientationData(roll: 0.4, yaw: 0.5, pitch: 0.6));

  @override
  Stream<double> get screenOrientationStream => Stream.value(90.0);
}

void main() {
  final AbsoluteSensorPlatform initialPlatform = AbsoluteSensorPlatform.instance;

  test('Default platform is MethodChannelAbsoluteSensor', () {
    expect(initialPlatform, isA<MethodChannelAbsoluteSensor>());
  });

  test('Can set and restore mock platform instance', () {
    final mock = MockAbsoluteSensorPlatform();
    AbsoluteSensorPlatform.instance = mock;
    expect(AbsoluteSensorPlatform.instance, mock);

    // And the high-level API uses the mock under the hood
    expect(
      AbsoluteSensor.isSensorAvailable(1),
      completion(isTrue),
    );
    expect(
      AbsoluteSensor.accelerometerEvents.first,
      completion(predicate<SensorData>(
        (d) => d.x == 1 && d.y == 2 && d.z == 3,
      )),
    );

    // Restore original
    AbsoluteSensorPlatform.instance = initialPlatform;
    expect(AbsoluteSensorPlatform.instance, initialPlatform);
  });

  test('Cannot set instance to a non-implementing class', () {
    // Using a bogus object should throw
    expect(
      () => AbsoluteSensorPlatform.instance = Object() as AbsoluteSensorPlatform,
      throwsA(isA<AssertionError>()),
    );
  });
}
