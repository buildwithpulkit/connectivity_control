# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture

The plugin follows Flutter's **platform interface pattern**:

1. **Public API** (`lib/connectivity_control.dart`) — `ConnectivityControl` facade; delegates to `ConnectivityControlPlatform.instance`
2. **Platform Interface** (`lib/src/platform_interface/`) — Abstract `ConnectivityControlPlatform extends PlatformInterface` using the token pattern; defaults to the method channel impl
3. **Method Channel Impl** (`lib/src/method_channel/`) — Concrete implementation using:
   - `'connectivity_control/methods'` for `getActiveNetworks()`
   - `'connectivity_control/events'` for the live stream
4. **Models** (`lib/src/core/`) — `NetworkInfo` (data model) and `NetworkType` enum

Android supports all `NetworkInfo` fields. iOS supports all fields except `downLinkKbps`/`upLinkKbps` (no API) and VPN type detection (platform limitation). `ConnectivityControl` is a singleton accessed via `ConnectivityControl()` factory constructor.

## Git workflow

- **Before committing,** create a branch for the work. Don't commit straight to `production`.
- **Branch name:** `<type>/<short-kebab-title>`, where `<type>` is the Conventional Commits type for the change:
  - bug fix → `fix/<short-kebab-title>`
  - new feature → `feat/<short-kebab-title>`
  - other work uses the closest type: `chore`, `refactor`, `perf`, `docs`, `test`, `ci`. An enhancement that changes behavior is `feat`; a cleanup with no behavior change is `refactor` or `chore`.
- **Commit message:** Conventional Commits message, e.g. `fix(auth): handle expired session token`.

## Testing Conventions

Tests live in `test/`. Each layer has its own test file. Mocks are created by subclassing `ConnectivityControlPlatform` directly — no external mocking libraries are used. The `analysis_options.yaml` enforces `public_member_api_docs: true`, so all public APIs must have dartdoc comments.
