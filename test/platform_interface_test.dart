import 'package:connectivity_control/src/core/enums/network_type.dart';
import 'package:connectivity_control/src/core/models/network_info.dart';
import 'package:connectivity_control/src/method_channel/connectivity_control_method_channel.dart';
import 'package:connectivity_control/src/platform_interface/connectivity_control_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// A valid mock that extends [ConnectivityControlPlatform], giving it
/// the correct token so it can be set as the platform instance.
class _MockPlatform extends ConnectivityControlPlatform {
  final List<NetworkInfo> networks;
  final Stream<List<NetworkInfo>> stream;

  _MockPlatform({
    List<NetworkInfo>? networks,
    Stream<List<NetworkInfo>>? stream,
  })  : networks = networks ?? const [],
        stream = stream ?? const Stream.empty();

  @override
  Future<List<NetworkInfo>> getActiveNetworks() async => networks;

  @override
  Stream<List<NetworkInfo>> listenToActiveNetworks() => stream;
}

/// Minimal subclass that does NOT override the abstract methods,
/// so calls fall through to the base-class throw.
class _UnimplementedPlatform extends ConnectivityControlPlatform {}

void main() {
  group('ConnectivityControlPlatform', () {
    tearDown(() {
      // Restore default instance after each test.
      ConnectivityControlPlatform.instance = MethodChannelConnectivityControl();
    });

    test('default instance is MethodChannelConnectivityControl', () {
      expect(
        ConnectivityControlPlatform.instance,
        isA<MethodChannelConnectivityControl>(),
      );
    });

    test('instance can be replaced with a valid mock', () {
      final mock = _MockPlatform();
      ConnectivityControlPlatform.instance = mock;
      expect(ConnectivityControlPlatform.instance, same(mock));
    });

    test('setting instance back to MethodChannel works', () {
      ConnectivityControlPlatform.instance = _MockPlatform();
      ConnectivityControlPlatform.instance = MethodChannelConnectivityControl();
      expect(
        ConnectivityControlPlatform.instance,
        isA<MethodChannelConnectivityControl>(),
      );
    });

    group('base class throws UnimplementedError', () {
      test('getActiveNetworks throws UnimplementedError', () {
        final platform = _UnimplementedPlatform();
        expect(
          () => platform.getActiveNetworks(),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('listenToActiveNetworks throws UnimplementedError', () {
        final platform = _UnimplementedPlatform();
        expect(
          () => platform.listenToActiveNetworks(),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('mock platform delegates', () {
      test('getActiveNetworks returns mock data', () async {
        final expected = [
          NetworkInfo(type: NetworkType.wifi, hasInternet: true),
          NetworkInfo(type: NetworkType.vpn),
        ];
        ConnectivityControlPlatform.instance =
            _MockPlatform(networks: expected);

        final result =
            await ConnectivityControlPlatform.instance.getActiveNetworks();
        expect(result, expected);
      });

      test('getActiveNetworks returns empty list', () async {
        ConnectivityControlPlatform.instance = _MockPlatform(networks: []);
        final result =
            await ConnectivityControlPlatform.instance.getActiveNetworks();
        expect(result, isEmpty);
      });

      test('listenToActiveNetworks emits mock stream data', () async {
        final expected = [NetworkInfo(type: NetworkType.cellular)];
        ConnectivityControlPlatform.instance = _MockPlatform(
          stream: Stream.value(expected),
        );

        final result = await ConnectivityControlPlatform.instance
            .listenToActiveNetworks()
            .first;
        expect(result, expected);
      });

      test('listenToActiveNetworks emits multiple events', () async {
        final event1 = [NetworkInfo(type: NetworkType.wifi)];
        final event2 = [NetworkInfo(type: NetworkType.ethernet)];
        ConnectivityControlPlatform.instance = _MockPlatform(
          stream: Stream.fromIterable([event1, event2]),
        );

        final results = await ConnectivityControlPlatform.instance
            .listenToActiveNetworks()
            .toList();
        expect(results, [event1, event2]);
      });
    });
  });
}
