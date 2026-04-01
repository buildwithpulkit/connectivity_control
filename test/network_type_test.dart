import 'package:connectivity_control/src/core/enums/network_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkType', () {
    test('has exactly 5 values', () {
      expect(NetworkType.values.length, 5);
    });

    test('contains all expected variants', () {
      expect(
          NetworkType.values,
          containsAll([
            NetworkType.vpn,
            NetworkType.wifi,
            NetworkType.ethernet,
            NetworkType.cellular,
            NetworkType.other,
          ]));
    });

    test('enum names match expected strings', () {
      expect(NetworkType.vpn.name, 'vpn');
      expect(NetworkType.wifi.name, 'wifi');
      expect(NetworkType.ethernet.name, 'ethernet');
      expect(NetworkType.cellular.name, 'cellular');
      expect(NetworkType.other.name, 'other');
    });

    test('values are unique', () {
      final names = NetworkType.values.map((e) => e.name).toSet();
      expect(names.length, NetworkType.values.length);
    });

    test('can look up by name', () {
      for (final type in NetworkType.values) {
        final found = NetworkType.values.firstWhere((e) => e.name == type.name);
        expect(found, type);
      }
    });
  });
}
