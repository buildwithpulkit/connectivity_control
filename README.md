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

---

## Installation

```yaml
dependencies:
  connectivity_control: ^0.0.4
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
final networks = await ConnectivityControl.instance.getActiveNetworks();
print(networks);
```

### Listen to Network Changes

```dart
ConnectivityControl.instance.onActiveNetworksChanged.listen((networks) {
  print(networks);
});
```

---

## NetworkInfo Fields

| Field | Android | iOS |
|-------|---------|-----|
| `type` | wifi, cellular, vpn, ethernet | wifi, cellular, ethernet, other |
| `hasInternet` | Yes | Yes |
| `isValidated` | Yes | Yes |
| `isMetered` | Yes | Yes |
| `downLinkKbps` | Yes | Not available |
| `upLinkKbps` | Yes | Not available |

### Platform Notes

- **VPN detection**: Android reports VPN as a separate network type. iOS does not expose VPN as a distinct interface type; VPN traffic appears under the underlying transport (Wi-Fi or cellular).
- **Bandwidth**: iOS does not provide bandwidth estimation APIs. `downLinkKbps` and `upLinkKbps` will be `null` on iOS.
