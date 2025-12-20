
import 'connectivity_control_platform_interface.dart';

class ConnectivityControl {
  Future<String?> getPlatformVersion() {
    return ConnectivityControlPlatform.instance.getPlatformVersion();
  }
}
