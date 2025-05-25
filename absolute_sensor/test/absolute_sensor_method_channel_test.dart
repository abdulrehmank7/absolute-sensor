import 'package:absolute_sensor/absolute_sensor_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel rpcChannel = MethodChannel('absolute_sensor/method');
  const EventChannel accelChannel = EventChannel('absolute_sensor/accelerometer');
  const EventChannel orientChannel = EventChannel('absolute_sensor/orientation');

  final MethodChannelAbsoluteSensor platform = MethodChannelAbsoluteSensor();
  final StandardMethodCodec codec = StandardMethodCodec();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(rpcChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(accelChannel.name, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(orientChannel.name, null);
  });

  test('isSensorAvailable returns true for type 1, false otherwise', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(rpcChannel, (MethodCall call) async {
      if (call.method == 'isSensorAvailable') {
        final int type = (call.arguments as Map)['sensorType'] as int;
        return type == 1;
      }
      return null;
    });

    expect(await platform.isSensorAvailable(1), isTrue);
    expect(await platform.isSensorAvailable(2), isFalse);
  });

  test('setSensorUpdateInterval completes without error', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(rpcChannel, (MethodCall call) async {
      if (call.method == 'setSensorUpdateInterval') {
        // validate arguments
        final args = call.arguments as Map;
        expect(args['sensorType'], 1);
        expect(args['interval'], 123456);
        return null;
      }
      return null;
    });

    await platform.setSensorUpdateInterval(1, 123456);
  });

  test('accelerometerStream emits SensorData from map payload', () async {
    // Setup a single event of {"x":1.0,"y":2.0,"z":3.0}
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(accelChannel.name, (ByteData? message) async {
      final MethodCall call = codec.decodeMethodCall(message);
      if (call.method == 'listen') {
        return codec.encodeSuccessEnvelope(
          <String, double>{'x': 1.0, 'y': 2.0, 'z': 3.0},
        );
      } else if (call.method == 'cancel') {
        return null;
      }
      return null;
    });

    final data = await platform.accelerometerStream.first;
    expect(data.x, 1.0);
    expect(data.y, 2.0);
    expect(data.z, 3.0);
  });

  test('orientationStream emits OrientationData from map payload', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(orientChannel.name, (ByteData? message) async {
      final MethodCall call = codec.decodeMethodCall(message);
      if (call.method == 'listen') {
        return codec.encodeSuccessEnvelope(
          <String, double>{'roll': 0.1, 'yaw': 0.2, 'pitch': 0.3},
        );
      } else if (call.method == 'cancel') {
        return null;
      }
      return null;
    });

    final od = await platform.orientationStream.first;
    expect(od.roll, closeTo(0.1, 1e-9));
    expect(od.yaw, closeTo(0.2, 1e-9));
    expect(od.pitch, closeTo(0.3, 1e-9));
  });
}
