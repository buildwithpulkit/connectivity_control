# connectivity_control

A Flutter plugin that provides **low-level, system-driven visibility into active network interfaces** on a device.

Unlike basic connectivity checks, this plugin is designed to help apps **understand, observe, and reason about multiple simultaneous networks** (Wi-Fi, cellular, VPN, etc.) using native platform signals.

---

## Features

### Android (Full Support)
- Detect **all active network interfaces**
- Identify network **type** (Wi-Fi, cellular, VPN, etc.)
- Determine whether a network:
  - Has internet capability
  - Is validated by the system
  - Is metered or unmetered
- Retrieve **upstream and downstream bandwidth estimates**
- Listen to **real-time network changes** via streams
- Native, event-driven implementation (no polling)

### iOS (Partial Support)
- Retrieve **currently active network interfaces** via `getActiveNetworks`

> ⚠️ Advanced network metadata and real-time streams are **Android-only** for now and will be introduced on iOS incrementally.

---

## Platform Support

| Platform | Support |
|--------|---------|
| Android | ✅ Full support (API 23+) |
| iOS | ⚠️ Partial support (`getActiveNetworks` only) |

---

## Installation

```yaml
dependencies:
  connectivity_control: ^0.0.2
```

```bash
flutter pub get
```

---

## How to Use

```dart
import 'package:connectivity_control/connectivity_control.dart';
```

### Get Active Networks (Android & iOS)

```dart
final networks = await ConnectivityControl().getActiveNetworks();
print(networks);
```

> On iOS, this is currently the **only supported API**.

### Listen to Network Changes (Android only)

```dart
ConnectivityControl().listenToActiveNetworks().listen((networks) {
  print(networks);
});
```

---

## NetworkInfo Fields

> ⚠️ Field availability depends on platform.

### Android
- `type`
- `hasInternet`
- `isValidated`
- `isMetered`
- `downLinkKbps`
- `upLinkKbps`

### iOS
- `type`
- `hasInternet`
- `isValidated` - always **null** due to platform limitations.
- `isMetered` - always **null** due to platform limitations.
- `downLinkKbps` - always **null** due to platform limitations.
- `upLinkKbps` - always **null** due to platform limitations.
