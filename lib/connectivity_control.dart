import 'package:connectivity_control/src/core/models/network_info.dart';
import 'package:connectivity_control/src/platform_interface/connectivity_control_platform_interface.dart';

export 'package:connectivity_control/src/core/enums/network_type.dart';
export 'package:connectivity_control/src/core/models/network_info.dart';

/// Exposes APIs to access network connectivity information.
///
/// This class delegates platform-specific implementations to
/// [ConnectivityControlPlatform].
class ConnectivityControl {
  /// Creates or returns the singleton [ConnectivityControl] instance.
  factory ConnectivityControl() => _instance;

  ConnectivityControl._();

  static final ConnectivityControl _instance = ConnectivityControl._();

  /// Returns the list of currently active network connections.
  ///
  /// The returned list may contain multiple entries when more than one
  /// network is active at the same time (for example, Wi-Fi and VPN).
  ///
  /// The availability and accuracy of the reported information depends
  /// on the underlying platform.
  Future<List<NetworkInfo>> getActiveNetworks() {
    return ConnectivityControlPlatform.instance.getActiveNetworks();
  }

  /// Emits updates whenever the set of active network connections changes.
  ///
  /// The stream produces a new list of [NetworkInfo] whenever the platform
  /// detects a change in network state, such as connecting to or
  /// disconnecting from a network.
  Stream<List<NetworkInfo>> get onActiveNetworksChanged {
    return ConnectivityControlPlatform.instance.onActiveNetworksChanged;
  }
}
