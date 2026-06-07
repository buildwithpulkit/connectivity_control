# connectivity_control

A Flutter plugin that provides **low-level, system-driven visibility into active network interfaces** on a device.

Unlike basic connectivity checks, this plugin is designed to help apps **understand, observe, and reason about multiple simultaneous networks** (Wi-Fi, cellular, VPN, etc.) using native platform signals.

---

## Features

- Detect **all active network interfaces**
- Identify network **type** (Wi-Fi, cellular, VPN, Ethernet)
- Determine whether a network:
  - Has internet capability
  - Is validated by the system
  - Is metered or unmetered
- Retrieve **upstream and downstream bandwidth estimates** (Android only)
- Listen to **real-time network changes** via streams
- Native, event-driven implementation (no polling)

---

## Platform Support

| Platform | Support |
|----------|---------|
| Android  | Full support (API 23+) |
| iOS      | Full support (iOS 13+) |
| macOS    | Full support (macOS 10.15+) |

---

## Installation

```yaml
dependencies:
  connectivity_control: ^1.0.0
```

```bash
flutter pub get
```

---

## How to Use

```dart
import 'package:connectivity_control/connectivity_control.dart';
```

### Get Active Networks

```dart
final networks = await ConnectivityControl().getActiveNetworks();
print(networks);
```

### Listen to Network Changes

```dart
ConnectivityControl().onActiveNetworksChanged.listen((networks) {
  print(networks);
});
```

---

## NetworkInfo Fields

| Field | Android | iOS | macOS |
|-------|---------|-----|-------|
| `type` | wifi, cellular, vpn, ethernet | wifi, cellular, ethernet, other | wifi, ethernet, other |
| `hasInternet` | Yes | Yes | Yes |
| `isValidated` | Yes | Yes | Yes |
| `isMetered` | Yes | Yes | Yes |
| `downLinkKbps` | Yes | Not available | Not available |
| `upLinkKbps` | Yes | Not available | Not available |

### Platform Notes

- **VPN detection**: Android reports VPN as a separate network type. iOS and macOS do not expose VPN as a distinct interface type via `NWPathMonitor`; VPN traffic appears under the underlying transport.
- **Bandwidth**: iOS and macOS do not provide bandwidth estimation APIs. `downLinkKbps` and `upLinkKbps` will be `null` on both platforms.
- **`isMetered` on macOS**: Maps to `isExpensive || isConstrained`. `isExpensive` is true for shared connections (e.g. iPhone USB tethering); `isConstrained` reflects the user enabling Low Data Mode in System Preferences.
