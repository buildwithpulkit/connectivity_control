import Network
import Foundation

final class NetworkInformationMapper {

    static func map(path: NWPath) -> [[String: Any?]] {
        var results: [[String: Any?]] = []

        if path.usesInterfaceType(.wifi) {
            results.append(buildNetworkMap(type: "wifi", path: path))
        }

        if path.usesInterfaceType(.cellular) {
            results.append(buildNetworkMap(type: "cellular", path: path))
        }

        if path.usesInterfaceType(.wiredEthernet) {
            results.append(buildNetworkMap(type: "ethernet", path: path))
        }

        if path.usesInterfaceType(.other) {
            results.append(buildNetworkMap(type: "other", path: path))
        }

        return results
    }

    private static func buildNetworkMap(
        type: String,
        path: NWPath
    ) -> [String: Any?] {
        return [
            "type": type,
            "hasInternet": path.status == .satisfied,
            "isValidated": path.status == .satisfied,
            "isMetered": path.isExpensive,
            "downLinkKbps": nil,
            "upLinkKbps": nil
        ]
    }
}
