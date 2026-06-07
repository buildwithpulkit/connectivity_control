import Foundation
import FlutterMacOS
import Network

class ActiveNetworkStreamHandler: NSObject, FlutterStreamHandler {
    private var monitor: NWPathMonitor?
    private let queue = DispatchQueue(label: "connectivity_control.stream")

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                events(NetworkInformationMapper.map(path: path))
            }
        }
        monitor.start(queue: queue)
        self.monitor = monitor
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        monitor?.cancel()
        monitor = nil
        return nil
    }
}
