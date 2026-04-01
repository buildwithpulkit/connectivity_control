import 'package:connectivity_control/connectivity_control.dart';
import 'package:connectivity_control/src/core/enums/network_type.dart';
import 'package:connectivity_control/src/core/models/network_info.dart';
import 'package:connectivity_control/src/method_channel/connectivity_control_method_channel.dart';
import 'package:connectivity_control/src/platform_interface/connectivity_control_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockPlatform extends ConnectivityControlPlatform {
  List<NetworkInfo> networks;
  Stream<List<NetworkInfo>> stream;

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

void main() {
  group('ConnectivityControl', () {
    late ConnectivityControl control;

    setUp(() {
      control = ConnectivityControl();
    });

    tearDown(() {
      ConnectivityControlPlatform.instance = MethodChannelConnectivityControl();
    });

    group('getActiveNetworks', () {
      test('returns data from platform instance', () async {
        final expected = [
          NetworkInfo(type: NetworkType.wifi, hasInternet: true),
        ];
        ConnectivityControlPlatform.instance = _MockPlatform(networks: expected);

        final result = await control.getActiveNetworks();
        expect(result, expected);
      });

      test('returns empty list when platform returns empty', () async {
        ConnectivityControlPlatform.instance = _MockPlatform(networks: []);

        final result = await control.getActiveNetworks();
        expect(result, isEmpty);
      });

      test('returns multiple networks', () async {
        final expected = [
          NetworkInfo(type: NetworkType.wifi, hasInternet: true),
          NetworkInfo(type: NetworkType.vpn, hasInternet: true),
          NetworkInfo(type: NetworkType.cellular, hasInternet: false),
        ];
        ConnectivityControlPlatform.instance = _MockPlatform(networks: expected);

        final result = await control.getActiveNetworks();

        expect(result, hasLength(3));
        expect(result[0].type, NetworkType.wifi);
        expect(result[1].type, NetworkType.vpn);
        expect(result[2].type, NetworkType.cellular);
      });

      test('returns a Future', () {
        ConnectivityControlPlatform.instance = _MockPlatform();

        final result = control.getActiveNetworks();
        expect(result, isA<Future<List<NetworkInfo>>>());
      });
    });

    group('listenToActiveNetworks', () {
      test('returns a Stream', () {
        ConnectivityControlPlatform.instance = _MockPlatform();

        final result = control.listenToActiveNetworks();
        expect(result, isA<Stream<List<NetworkInfo>>>());
      });

      test('emits data from platform stream', () async {
        final expected = [NetworkInfo(type: NetworkType.cellular)];
        ConnectivityControlPlatform.instance = _MockPlatform(
          stream: Stream.value(expected),
        );

        final result = await control.listenToActiveNetworks().first;
        expect(result, expected);
      });

      test('emits multiple events', () async {
        final event1 = [NetworkInfo(type: NetworkType.wifi)];
        final event2 = [
          NetworkInfo(type: NetworkType.wifi),
          NetworkInfo(type: NetworkType.vpn),
        ];
        ConnectivityControlPlatform.instance = _MockPlatform(
          stream: Stream.fromIterable([event1, event2]),
        );

        final results = await control.listenToActiveNetworks().toList();
        expect(results, hasLength(2));
        expect(results[0], event1);
        expect(results[1], event2);
      });
    });

    group('instance sharing', () {
      test('multiple instances share the same platform', () async {
        final expected = [NetworkInfo(type: NetworkType.ethernet)];
        ConnectivityControlPlatform.instance = _MockPlatform(networks: expected);

        final control1 = ConnectivityControl();
        final control2 = ConnectivityControl();

        final result1 = await control1.getActiveNetworks();
        final result2 = await control2.getActiveNetworks();

        expect(result1, expected);
        expect(result2, expected);
      });
    });
  });
}
