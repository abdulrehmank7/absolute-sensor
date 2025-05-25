<h1 data-start="0" data-end="32">Absolute Sensor Flutter Plugin</h1>
<p data-start="34" data-end="176"><strong data-start="34" data-end="53">Absolute Sensor</strong> provides unified access to device motion and orientation sensors on Android, iOS, and Web with strongly-typed data models.</p>

<h2 data-start="384" data-end="395">Features</h2>
<ul data-start="397" data-end="1356">
<li data-start="397" data-end="556">
<p data-start="399" data-end="416"><strong data-start="399" data-end="414">RPC Methods</strong></p>
<ul data-start="419" data-end="556">
<li data-start="419" data-end="473">
<p data-start="421" data-end="473"><code data-start="421" data-end="471">isSensorAvailable(int sensorType) → Future&lt;bool&gt;</code></p>
</li>
<li data-start="476" data-end="556">
<p data-start="478" data-end="556"><code data-start="478" data-end="554">setSensorUpdateInterval(int sensorType, int intervalMicros) → Future&lt;void&gt;</code></p>
</li>
</ul>
</li>
<li data-start="558" data-end="1046">
<p data-start="560" data-end="573"><strong data-start="560" data-end="571">Streams</strong></p>
<ul data-start="576" data-end="1046">
<li data-start="576" data-end="620">
<p data-start="578" data-end="620"><strong data-start="578" data-end="595">Accelerometer</strong> → <code data-start="598" data-end="618">Stream&lt;SensorData&gt;</code></p>
</li>
<li data-start="623" data-end="694">
<p data-start="625" data-end="694"><strong data-start="625" data-end="669">User Accelerometer (Linear Acceleration)</strong> → <code data-start="672" data-end="692">Stream&lt;SensorData&gt;</code></p>
</li>
<li data-start="697" data-end="737">
<p data-start="699" data-end="737"><strong data-start="699" data-end="712">Gyroscope</strong> → <code data-start="715" data-end="735">Stream&lt;SensorData&gt;</code></p>
</li>
<li data-start="740" data-end="783">
<p data-start="742" data-end="783"><strong data-start="742" data-end="758">Magnetometer</strong> → <code data-start="761" data-end="781">Stream&lt;SensorData&gt;</code></p>
</li>
<li data-start="786" data-end="871">
<p data-start="788" data-end="871"><strong data-start="788" data-end="803">Orientation</strong> → <code data-start="806" data-end="831">Stream&lt;OrientationData&gt;</code> (roll, yaw, pitch relative to device)</p>
</li>
<li data-start="874" data-end="976">
<p data-start="876" data-end="976"><strong data-start="876" data-end="900">Absolute Orientation</strong> → <code data-start="903" data-end="928">Stream&lt;OrientationData&gt;</code> (roll, yaw, pitch relative to magnetic north)</p>
</li>
<li data-start="979" data-end="1046">
<p data-start="981" data-end="1046"><strong data-start="981" data-end="1003">Screen Orientation</strong> → <code data-start="1006" data-end="1022">Stream&lt;double&gt;</code> (0°, 90°, 180°, –90°)</p>
</li>
</ul>
</li>
<li data-start="1048" data-end="1356">
<p data-start="1050" data-end="1067"><strong data-start="1050" data-end="1065">Data Models</strong></p>

```dart
class SensorData {
  final double x, y, z;
  SensorData({ required this.x, required this.y, required this.z });
}

class OrientationData {
  final double roll, yaw, pitch;
  OrientationData({ required this.roll, required this.yaw, required this.pitch });
}
``` 

</li>
</ul>
<hr data-start="1358" data-end="1361">
<h2 data-start="1363" data-end="1378">Installation</h2>
<ol data-start="1380" data-end="1966">
<li data-start="1380" data-end="1508">
<p data-start="1383" data-end="1410"><strong data-start="1383" data-end="1408">Add to <code data-start="1392" data-end="1406">pubspec.yaml</code></strong></p>


```yaml

dependencies:
  absolute_sensor: ^0.0.1

```

  

<li data-start="1906" data-end="1966">
<p data-start="1909" data-end="1933"><strong data-start="1909" data-end="1931">Fetch dependencies</strong></p>

```shell

flutter pub get

```
  
</li>
</ol>
<hr data-start="1968" data-end="1971">
<h2 data-start="1973" data-end="1981">Usage</h2>
<h3 data-start="1983" data-end="1993">Import</h3>


  ```dart
'package:absolute_sensor/absolute_sensor.dart';

```

<h3 data-start="2063" data-end="2092">Check Sensor Availability</h3>

```dart
const TYPE_ACCELEROMETER        = 1;
const TYPE_MAGNETIC_FIELD       = 2;
const TYPE_GYROSCOPE            = 4;
const TYPE_USER_ACCELEROMETER   = 10;
const TYPE_ORIENTATION          = 11;
const TYPE_ABSOLUTE_ORIENTATION = 15;

bool hasAccel = await AbsoluteSensor.isSensorAvailable(TYPE_ACCELEROMETER);

```

<h3 data-start="2458" data-end="2481">Set Update Interval</h3>

```dart
// interval in microseconds (e.g. 16000 ≈ 60 Hz)
await AbsoluteSensor.setSensorUpdateInterval(TYPE_ACCELEROMETER, 16000);

```

<h3 data-start="2618" data-end="2646">Listen to Sensor Streams</h3>

```dart
// Accelerometer
final subAccel = AbsoluteSensor.accelerometerEvents.listen((SensorData d) {
  print('Accel → x:${d.x}, y:${d.y}, z:${d.z}');
});

// Orientation
final subOrient = AbsoluteSensor.orientationEvents.listen((OrientationData o) {
  print('Orientation → roll:${o.roll}, yaw:${o.yaw}, pitch:${o.pitch}');
});

// Screen rotation
final subScreen = AbsoluteSensor.screenOrientationEvents.listen((angle) {
  print('Screen rotated to $angle°');
});
```


<p data-start="3116" data-end="3173">Remember to <strong data-start="3128" data-end="3138">cancel</strong> your subscriptions in <code data-start="3161" data-end="3172">dispose()</code>:</p>


```dart
subAccel.cancel();
subOrient.cancel();
subScreen.cancel();
```


<hr data-start="3246" data-end="3249">
<h2 data-start="3251" data-end="3268">Platform Notes</h2>
<h3 data-start="3270" data-end="3287">Android &amp; iOS</h3>
<ul data-start="3288" data-end="3450">
<li data-start="3288" data-end="3319">
<p data-start="3290" data-end="3319">No additional setup required.</p>
</li>
<li data-start="3320" data-end="3374">
<p data-start="3322" data-end="3374">iOS: CoreMotion APIs require no special permissions.</p>
</li>
<li data-start="3375" data-end="3450">
<p data-start="3377" data-end="3450">Android: Sensors are available on most devices; check availability first.</p>
</li>
</ul>
<h3 data-start="3452" data-end="3459">Web</h3>
<ul data-start="3460" data-end="3751">
<li data-start="3460" data-end="3501">
<p data-start="3462" data-end="3501">Uses <code data-start="3467" data-end="3480">package:web</code> + <code data-start="3483" data-end="3500">dart:js_interop</code>.</p>
</li>
<li data-start="3502" data-end="3526">
<p data-start="3504" data-end="3526">No <code data-start="3507" data-end="3518">dart:html</code> import.</p>
</li>
<li data-start="3527" data-end="3696">
<p data-start="3529" data-end="3555">Listens to browser events:</p>
<ul data-start="3558" data-end="3696">
<li data-start="3558" data-end="3604">
<p data-start="3560" data-end="3604"><code data-start="3560" data-end="3574">devicemotion</code> for accelerometer &amp; gyroscope</p>
</li>
<li data-start="3607" data-end="3644">
<p data-start="3609" data-end="3644"><code data-start="3609" data-end="3628">deviceorientation</code> for orientation</p>
</li>
<li data-start="3647" data-end="3696">
<p data-start="3649" data-end="3696"><code data-start="3649" data-end="3676">screen.orientation.change</code> for screen rotation</p>
</li>
</ul>
</li>
<li data-start="3697" data-end="3751">
<p data-start="3699" data-end="3751">Requires HTTPS or localhost for real device sensors.</p>
</li>
</ul>
<hr data-start="3753" data-end="3756">
<h2 data-start="3758" data-end="3768">Example</h2>

```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() =&gt; _MyAppState();
}
class _MyAppState extends State&lt;MyApp&gt; {
  String _text = 'Waiting…';
  late StreamSubscription&lt;SensorData&gt; _accelSub;

  @override
  void initState() {
    super.initState();
    AbsoluteSensor.isSensorAvailable(TYPE_ACCELEROMETER).then((ok) {
      if (ok) {
        _accelSub = AbsoluteSensor.accelerometerEvents.listen((d) {
          setState(() {
            _text = 'x:${d.x.toStringAsFixed(1)}, '
                  'y:${d.y.toStringAsFixed(1)}, '
                  'z:${d.z.toStringAsFixed(1)}';
          });
        });
      } else {
        setState(() =&gt; _text = 'No accelerometer');
      }
    });
  }

  @override
  void dispose() {
    _accelSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) =&gt; MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('AbsoluteSensor Demo')),
      body: Center(child: Text(_text, style: TextStyle(fontSize: 24))),
    ),
  );
}
```


Feel free to adapt and contribute via pull requests!</p>
