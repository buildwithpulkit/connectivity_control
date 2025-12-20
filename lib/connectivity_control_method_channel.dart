import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'connectivity_control_platform_interface.dart';

/// An implementation of [ConnectivityControlPlatform] that uses method channels.
class MethodChannelConnectivityControl extends ConnectivityControlPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('connectivity_control');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
