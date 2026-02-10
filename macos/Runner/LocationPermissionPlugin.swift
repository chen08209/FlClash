import Cocoa
import FlutterMacOS
import CoreLocation

class LocationPermissionPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var pendingResult: FlutterResult?

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.flclash/location_permission",
            binaryMessenger: registrar.messenger
        )
        let instance = LocationPermissionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestLocationPermission":
            requestLocationPermission(result: result)
        case "checkLocationPermission":
            checkLocationPermission(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func requestLocationPermission(result: @escaping FlutterResult) {
        let status: CLAuthorizationStatus
        if #available(macOS 11.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }

        switch status {
        case .authorizedAlways:
            result("granted")
        case .denied:
            result("denied")
        case .restricted:
            result("restricted")
        case .notDetermined:
            // Store result to respond after authorization callback
            pendingResult = result
            if #available(macOS 10.15, *) {
                locationManager.requestWhenInUseAuthorization()
            } else {
                // On older macOS, just start updating which triggers the prompt
                locationManager.startUpdatingLocation()
                locationManager.stopUpdatingLocation()
            }
        @unknown default:
            result("unknown")
        }
    }

    private func checkLocationPermission(result: @escaping FlutterResult) {
        let status: CLAuthorizationStatus
        if #available(macOS 11.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }

        switch status {
        case .authorizedAlways:
            result("granted")
        case .denied:
            result("denied")
        case .restricted:
            result("restricted")
        case .notDetermined:
            result("notDetermined")
        @unknown default:
            result("unknown")
        }
    }

    // CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let result = pendingResult else { return }
        pendingResult = nil

        let status: CLAuthorizationStatus
        if #available(macOS 11.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }

        switch status {
        case .authorizedAlways:
            result("granted")
        case .denied:
            result("denied")
        case .restricted:
            result("restricted")
        case .notDetermined:
            result("notDetermined")
        @unknown default:
            result("unknown")
        }
    }
}
