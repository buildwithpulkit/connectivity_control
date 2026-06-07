# macOS Platform Support — Design Overview

This document records every design decision made before implementing macOS support for the `connectivity_control` plugin, and the reasoning behind each choice.

---

## 1. Code Structure — Separate `macos/` Directory

**Decision:** macOS native code lives in a dedicated `macos/` directory, mirroring the existing `ios/` layout. No source files are shared between the two platforms.

**Why:** The iOS and macOS implementations differ by only a single import line (`import Flutter` vs `import FlutterMacOS`) and a registrar call, but Flutter's platform plugin convention expects one directory per platform. Sharing sources across platforms (e.g. via a top-level `darwin/` Swift package) would require non-standard build system wiring, complicates tooling, and adds complexity that isn't justified for three small Swift files. The duplication is minimal and easy to reason about.

---

## 2. Minimum Deployment Target — macOS 10.15 (Catalina)

**Decision:** The minimum macOS deployment target is **10.15 (Catalina)**.

**Why:** `NWPathMonitor` — the entire basis of this plugin — was introduced in macOS 10.14 (Mojave), which is also Flutter's own minimum. However, macOS 10.15 adds `NWPath.isConstrained`, which reflects the user's Low Data Mode preference. This flag is directly relevant to the `isMetered` field and was the primary reason for choosing 10.15 over 10.14. macOS 10.14 market share is negligible today, so the compatibility tradeoff is negligible.

---

## 3. Build System — Both CocoaPods and Swift Package Manager

**Decision:** The macOS target ships both a `macos/connectivity_control.podspec` (CocoaPods) and a `macos/connectivity_control/Package.swift` (SPM), mirroring the iOS side exactly.

**Why:** Consistency with the iOS platform. A consumer using CocoaPods to integrate the iOS plugin almost certainly needs the macOS podspec too. A plugin that behaves differently across its own platforms — supporting both build systems on iOS but only one on macOS — creates unnecessary friction. The maintenance overhead of two files is low.

---

## 4. `isMetered` Mapping — `isExpensive || isConstrained`

**Decision:** On macOS, `isMetered` maps to `path.isExpensive || path.isConstrained`.

**Why:** iOS maps `isMetered` to `isExpensive` alone (cellular, personal hotspot) because `isConstrained` is less meaningful on mobile. On macOS, a user who has enabled Low Data Mode in System Preferences (`isConstrained`) is explicitly signalling "treat this as a metered connection" — which is exactly what the `isMetered` field communicates to consumers. Using both flags gives a more semantically correct result on macOS. This is also the reason we chose macOS 10.15 as the deployment floor (10.14 lacks `isConstrained`).

---

## 5. VPN Detection — Not Supported

**Decision:** The macOS implementation does not detect or report `NetworkType.vpn`.

**Why:** `NWPathMonitor` does not expose a `.vpn` interface type on any Apple platform. The only workaround on macOS is to heuristically match interface names like `utun*` or `ppp*` in `path.availableInterfaces`. This approach is fragile — Apple does not document these names as stable, a future macOS release could change them silently, and some non-VPN interfaces could match. Shipping a heuristic that can return wrong data without any indication of failure is worse than documenting the limitation. VPN detection is omitted on macOS for the same reason it is omitted on iOS.

---

## 6. `downLinkKbps` / `upLinkKbps` — Always `nil`

**Decision:** Both bandwidth fields return `nil` on macOS.

**Why:** `NWPath` exposes no bandwidth estimation API on any Apple platform (iOS or macOS). There is no alternative macOS API that provides per-interface bandwidth in a way that maps cleanly to the plugin's model. This matches iOS behaviour exactly.

---

## 7. Cellular Interface — Excluded from Mapper

**Decision:** The macOS `NetworkInformationMapper` does not check `path.usesInterfaceType(.cellular)`.

**Why:** No Mac hardware has a built-in cellular radio. USB tethering to an iPhone presents as `wiredEthernet` or `other`, not `.cellular`. Including the cellular check would be dead code that is semantically misleading to anyone reading the macOS implementation. It is omitted to keep the mapper honest about what macOS actually supports.

---

## 8. Example App — macOS Target Added

**Decision:** The `example/` app is updated to support macOS.

**Why:** The example app serves as both a reference implementation for consumers and a smoke-test harness for the plugin author. Without a runnable macOS target, the end-to-end wiring (pubspec registration → method channel → native Swift code) can only be verified by building from scratch. Adding the macOS target takes minimal effort and makes manual validation straightforward. It also signals to `pub.dev` and consumers that macOS is a first-class target.

---

## 9. CI — macOS Build Job Added

**Decision:** A new `build-macos` job is added to `ci.yml`, running on `macos-latest`, which executes `flutter build macos` inside `example/`.

**Why:** The existing CI jobs run on `ubuntu-latest` and cover Dart-level concerns (analysis, formatting, unit tests, publish dry-run). They cannot compile Swift or invoke the macOS toolchain. A CI pipeline that cannot catch a Swift compilation error or a broken plugin registration provides no protection for the macOS platform. The `macos-latest` runner is slower and costs more GitHub Actions minutes, but the risk of shipping a broken native implementation without a build gate outweighs the cost.
