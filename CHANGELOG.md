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