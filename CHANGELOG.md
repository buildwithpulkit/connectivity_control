## 0.0.2

### Added
- Initial iOS platform support.
- iOS implementation of `getActiveNetworks`, enabling retrieval of currently active network interfaces on iOS devices.

### Notes
- This release intentionally exposes **only** the `getActiveNetworks` API on iOS.

### Platform Support
- **Android**: Full implementation using modern `ConnectivityManager` APIs.
- **iOS**: Partial implementation focused on active network discovery, designed to maintain Dart API consistency and enable future feature parity.

---

## 0.0.1

### Added
- Detect all active network interfaces (Wi-Fi, cellular, VPN) on the device.
- Real-time stream of active network changes.
- Per-network metadata including:
  - Internet capability
  - Validation status
  - Metered / unmetered state
  - Upstream and downstream bandwidth estimates.

### Platform Support
- Android implementation using modern `ConnectivityManager` APIs.
- Flutter API designed for extensibility and future platform parity.