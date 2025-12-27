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
  static const EventChannel _eventChannel = EventChannel(
    'connectivity_control/events',
  );

  @override
  Future<List<NetworkInfo>> getActiveNetworks() async {
    final result = await _methodChannel.invokeMethod<List<dynamic>>(
      'getActiveNetworks',
    );

    if (result == null || result.isEmpty) return <NetworkInfo>[];

    return result
        .cast<Map<dynamic, dynamic>>()
        .map(NetworkInfo.fromMap)
        .toList();
  }

  @override
  Stream<List<NetworkInfo>> listenToActiveNetworks() {
    return _eventChannel.receiveBroadcastStream().map((event) {
      if (event == null) return <NetworkInfo>[];

      final list = event as List<dynamic>;

      return list
          .cast<Map<dynamic, dynamic>>()
          .map(NetworkInfo.fromMap)
          .toList();
    });
  }
}
