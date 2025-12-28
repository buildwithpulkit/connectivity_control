/// Represents the type of network connection currently in use.
enum NetworkType {
  /// A Virtual Private Network (VPN) connection.
  vpn,

  /// A Wi-Fi network connection.
  wifi,

  /// A wired Ethernet network connection.
  ethernet,

  /// A cellular/mobile data connection (e.g. LTE, 5G).
  cellular,

  /// Any network type that cannot be classified into
  /// the known categories.
  other
}
