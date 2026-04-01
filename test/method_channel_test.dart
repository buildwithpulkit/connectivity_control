import 'package:connectivity_control/src/core/enums/network_type.dart';
import 'package:connectivity_control/src/method_channel/connectivity_control_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('connectivity_control/methods');
  const eventChannel = EventChannel('connectivity_control/events');

  late MethodChannelConnectivityControl plugin;

  setUp(() {
    plugin = MethodChannelConnectivityControl();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(eventChannel, null);
  });

  group('MethodChannelConnectivityControl', () {
    group('getActiveNetworks', () {
      test('returns empty list when channel returns null', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (_) async => null);

        final result = await plugin.getActiveNetworks();
        expect(result, isEmpty);
      });

      test('returns empty list when channel returns empty list', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (_) async => <dynamic>[]);

        final result = await plugin.getActiveNetworks();
        expect(result, isEmpty);
      });

      test('calls getActiveNetworks method on the channel', () async {
        String? invokedMethod;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
          invokedMethod = call.method;
          return null;
        });

        await plugin.getActiveNetworks();
        expect(invokedMethod, 'getActiveNetworks');
      });

      test('parses a single network correctly', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (_) async => [
                  {
                    'type': 'wifi',
                    'hasInternet': true,
                    'isValidated': true,
                    'isMetered': false,
                    'downLinkKbps': 5000,
                    'upLinkKbps': 1000,
                  }
                ]);

        final result = await plugin.getActiveNetworks();

        expect(result, hasLength(1));
        expect(result.first.type, NetworkType.wifi);
        expect(result.first.hasInternet, isTrue);
        expect(result.first.isValidated, isTrue);
        expect(result.first.isMetered, isFalse);
        expect(result.first.downLinkKbps, 5000);
        expect(result.first.upLinkKbps, 1000);
      });

      test('parses multiple networks', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (_) async => [
                  {'type': 'wifi', 'hasInternet': true},
                  {'type': 'vpn', 'hasInternet': true},
                  {'type': 'cellular', 'hasInternet': false},
                ]);

        final result = await plugin.getActiveNetworks();

        expect(result, hasLength(3));
        expect(result[0].type, NetworkType.wifi);
        expect(result[1].type, NetworkType.vpn);
        expect(result[2].type, NetworkType.cellular);
      });

      test('parses network with null optional fields', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (_) async => [
                  {'type': 'ethernet'}
                ]);

        final result = await plugin.getActiveNetworks();

        expect(result, hasLength(1));
        expect(result.first.type, NetworkType.ethernet);
        expect(result.first.hasInternet, isNull);
        expect(result.first.isValidated, isNull);
        expect(result.first.isMetered, isNull);
        expect(result.first.downLinkKbps, isNull);
        expect(result.first.upLinkKbps, isNull);
      });

      test('defaults unknown network type to other', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (_) async => [
                  {'type': 'satellite'}
                ]);

        final result = await plugin.getActiveNetworks();

        expect(result.first.type, NetworkType.other);
      });
    });

    group('listenToActiveNetworks', () {
      test('returns empty list when event data is null', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockStreamHandler(
          eventChannel,
          MockStreamHandler.inline(
            onListen: (_, events) {
              events.success(null);
              events.endOfStream();
            },
          ),
        );

        final result = await plugin.listenToActiveNetworks().first;
        expect(result, isEmpty);
      });

      test('emits parsed NetworkInfo list', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockStreamHandler(
          eventChannel,
          MockStreamHandler.inline(
            onListen: (_, events) {
              events.success([
                {
                  'type': 'ethernet',
                  'hasInternet': true,
                  'downLinkKbps': 100000,
                  'upLinkKbps': 50000,
                }
              ]);
              events.endOfStream();
            },
          ),
        );

        final result = await plugin.listenToActiveNetworks().first;

        expect(result, hasLength(1));
        expect(result.first.type, NetworkType.ethernet);
        expect(result.first.hasInternet, isTrue);
        expect(result.first.downLinkKbps, 100000);
        expect(result.first.upLinkKbps, 50000);
      });

      test('emits multiple events in order', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockStreamHandler(
          eventChannel,
          MockStreamHandler.inline(
            onListen: (_, events) {
              events.success([{'type': 'wifi'}]);
              events.success([{'type': 'cellular'}]);
              events.endOfStream();
            },
          ),
        );

        final results = await plugin.listenToActiveNetworks().toList();

        expect(results, hasLength(2));
        expect(results[0].first.type, NetworkType.wifi);
        expect(results[1].first.type, NetworkType.cellular);
      });

      test('emits empty list when event data is empty list', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockStreamHandler(
          eventChannel,
          MockStreamHandler.inline(
            onListen: (_, events) {
              events.success(<dynamic>[]);
              events.endOfStream();
            },
          ),
        );

        final result = await plugin.listenToActiveNetworks().first;
        expect(result, isEmpty);
      });

      test('returns a broadcast stream', () {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockStreamHandler(
          eventChannel,
          MockStreamHandler.inline(
            onListen: (_, events) => events.endOfStream(),
          ),
        );

        final stream = plugin.listenToActiveNetworks();
        expect(stream.isBroadcast, isTrue);
      });
    });
  });
}
