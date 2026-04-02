import Foundation
import Flutter
import Network

class ActiveNetworkStreamHandler: NSObject, FlutterStreamHandler {
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "connectivity_control.stream")

    override init() {
        self.monitor = NWPathMonitor()
        super.init()
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                events(NetworkInformationMapper.map(path: path))
            }
        }

        monitor.start(queue: queue)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        monitor.cancel()
        return nil
    }
}
