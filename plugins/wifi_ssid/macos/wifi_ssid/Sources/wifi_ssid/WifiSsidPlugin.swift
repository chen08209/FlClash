import Cocoa
import CoreLocation
import CoreWLAN
import FlutterMacOS

public class WifiSsidPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    private let wifiClient = CWWiFiClient.shared()
    private let ssidQueue = DispatchQueue(label: "com.follow.clash.wifi_ssid")
    private var pendingPermissionResult: FlutterResult?

    private enum Method {
        static let getSsid = "getSsid"
        static let checkPermission = "checkPermission"
        static let requestPermission = "requestPermission"
    }

    private enum ErrorCode {
        static let inProgress = "IN_PROGRESS"
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "wifi_ssid", binaryMessenger: registrar.messenger
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
        case Method.getSsid:
            getSsid(result: result)
        case Method.checkPermission:
            checkPermission(result: result)
        case Method.requestPermission:
            requestPermission(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Permission

    private func checkPermission(result: @escaping FlutterResult) {
        // CoreWLAN only requires location authorization on macOS 14+.
        guard #available(macOS 14, *) else {
            result(WifiSsidPermission.granted.rawValue)
            return
        }
        result(mapAuthStatus(locationManager.authorizationStatus).rawValue)
    }

    private func requestPermission(result: @escaping FlutterResult) {
        guard #available(macOS 14, *) else {
            result(WifiSsidPermission.granted.rawValue)
            return
        }
        let permission = mapAuthStatus(locationManager.authorizationStatus)
        if permission != .denied {
            result(permission.rawValue)
            return
        }
        if pendingPermissionResult != nil {
            result(
                FlutterError(
                    code: ErrorCode.inProgress,
                    message: "A permission request is already active",
                    details: nil
                )
            )
            return
        }
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
        case .authorizedAlways, .authorizedWhenInUse:
            return .granted
        case .denied, .restricted:
            return .permanentlyDenied
        default:
            return .denied
        }
    }

    private enum WifiSsidPermission: Int {
        // Values must match WifiSsidPermission.index in Dart.
        case granted = 0
        case denied = 1
        case permanentlyDenied = 2
    }

    // MARK: - SSID

    private func getSsid(result: @escaping FlutterResult) {
        if #available(macOS 14, *) {
            guard mapAuthStatus(locationManager.authorizationStatus) == .granted else {
                result(nil)
                return
            }
        }
        // CoreWLAN reaches wifid over XPC, so a wedged daemon would hold the
        // platform thread and freeze the window until it answers.
        let client = wifiClient
        ssidQueue.async {
            let ssid = client.interface()?.ssid()
            DispatchQueue.main.async {
                result(ssid)
            }
        }
    }
}
