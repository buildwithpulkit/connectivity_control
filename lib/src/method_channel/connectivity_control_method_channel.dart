import 'package:flutter/services.dart';
import 'package:connectivity_control/src/core/models/network_info.dart';
import 'package:connectivity_control/src/platform_interface/connectivity_control_platform_interface.dart';

/// An implementation of [ConnectivityControlPlatform] that uses method channels.
class MethodChannelConnectivityControl extends ConnectivityControlPlatform {
  /// The method channel used to interact with the native platform.
  static const MethodChannel _methodChannel = MethodChannel(
    'connectivity_control/methods',
  );

  /// The event channel used to interact with the native platform.
  // static const EventChannel _eventChannel = EventChannel(
  //   'connectivity_control/events',
  // );

  @override
  Future<String?> getPlatformVersion() async {
    final version = await _methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<List<NetworkInfo>> getActiveNetworks() async {
    return <NetworkInfo>[];
  }

  @override
  Stream<List<NetworkInfo>> listenToActiveNetworks() {
    return const Stream.empty();
  }
}
