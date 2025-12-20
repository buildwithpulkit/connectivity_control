import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_control/connectivity_control.dart';
import 'package:connectivity_control/connectivity_control_platform_interface.dart';
import 'package:connectivity_control/connectivity_control_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockConnectivityControlPlatform
    with MockPlatformInterfaceMixin
    implements ConnectivityControlPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ConnectivityControlPlatform initialPlatform = ConnectivityControlPlatform.instance;

  test('$MethodChannelConnectivityControl is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelConnectivityControl>());
  });

  test('getPlatformVersion', () async {
    ConnectivityControl connectivityControlPlugin = ConnectivityControl();
    MockConnectivityControlPlatform fakePlatform = MockConnectivityControlPlatform();
    ConnectivityControlPlatform.instance = fakePlatform;

    expect(await connectivityControlPlugin.getPlatformVersion(), '42');
  });
}
