import FlutterMacOS
import Network

public class ConnectivityControlPlugin: NSObject, FlutterPlugin {

  private let monitor: NWPathMonitor
  private let queue = DispatchQueue(label: "connectivity_control.monitor")
  private var methodChannel: FlutterMethodChannel?
  private var eventChannel: FlutterEventChannel?

  override init() {
    self.monitor = NWPathMonitor()
    super.init()
    self.monitor.start(queue: queue)
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = ConnectivityControlPlugin()

    let methodChannel = FlutterMethodChannel(name: "connectivity_control/methods", binaryMessenger: registrar.messenger)
    instance.methodChannel = methodChannel
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let eventChannel = FlutterEventChannel(name: "connectivity_control/events", binaryMessenger: registrar.messenger)
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
      let path = monitor.currentPath
      let networks = NetworkInformationMapper.map(path: path)
      result(networks)

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
