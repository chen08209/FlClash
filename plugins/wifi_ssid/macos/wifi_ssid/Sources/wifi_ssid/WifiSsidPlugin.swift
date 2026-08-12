import Cocoa
import CoreLocation
import CoreWLAN
import FlutterMacOS

// Permission values must match WifiSsidPermission enum index in Dart:
//   0 = granted, 1 = denied, 2 = permanentlyDenied
public class WifiSsidPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    private var pendingPermissionResult: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "wifi_ssid",
            binaryMessenger: registrar.messenger
        )
        let instance = WifiSsidPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    override init() {
        super.init()
        locationManager.delegate = self
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getSsid":
            getSsid(result: result)
        case "checkPermission":
            checkPermission(result: result)
        case "requestPermission":
            requestPermission(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Permission

    private func checkPermission(result: @escaping FlutterResult) {
        let status = locationManager.authorizationStatus
        result(mapAuthStatus(status).rawValue)
    }

    private func requestPermission(result: @escaping FlutterResult) {
        let status = locationManager.authorizationStatus
        if status == .authorizedAlways {
            result(0) // granted
            return
        }
        // .restricted can never be granted by a prompt, so replying here
        // keeps the Dart future from waiting forever.
        if status == .denied || status == .restricted {
            result(2) // permanentlyDenied
            return
        }
        // A second request would otherwise strand the first caller.
        pendingPermissionResult?(mapAuthStatus(status).rawValue)
        pendingPermissionResult = result
        locationManager.requestWhenInUseAuthorization()
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let result = pendingPermissionResult else { return }
        pendingPermissionResult = nil
        result(mapAuthStatus(manager.authorizationStatus).rawValue)
    }

    private func mapAuthStatus(_ status: CLAuthorizationStatus) -> WifiSsidPermission {
        switch status {
        case .authorizedAlways:
            return .granted
        case .denied, .restricted:
            return .permanentlyDenied
        default:
            return .denied
        }
    }

    private enum WifiSsidPermission: Int {
        case granted = 0
        case denied = 1
        case permanentlyDenied = 2
    }

    // MARK: - SSID

    private func getSsid(result: @escaping FlutterResult) {
        // SSID access is location-gated on modern macOS; touching CoreWLAN
        // without authorization can block the platform thread indefinitely,
        // so treat missing permission as "no SSID" and never read inline.
        guard mapAuthStatus(locationManager.authorizationStatus) == .granted else {
            result(nil)
            return
        }
        DispatchQueue.global(qos: .utility).async {
            let ssid = CWWiFiClient.shared().interface()?.ssid()
            DispatchQueue.main.async {
                result(ssid)
            }
        }
    }
}
