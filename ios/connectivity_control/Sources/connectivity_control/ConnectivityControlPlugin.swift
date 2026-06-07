import UIKit
import Flutter
import Network

public class ConnectivityControlPlugin: NSObject, FlutterPlugin {

  private let monitor: NWPathMonitor
  private let queue = DispatchQueue(label: "connectivity_control.monitor")
  private var methodChannel: FlutterMethodChannel?
  private var eventChannel: FlutterEventChannel?
  private var cachedPath: NWPath?
  private var pendingResults: [FlutterResult] = []

  override init() {
    self.monitor = NWPathMonitor()
    super.init()
    self.monitor.pathUpdateHandler = { [weak self] path in
      DispatchQueue.main.async {
        guard let self = self else { return }
        self.cachedPath = path
        let pending = self.pendingResults
        self.pendingResults = []
        let networks = NetworkInformationMapper.map(path: path)
        for pendingResult in pending {
          pendingResult(networks)
        }
      }
    }
    self.monitor.start(queue: queue)
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = ConnectivityControlPlugin()

    let methodChannel = FlutterMethodChannel(name: "connectivity_control/methods", binaryMessenger: registrar.messenger())
    instance.methodChannel = methodChannel
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let eventChannel = FlutterEventChannel(name: "connectivity_control/events", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(ActiveNetworkStreamHandler())
    instance.eventChannel = eventChannel
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    monitor.cancel()
    methodChannel?.setMethodCallHandler(nil)
    methodChannel = nil
    eventChannel?.setStreamHandler(nil)
    eventChannel = nil
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {

    case "getActiveNetworks":
      if let path = cachedPath {
        result(NetworkInformationMapper.map(path: path))
      } else {
        pendingResults.append(result)
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
