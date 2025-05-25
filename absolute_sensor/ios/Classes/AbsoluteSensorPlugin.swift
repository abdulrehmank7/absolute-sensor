import Flutter
import UIKit
import CoreMotion

/**
 * AbsoluteSensorPlugin bridges CoreMotion sensors to Flutter with structured data.
 *
 * Provides RPCs for availability and update interval, and streams:
 *  - Accelerometer: { "x": Double, "y": Double, "z": Double }
 *  - User (linear) Accelerometer: same as above
 *  - Gyroscope: same as above
 *  - Magnetometer: same as above
 *  - Orientation: { "roll": Double, "yaw": Double, "pitch": Double }
 *  - Absolute Orientation: same as above (magnetic north reference)
 *  - Screen Orientation: Double (0, 90, 180, -90)
 */
public class AbsoluteSensorPlugin: NSObject, FlutterPlugin {
    private let motionManager = CMMotionManager()
    
    private var methodChannel: FlutterMethodChannel!
    private var accelerometerChannel: FlutterEventChannel!
    private var userAccelerometerChannel: FlutterEventChannel!
    private var gyroscopeChannel: FlutterEventChannel!
    private var magnetometerChannel: FlutterEventChannel!
    private var orientationChannel: FlutterEventChannel!
    private var absoluteOrientationChannel: FlutterEventChannel!
    private var screenOrientationChannel: FlutterEventChannel!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AbsoluteSensorPlugin()
        instance.setupChannels(registrar: registrar)
    }
    
    private func setupChannels(registrar: FlutterPluginRegistrar) {
        // Method channel for RPCs
        methodChannel = FlutterMethodChannel(
            name: "absolute_sensor/method",
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(self, channel: methodChannel)
        
        // Event channels for sensor streams
        accelerometerChannel = FlutterEventChannel(
            name: "absolute_sensor/accelerometer",
            binaryMessenger: registrar.messenger()
        )
        accelerometerChannel.setStreamHandler(
            AccelerometerHandler(motionManager: motionManager)
        )
        
        userAccelerometerChannel = FlutterEventChannel(
            name: "absolute_sensor/user_accelerometer",
            binaryMessenger: registrar.messenger()
        )
        userAccelerometerChannel.setStreamHandler(
            UserAccelerometerHandler(motionManager: motionManager)
        )
        
        gyroscopeChannel = FlutterEventChannel(
            name: "absolute_sensor/gyroscope",
            binaryMessenger: registrar.messenger()
        )
        gyroscopeChannel.setStreamHandler(
            GyroscopeHandler(motionManager: motionManager)
        )
        
        magnetometerChannel = FlutterEventChannel(
            name: "absolute_sensor/magnetometer",
            binaryMessenger: registrar.messenger()
        )
        magnetometerChannel.setStreamHandler(
            MagnetometerHandler(motionManager: motionManager)
        )
        
        orientationChannel = FlutterEventChannel(
            name: "absolute_sensor/orientation",
            binaryMessenger: registrar.messenger()
        )
        orientationChannel.setStreamHandler(
            AttitudeHandler(
                motionManager: motionManager,
                referenceFrame: .xArbitraryCorrectedZVertical
            )
        )
        
        absoluteOrientationChannel = FlutterEventChannel(
            name: "absolute_sensor/absolute_orientation",
            binaryMessenger: registrar.messenger()
        )
        absoluteOrientationChannel.setStreamHandler(
            AttitudeHandler(
                motionManager: motionManager,
                referenceFrame: .xMagneticNorthZVertical
            )
        )
        
        screenOrientationChannel = FlutterEventChannel(
            name: "absolute_sensor/screen_orientation",
            binaryMessenger: registrar.messenger()
        )
        screenOrientationChannel.setStreamHandler(
            ScreenOrientationHandler()
        )
    }
    
    // MARK: - RPC handlers
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isSensorAvailable":
            guard let type = call.arguments as? Int else {
                result(FlutterError(code: "BAD_ARGUMENT", message: "sensorType missing", details: nil))
                return
            }
            result(isSensorAvailable(type))
            
        case "setSensorUpdateInterval":
            guard
                let args = call.arguments as? [String: Any],
                let type = args["sensorType"] as? Int,
                let micros = args["interval"] as? Int
            else {
                result(FlutterError(code: "BAD_ARGUMENT", message: "sensorType/interval missing", details: nil))
                return
            }
            setSensorUpdateInterval(type, micros)
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func isSensorAvailable(_ type: Int) -> Bool {
        switch type {
        case 1:   return motionManager.isAccelerometerAvailable
        case 10:  return motionManager.isDeviceMotionAvailable
        case 4:   return motionManager.isGyroAvailable
        case 2:   return motionManager.isDeviceMotionAvailable
        case 11, 15:
            return motionManager.isDeviceMotionAvailable
        default:  return false
        }
    }
    
    private func setSensorUpdateInterval(_ type: Int, _ micros: Int) {
        let secs = TimeInterval(Double(micros) / 1_000_000.0)
        switch type {
        case 1:   motionManager.accelerometerUpdateInterval = secs
        case 10:  motionManager.deviceMotionUpdateInterval = secs
        case 4:   motionManager.gyroUpdateInterval = secs
        case 2:   motionManager.deviceMotionUpdateInterval = secs
        case 11, 15:
            motionManager.deviceMotionUpdateInterval = secs
        default:  break
        }
    }
}


/// Streams raw accelerometer {x, y, z} values.
private class AccelerometerHandler: NSObject, FlutterStreamHandler {
    let motionManager: CMMotionManager
    
    init(motionManager: CMMotionManager) { self.motionManager = motionManager }
    
    func onListen(withArguments _: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        guard motionManager.isAccelerometerAvailable else { return nil }
        motionManager.startAccelerometerUpdates(to: .main) { data, _ in
            if let a = data?.acceleration {
                eventSink(["x": a.x, "y": a.y, "z": a.z])
            }
        }
        return nil
    }
    
    func onCancel(withArguments _: Any?) -> FlutterError? {
        motionManager.stopAccelerometerUpdates()
        return nil
    }
}

/// Streams raw user-accelerometer (linear acceleration) {x, y, z} values.
private class UserAccelerometerHandler: NSObject, FlutterStreamHandler {
    let motionManager: CMMotionManager
    
    init(motionManager: CMMotionManager) { self.motionManager = motionManager }
    
    func onListen(withArguments _: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        guard motionManager.isDeviceMotionAvailable else { return nil }
        motionManager.startDeviceMotionUpdates(to: .main) { data, _ in
            if let u = data?.userAcceleration {
                eventSink(["x": u.x, "y": u.y, "z": u.z])
            }
        }
        return nil
    }
    
    func onCancel(withArguments _: Any?) -> FlutterError? {
        motionManager.stopDeviceMotionUpdates()
        return nil
    }
}

/// Streams raw gyroscope {x, y, z} rotationRate values.
private class GyroscopeHandler: NSObject, FlutterStreamHandler {
    let motionManager: CMMotionManager
    
    init(motionManager: CMMotionManager) { self.motionManager = motionManager }
    
    func onListen(withArguments _: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        guard motionManager.isGyroAvailable else { return nil }
        motionManager.startGyroUpdates(to: .main) { data, _ in
            if let r = data?.rotationRate {
                eventSink(["x": r.x, "y": r.y, "z": r.z])
            }
        }
        return nil
    }
    
    func onCancel(withArguments _: Any?) -> FlutterError? {
        motionManager.stopGyroUpdates()
        return nil
    }
}

/// Streams raw magnetometer {x, y, z} magneticField values.
private class MagnetometerHandler: NSObject, FlutterStreamHandler {
    let motionManager: CMMotionManager
    
    init(motionManager: CMMotionManager) { self.motionManager = motionManager }
    
    func onListen(withArguments _: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        guard motionManager.isDeviceMotionAvailable else { return nil }
        motionManager.startDeviceMotionUpdates(
            using: .xArbitraryCorrectedZVertical,
            to: .main
        ) { data, _ in
            if let m = data?.magneticField.field {
                eventSink(["x": m.x, "y": m.y, "z": m.z])
            }
        }
        return nil
    }
    
    func onCancel(withArguments _: Any?) -> FlutterError? {
        motionManager.stopDeviceMotionUpdates()
        return nil
    }
}

/// Streams orientation {roll, yaw, pitch} in radians.
private class AttitudeHandler: NSObject, FlutterStreamHandler {
    let motionManager: CMMotionManager
    let referenceFrame: CMAttitudeReferenceFrame
    
    init(
        motionManager: CMMotionManager,
        referenceFrame: CMAttitudeReferenceFrame
    ) {
        self.motionManager = motionManager
        self.referenceFrame = referenceFrame
    }
    
    func onListen(withArguments _: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        guard motionManager.isDeviceMotionAvailable else { return nil }
        motionManager.startDeviceMotionUpdates(
            using: referenceFrame,
            to: .main
        ) { data, _ in
            guard let att = data?.attitude else { return }
            var yaw = att.yaw
            if self.referenceFrame == .xMagneticNorthZVertical {
                yaw = fmod(yaw + .pi + .pi/2, .pi * 2) - .pi
            }
            let roll  = att.roll
            let pitch = att.pitch
            eventSink(["roll": roll, "yaw": yaw, "pitch": pitch])
        }
        return nil
    }
    
    func onCancel(withArguments _: Any?) -> FlutterError? {
        motionManager.stopDeviceMotionUpdates()
        return nil
    }
}

/// Streams screen-rotation angles (0°, 90°, 180°, -90°).
private class ScreenOrientationHandler: NSObject, FlutterStreamHandler {
    private var sink: FlutterEventSink?
    
    func onListen(withArguments _: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        sink = eventSink
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        orientationChanged()
        return nil
    }
    
    func onCancel(withArguments _: Any?) -> FlutterError? {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self)
        sink = nil
        return nil
    }
    
    @objc private func orientationChanged() {
        guard let sink = sink else { return }
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:           sink(0.0)
        case .portraitUpsideDown: sink(180.0)
        case .landscapeLeft:      sink(-90.0)
        case .landscapeRight:     sink(90.0)
        default:                  sink(0.0)
        }
    }
}
