## 1.1.0

### Added
- **macOS support** (macOS 10.15+) via `NWPathMonitor` from the `Network` framework.
- macOS ships both CocoaPods (`macos/connectivity_control.podspec`) and Swift Package Manager (`macos/connectivity_control/Package.swift`) support, matching the iOS side.
- CI: new `build-macos` job on `macos-latest` that runs `flutter build macos` on the example app to guard against native compilation regressions.

### Platform Notes
- **macOS**: `type` reports wifi, ethernet, and other. Cellular and VPN are not reported (platform limitation — `NWPathMonitor` exposes no VPN interface type, and no Mac hardware has a cellular radio).
- **macOS `isMetered`**: mapped to `NWPath.isExpensive || NWPath.isConstrained` — covers both shared connections (e.g. iPhone tethering) and user-enabled Low Data Mode.
- **macOS bandwidth**: `downLinkKbps` and `upLinkKbps` are always `null` (no macOS API available).

---

## 1.0.0

### Changed
- **BREAKING**: `listenToActiveNetworks()` renamed to `onActiveNetworksChanged` stream getter.
- Exported `NetworkInfo` and `NetworkType` from the barrel file — single import gives access to all public types.
- Added `topics` and `issue_tracker` to pubspec for pub.dev discoverability.

### Platform Support
- **Android**: Full support (API 24+).
- **iOS**: Full support (iOS 13+). `downLinkKbps`/`upLinkKbps` unavailable (no iOS API). VPN not reported as a separate type (platform limitation).

---

## 0.0.4

### Added
- Real-time network change stream (`listenToActiveNetworks`) on iOS via `NWPathMonitor`.
- `isMetered` field on iOS, mapped from `NWPath.isExpensive`.
- `isValidated` field on iOS, mapped from `NWPath.status == .satisfied`.
- Proper resource cleanup on iOS via `detachFromEngine`.

### Changed
- Updated README to reflect full iOS platform support.

### Platform Support
- **Android**: Full implementation (unchanged).
- **iOS**: Full implementation — both `getActiveNetworks` and `listenToActiveNetworks` now supported with `isMetered` and `isValidated` fields populated. `downLinkKbps`/`upLinkKbps` remain unavailable (no iOS API). VPN not reported as a separate type (platform limitation).

---

## 0.0.3

### Added
- Swift Package Manager (SPM) support for iOS.

### Changed
- Migrated iOS source files to SPM-compatible directory structure.
- Updated podspec to reference new source paths while maintaining CocoaPods compatibility.

---

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