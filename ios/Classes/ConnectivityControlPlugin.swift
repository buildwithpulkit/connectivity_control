import UIKit
import Flutter
import Network

public class ConnectivityControlPlugin: NSObject, FlutterPlugin {

  private let monitor: NWPathMonitor
  private let queue = DispatchQueue(label: "connectivity_control.monitor")

  override init() {
    self.monitor = NWPathMonitor()
    super.init()
    self.monitor.start(queue: queue)
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(name: "connectivity_control/methods", binaryMessenger: registrar.messenger())
    let instance = ConnectivityControlPlugin()
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      
    case "getActiveNetworks":
      let path = monitor.currentPath
      let networks = NetworkInformationMapper.map(path: path)
      result(networks)

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
