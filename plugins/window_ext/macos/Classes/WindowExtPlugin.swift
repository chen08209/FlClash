import Cocoa
import FlutterMacOS

public class WindowExtPlugin: NSObject, FlutterPlugin {
    public static var instance:WindowExtPlugin?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "window_ext", binaryMessenger: registrar.messenger)
        instance = WindowExtPlugin(registrar, channel)
        registrar.addMethodCallDelegate(instance!, channel: channel)
    }
    
    private var registrar: FlutterPluginRegistrar!
    private var channel: FlutterMethodChannel!
    
    public init(_ registrar: FlutterPluginRegistrar, _ channel: FlutterMethodChannel) {
        super.init()
        self.registrar = registrar
        self.channel = channel
    }
    
    public func handleShouldTerminate(){
        channel.invokeMethod("shouldTerminate", arguments: nil)
    }
}
