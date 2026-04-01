import 'package:connectivity_control/src/core/enums/network_type.dart';
import 'package:connectivity_control/src/core/models/network_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkInfo', () {
    group('constructor', () {
      test('creates instance with required type only', () {
        final info = NetworkInfo(type: NetworkType.wifi);

        expect(info.type, NetworkType.wifi);
        expect(info.hasInternet, isNull);
        expect(info.isValidated, isNull);
        expect(info.isMetered, isNull);
        expect(info.downLinkKbps, isNull);
        expect(info.upLinkKbps, isNull);
      });

      test('creates instance with all parameters', () {
        final info = NetworkInfo(
          type: NetworkType.cellular,
          hasInternet: true,
          isValidated: true,
          isMetered: false,
          downLinkKbps: 1000,
          upLinkKbps: 500,
        );

        expect(info.type, NetworkType.cellular);
        expect(info.hasInternet, isTrue);
        expect(info.isValidated, isTrue);
        expect(info.isMetered, isFalse);
        expect(info.downLinkKbps, 1000);
        expect(info.upLinkKbps, 500);
      });

      test('accepts all NetworkType variants', () {
        for (final type in NetworkType.values) {
          final info = NetworkInfo(type: type);
          expect(info.type, type);
        }
      });
    });

    group('fromMap', () {
      test('parses all fields correctly', () {
        final info = NetworkInfo.fromMap({
          'type': 'wifi',
          'hasInternet': true,
          'isValidated': true,
          'isMetered': false,
          'downLinkKbps': 2000,
          'upLinkKbps': 800,
        });

        expect(info.type, NetworkType.wifi);
        expect(info.hasInternet, isTrue);
        expect(info.isValidated, isTrue);
        expect(info.isMetered, isFalse);
        expect(info.downLinkKbps, 2000);
        expect(info.upLinkKbps, 800);
      });

      test('parses vpn type', () {
        final info = NetworkInfo.fromMap({'type': 'vpn'});
        expect(info.type, NetworkType.vpn);
      });

      test('parses ethernet type', () {
        final info = NetworkInfo.fromMap({'type': 'ethernet'});
        expect(info.type, NetworkType.ethernet);
      });

      test('parses cellular type', () {
        final info = NetworkInfo.fromMap({'type': 'cellular'});
        expect(info.type, NetworkType.cellular);
      });

      test('parses other type', () {
        final info = NetworkInfo.fromMap({'type': 'other'});
        expect(info.type, NetworkType.other);
      });

      test('defaults to other for unknown type string', () {
        final info = NetworkInfo.fromMap({'type': 'bluetooth'});
        expect(info.type, NetworkType.other);
      });

      test('defaults to other when type key is missing', () {
        final info = NetworkInfo.fromMap({});
        expect(info.type, NetworkType.other);
      });

      test('defaults to other when type value is null', () {
        final info = NetworkInfo.fromMap({'type': null});
        expect(info.type, NetworkType.other);
      });

      test('handles all optional fields as null when absent', () {
        final info = NetworkInfo.fromMap({'type': 'wifi'});

        expect(info.hasInternet, isNull);
        expect(info.isValidated, isNull);
        expect(info.isMetered, isNull);
        expect(info.downLinkKbps, isNull);
        expect(info.upLinkKbps, isNull);
      });

      test('handles false boolean fields correctly', () {
        final info = NetworkInfo.fromMap({
          'type': 'wifi',
          'hasInternet': false,
          'isValidated': false,
          'isMetered': true,
        });

        expect(info.hasInternet, isFalse);
        expect(info.isValidated, isFalse);
        expect(info.isMetered, isTrue);
      });

      test('handles zero bandwidth values', () {
        final info = NetworkInfo.fromMap({
          'type': 'cellular',
          'downLinkKbps': 0,
          'upLinkKbps': 0,
        });

        expect(info.downLinkKbps, 0);
        expect(info.upLinkKbps, 0);
      });

      test('handles large bandwidth values', () {
        final info = NetworkInfo.fromMap({
          'type': 'ethernet',
          'downLinkKbps': 1000000,
          'upLinkKbps': 500000,
        });

        expect(info.downLinkKbps, 1000000);
        expect(info.upLinkKbps, 500000);
      });
    });

    group('toString', () {
      test('starts with NetworkInfo( and ends with )', () {
        final info = NetworkInfo(type: NetworkType.vpn);
        expect(info.toString(), startsWith('NetworkInfo('));
        expect(info.toString(), endsWith(')'));
      });

      test('includes type name', () {
        for (final type in NetworkType.values) {
          final info = NetworkInfo(type: type);
          expect(info.toString(), contains('type: ${type.name}'));
        }
      });

      test('includes all field values when set', () {
        final info = NetworkInfo(
          type: NetworkType.wifi,
          hasInternet: true,
          isValidated: false,
          isMetered: true,
          downLinkKbps: 100,
          upLinkKbps: 50,
        );
        final result = info.toString();

        expect(result, contains('hasInternet: true'));
        expect(result, contains('isValidated: false'));
        expect(result, contains('isMetered: true'));
        expect(result, contains('downLinkKbps: 100'));
        expect(result, contains('upLinkKbps: 50'));
      });

      test('shows null for absent optional fields', () {
        final info = NetworkInfo(type: NetworkType.cellular);
        final result = info.toString();

        expect(result, contains('hasInternet: null'));
        expect(result, contains('isValidated: null'));
        expect(result, contains('isMetered: null'));
        expect(result, contains('downLinkKbps: null'));
        expect(result, contains('upLinkKbps: null'));
      });
    });
  });
}
