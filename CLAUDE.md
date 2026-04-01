# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

`connectivity_control` is a Flutter plugin that provides low-level, system-driven visibility into active network interfaces. It exposes two APIs:
- `getActiveNetworks()` — one-time query returning `List<NetworkInfo>`
- `listenToActiveNetworks()` — real-time `Stream<List<NetworkInfo>>`

## Commands

```bash
# Install dependencies
flutter pub get

# Run all tests
flutter test

# Run a single test file
flutter test test/network_info_test.dart

# Run a specific test by name
flutter test test/network_info_test.dart -n "creates instance with required type only"

# Lint
flutter analyze

# Format
flutter format .
```

## Architecture

The plugin follows Flutter's **platform interface pattern**:

1. **Public API** (`lib/connectivity_control.dart`) — `ConnectivityControl` facade; delegates to `ConnectivityControlPlatform.instance`
2. **Platform Interface** (`lib/src/platform_interface/`) — Abstract `ConnectivityControlPlatform extends PlatformInterface` using the token pattern; defaults to the method channel impl
3. **Method Channel Impl** (`lib/src/method_channel/`) — Concrete implementation using:
   - `'connectivity_control/methods'` for `getActiveNetworks()`
   - `'connectivity_control/events'` for the live stream
4. **Models** (`lib/src/core/`) — `NetworkInfo` (data model) and `NetworkType` enum

Android supports all `NetworkInfo` fields. iOS currently only supports `getActiveNetworks()` and returns partial metadata.

## Testing Conventions

Tests live in `test/`. Each layer has its own test file. Mocks are created by subclassing `ConnectivityControlPlatform` directly — no external mocking libraries are used. The `analysis_options.yaml` enforces `public_member_api_docs: true`, so all public APIs must have dartdoc comments.
