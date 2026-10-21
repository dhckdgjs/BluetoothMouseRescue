# Validation record

Date: 2026-10-21 (Asia/Seoul). Release: v0.2.0.

## Incident evidence versus app testing

The prior incident record reports recovery after the user executed `sudo killall -9 BTLEServer`: a new process, connected MX Anywhere 3S, HID registration and user-confirmed pointer operation. That is evidence for the intervention on that host, not proof of every path in this app or a permanent fix.

## v0.2.0 checks performed

- Build environment: Apple Silicon, macOS 26.7.1, Swift 6.4, macOS SDK 27.0. Deployment target: macOS 13.0.
- `swift run RescueChecks`: 11 groups passed. Coverage includes report filtering/privacy; off/unknown/malformed reports; optional battery; PID replacement; subprocess output/nonzero status/timeout; exactly one delayed startup recheck; no duplicate startup reads; a user action superseding the recheck; cancellation; a synthetic disconnected report followed by a fresh connected report; Korean default and all 43 English translations.
- The checks run as a standalone executable because the original Command Line Tools environment lacked XCTest. This is not an XCTest result.
- Universal release build completed with isolated SwiftPM scratch paths for arm64 and x86_64. This also fixes overlapping architecture output paths with the current Swift build engine.
- Built-app `--diagnose`: exit 0, Bluetooth on, BTLEServer running, one listed/connected mouse and complete diagnostics. No device names, addresses or serials in the summary.
- `lipo -archs`: arm64 and x86_64. Bundle plist and shell syntax checks passed. Strict code-signature verification passed for the ad hoc signature.
- Native UI inspected in Korean and English: immediate label, connection status, explanatory text, warning and window-title updates; no observed clipping. The warning above the repair button explicitly includes other Bluetooth keyboards/devices and temporary loss of connection or operation.
- Language persistence was verified by selecting English, quitting and reopening the app; English remained selected. The UI was then returned to Korean.
- Launch UI showed the pending automatic recheck, then the completed state with the mouse connected. The initial-disconnected-to-connected transition was tested using synthetic reports; it was not reproduced on a second physical Mac.
- No repair button was pressed during these read-only checks. Bluetooth services and pairing were not intentionally changed.
- Release ZIP checksum verified; source/binary scans checked for personal home/workspace paths, credentials and raw identifiers before publication.

## Not yet verified

- A real administrator-authenticated repair through v0.2.0, administrator-prompt cancellation end-to-end, or Standard User authentication.
- Intel hardware, every macOS version from 13 onward, multiple BLE accessories or first launch on a different Mac.
- Developer ID signing, Apple notarization or downloaded/quarantined-app behavior on a clean Mac.
- The initiating Apple service defect, long-term recurrence or a permanent fix.
