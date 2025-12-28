import 'package:connectivity_control/src/core/enums/network_type.dart';

/// Holds detailed information about a single network connection.
///
/// This model represents network characteristics reported by the
/// underlying platform (Android or iOS).
/// Not all fields are guaranteed to be available on every platform
/// or OS version, so several properties are nullable.
class NetworkInfo {
  /// The type of network connection (e.g. Wi-Fi, cellular, VPN).
  final NetworkType type;

  /// Whether the network is currently capable of accessing the internet.
  final bool? hasInternet;

  /// Whether the network connection has been validated by the system.
  final bool? isValidated;

  /// Whether the network connection is metered.
  ///
  /// Metered networks may incur data charges and should be used
  /// cautiously for large transfers.
  final bool? isMetered;

  /// Estimated downstream bandwidth in kilobits per second (Kbps).
  ///
  /// This value is platform-reported and may be approximate.
  /// Not
  final int? downLinkKbps;

  /// Estimated upstream bandwidth in kilobits per second (Kbps).
  ///
  /// This value is platform-reported and may be approximate.
  final int? upLinkKbps;

  /// Creates a new [NetworkInfo] instance.
  ///
  /// The [type] parameter is required, while all other properties
  /// are optional and may be `null` depending on platform support.
  NetworkInfo({
    required this.type,
    this.hasInternet,
    this.isValidated,
    this.isMetered,
    this.downLinkKbps,
    this.upLinkKbps,
  });

  /// Creates a [NetworkInfo] instance from a platform channel map.
  ///
  /// The map is typically received from native platform code
  /// via platform channels. If the provided network type is unknown
  /// or missing, [NetworkType.other] is used as a fallback.
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
