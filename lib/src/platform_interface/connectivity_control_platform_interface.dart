import 'package:connectivity_control/src/core/models/network_info.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:connectivity_control/src/method_channel/connectivity_control_method_channel.dart';

abstract class ConnectivityControlPlatform extends PlatformInterface {
  /// Constructs a ConnectivityControlPlatform.
  ConnectivityControlPlatform() : super(token: _token);

  static final Object _token = Object();

  static ConnectivityControlPlatform _instance =
      MethodChannelConnectivityControl();

  /// The default instance of [ConnectivityControlPlatform] to use.
  ///
  /// Defaults to [MethodChannelConnectivityControl].
  static ConnectivityControlPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ConnectivityControlPlatform] when
  /// they register themselves.
  static set instance(ConnectivityControlPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns currently active networks.
  Future<List<NetworkInfo>> getActiveNetworks() {
    throw UnimplementedError('getActiveNetworks() has not been implemented.');
  }

  /// Stream of active network changes.
  Stream<List<NetworkInfo>> listenToActiveNetworks() {
    throw UnimplementedError(
      'listenToActiveNetworks() has not been implemented.',
    );
  }
}
