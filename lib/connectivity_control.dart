import 'package:connectivity_control/src/core/models/network_info.dart';
import 'package:connectivity_control/src/platform_interface/connectivity_control_platform_interface.dart';

class ConnectivityControl {
  Future<String?> getPlatformVersion() {
    return ConnectivityControlPlatform.instance.getPlatformVersion();
  }

  Future<List<NetworkInfo>> getActiveNetworks() {
    return ConnectivityControlPlatform.instance.getActiveNetworks();
  }

  Stream<List<NetworkInfo>> listenToActiveNetworks() {
    return ConnectivityControlPlatform.instance.listenToActiveNetworks();
  }
}
