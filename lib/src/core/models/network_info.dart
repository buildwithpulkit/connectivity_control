import 'package:connectivity_control/src/core/enums/network_type.dart';

class NetworkInfo {
  final NetworkType type;
  final bool? hasInternet;
  final bool? isValidated;
  final bool? isMetered;
  final int? downLinkKbps;
  final int? upLinkKbps;

  NetworkInfo({
    required this.type,
    this.hasInternet,
    this.isValidated,
    this.isMetered,
    this.downLinkKbps,
    this.upLinkKbps,
  });

  factory NetworkInfo.fromMap(Map<dynamic, dynamic> map) {
    return NetworkInfo(
      type: NetworkType.values.firstWhere(
        (network) => network.name == map["type"],
        orElse: () => NetworkType.other,
      ),
      hasInternet: map["hasInternet"] as bool?,
      isValidated: map["isValidated"] as bool?,
      isMetered: map["isMetered"] as bool?,
      downLinkKbps: map["downLinkKbps"] as int?,
      upLinkKbps: map["upLinkKbps"] as int?,
    );
  }

  @override
  String toString() {
    return 'NetworkInfo('
        'type: ${type.name}, '
        'hasInternet: $hasInternet, '
        'isValidated: $isValidated, '
        'isMetered: $isMetered, '
        'downLinkKbps: $downLinkKbps, '
        'upLinkKbps: $upLinkKbps'
        ')';
  }
}
