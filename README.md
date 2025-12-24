# connectivity_control

A Flutter plugin that provides **low-level, real-time visibility into active network interfaces** on a device, including whether each network actually has internet access and its key characteristics.

Unlike basic connectivity checks, this plugin is designed to help apps **understand, observe, and reason about multiple simultaneous networks** (Wi-Fi, cellular, VPN, etc.) using accurate system-level signals.

---

## Features (v0.0.1)

- Detect **all active network interfaces** on the device
- Identify network **type** (Wi-Fi, cellular, VPN, etc.)
- Determine whether a network:
  - Has internet capability
  - Is validated by the system
  - Is metered or unmetered
- Retrieve **upstream and downstream bandwidth estimates**
- Listen to **real-time network changes** via streams
- Native, event-driven implementation (no polling)

---

## Platform Support

| Platform | Support |
|--------|---------|
| Android | ✅ Supported (API 21+) |
| iOS | ⏳ Planned |

---

## Installation

```yaml
dependencies:
  connectivity_control: ^0.0.1
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
ConnectivityControl().listenToActiveNetworks().listen((networks) {
  print(networks);
});
```

---

## NetworkInfo Fields

- `type`
- `hasInternet`
- `isValidated`
- `isMetered`
- `downLinkKbps`
- `upLinkKbps`
