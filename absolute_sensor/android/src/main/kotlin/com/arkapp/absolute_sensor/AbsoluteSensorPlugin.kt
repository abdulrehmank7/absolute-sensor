package com.arkapp.absolute_sensor

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.view.Surface
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/**
 * Bridges Android sensors to Flutter with structured data maps.
 */
class AbsoluteSensorPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var sensorManager: SensorManager
    private var methodChannel: MethodChannel? = null
    private var accChannel: EventChannel? = null
    private var userAccChannel: EventChannel? = null
    private var gyroChannel: EventChannel? = null
    private var magChannel: EventChannel? = null
    private var orientChannel: EventChannel? = null
    private var absOrientChannel: EventChannel? = null
    private var screenOrientChannel: EventChannel? = null

    private var accHandler: StreamHandlerImpl? = null
    private var userAccHandler: StreamHandlerImpl? = null
    private var gyroHandler: StreamHandlerImpl? = null
    private var magHandler: StreamHandlerImpl? = null
    private var orientHandler: RotationVectorStreamHandler? = null
    private var absOrientHandler: RotationVectorStreamHandler? = null
    private var screenOrientHandler: ScreenOrientationStreamHandler? = null

    companion object {
        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val instance = AbsoluteSensorPlugin()
            instance.setupChannels(registrar.context(), registrar.messenger())
        }
    }

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        setupChannels(binding.applicationContext, binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        teardownChannels()
    }

    private fun setupChannels(context: Context, messenger: BinaryMessenger) {
        sensorManager =
            context.getSystemService(Context.SENSOR_SERVICE) as SensorManager

        methodChannel = MethodChannel(messenger, "absolute_sensor/method")
        methodChannel!!.setMethodCallHandler(this)

        accChannel = EventChannel(messenger, "absolute_sensor/accelerometer")
        accHandler = StreamHandlerImpl(sensorManager, Sensor.TYPE_ACCELEROMETER)
        accChannel!!.setStreamHandler(accHandler)

        userAccChannel = EventChannel(messenger, "absolute_sensor/user_accelerometer")
        userAccHandler = StreamHandlerImpl(sensorManager, Sensor.TYPE_LINEAR_ACCELERATION)
        userAccChannel!!.setStreamHandler(userAccHandler)

        gyroChannel = EventChannel(messenger, "absolute_sensor/gyroscope")
        gyroHandler = StreamHandlerImpl(sensorManager, Sensor.TYPE_GYROSCOPE)
        gyroChannel!!.setStreamHandler(gyroHandler)

        magChannel = EventChannel(messenger, "absolute_sensor/magnetometer")
        magHandler = StreamHandlerImpl(sensorManager, Sensor.TYPE_MAGNETIC_FIELD)
        magChannel!!.setStreamHandler(magHandler)

        orientChannel = EventChannel(messenger, "absolute_sensor/orientation")
        orientHandler = RotationVectorStreamHandler(sensorManager, Sensor.TYPE_GAME_ROTATION_VECTOR)
        orientChannel!!.setStreamHandler(orientHandler)

        absOrientChannel = EventChannel(messenger, "absolute_sensor/absolute_orientation")
        absOrientHandler = RotationVectorStreamHandler(sensorManager, Sensor.TYPE_ROTATION_VECTOR)
        absOrientChannel!!.setStreamHandler(absOrientHandler)

        screenOrientChannel = EventChannel(messenger, "absolute_sensor/screen_orientation")
        screenOrientHandler = ScreenOrientationStreamHandler(context, sensorManager)
        screenOrientChannel!!.setStreamHandler(screenOrientHandler)
    }

    private fun teardownChannels() {
        methodChannel?.setMethodCallHandler(null)
        accChannel?.setStreamHandler(null)
        userAccChannel?.setStreamHandler(null)
        gyroChannel?.setStreamHandler(null)
        magChannel?.setStreamHandler(null)
        orientChannel?.setStreamHandler(null)
        absOrientChannel?.setStreamHandler(null)
        screenOrientChannel?.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isSensorAvailable" -> {
                val type = call.argument<Int>("sensorType") ?: -1
                result.success(sensorManager.getDefaultSensor(type) != null)
            }

            "setSensorUpdateInterval" -> {
                val type = call.argument<Int>("sensorType")!!
                val interval = call.argument<Int>("interval")!!
                when (type) {
                    Sensor.TYPE_ACCELEROMETER -> accHandler?.setUpdateInterval(interval)
                    Sensor.TYPE_LINEAR_ACCELERATION -> userAccHandler?.setUpdateInterval(interval)
                    Sensor.TYPE_GYROSCOPE -> gyroHandler?.setUpdateInterval(interval)
                    Sensor.TYPE_MAGNETIC_FIELD -> magHandler?.setUpdateInterval(interval)
                    Sensor.TYPE_GAME_ROTATION_VECTOR -> orientHandler?.setUpdateInterval(interval)
                    Sensor.TYPE_ROTATION_VECTOR -> absOrientHandler?.setUpdateInterval(interval)
                }
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }
}

class StreamHandlerImpl(
    private val sensorManager: SensorManager,
    sensorType: Int,
    private var interval: Int = SensorManager.SENSOR_DELAY_NORMAL
) : EventChannel.StreamHandler, SensorEventListener {
    private val sensor = sensorManager.getDefaultSensor(sensorType)
    private var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        sensor?.also { sensorManager.registerListener(this, it, interval) }
    }

    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(this)
        sink = null
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onSensorChanged(event: SensorEvent) {
        sink?.success(
            mapOf(
                "x" to event.values[0],
                "y" to event.values[1],
                "z" to event.values[2],
            )
        )
    }

    fun setUpdateInterval(newInterval: Int) {
        interval = newInterval
        sink?.let {
            sensorManager.unregisterListener(this)
            sensorManager.registerListener(this, sensor, interval)
        }
    }
}

class RotationVectorStreamHandler(
    private val sensorManager: SensorManager,
    sensorType: Int,
    private var interval: Int = SensorManager.SENSOR_DELAY_NORMAL
) : EventChannel.StreamHandler, SensorEventListener {
    private val sensor = sensorManager.getDefaultSensor(sensorType)
    private var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        sensor?.also { sensorManager.registerListener(this, it, interval) }
    }

    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(this)
        sink = null
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onSensorChanged(event: SensorEvent) {
        val matrix = FloatArray(9)
        SensorManager.getRotationMatrixFromVector(matrix, event.values)
        matrix[7] = matrix[7].coerceIn(-1f, 1f)
        val orientation = FloatArray(3)
        SensorManager.getOrientation(matrix, orientation)
        val yaw = -orientation[0]
        val pitch = -orientation[1]
        val roll = orientation[2]
        sink?.success(mapOf("roll" to roll, "yaw" to yaw, "pitch" to pitch))
    }

    fun setUpdateInterval(newInterval: Int) {
        interval = newInterval
        sink?.let {
            sensorManager.unregisterListener(this)
            sensorManager.registerListener(this, sensor, interval)
        }
    }
}

class ScreenOrientationStreamHandler(
    private val context: Context,
    private  val sensorManager: SensorManager,
    private var interval: Int = SensorManager.SENSOR_DELAY_NORMAL
) : EventChannel.StreamHandler, SensorEventListener {
    private val sensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
    private var sink: EventChannel.EventSink? = null
    private var lastRotation: Int? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        sensor?.also { sensorManager.registerListener(this, it, interval) }
    }

    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(this)
        sink = null
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onSensorChanged(event: SensorEvent) {
        val rotation = (context.getSystemService(Context.WINDOW_SERVICE) as WindowManager)
            .defaultDisplay.rotation
        val degrees = when (rotation) {
            Surface.ROTATION_0 -> 0.0
            Surface.ROTATION_90 -> 90.0
            Surface.ROTATION_180 -> 180.0
            Surface.ROTATION_270 -> -90.0
            else -> 0.0
        }
        if (lastRotation != rotation) {
            sink?.success(degrees)
            lastRotation = rotation
        }
    }
}
