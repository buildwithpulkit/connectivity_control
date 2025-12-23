import 'package:connectivity_control/src/core/enums/network_type.dart';

class NetworkInfo {
  final NetworkType type;
  final bool? hasInternet;
  final bool? isValidated;
  final bool? isMetered;
  final bool? isDefaultNetwork;
  final int? downLinkKbps;
  final int? upLinkKbps;

  NetworkInfo({
    required this.type,
    this.hasInternet,
    this.isValidated,
    this.isMetered,
    this.isDefaultNetwork,
    this.downLinkKbps,
    this.upLinkKbps,
  });
}
