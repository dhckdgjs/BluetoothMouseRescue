# Agent handoff

## User intent and boundaries

- User wanted a real Bluetooth repair without rebooting and explicitly rejected USB receivers as a workaround.
- The successful fix was `sudo killall -9 BTLEServer`, not another `bluetoothd` restart.
- This repository turns that one intervention into a transparent native SwiftUI utility.
- The user authorized a public GitHub repository and release, and explicitly chose the MIT license on 2026-10-21. Apple signing/notarization credentials are not available.

## Read first

1. `docs/INCIDENT.md`: observed facts, unsuccessful attempts, successful intervention, limits of the diagnosis.
2. `docs/VALIDATION.md`: distinguish actual command recovery from tests of this new app.
3. `docs/RELEASING.md`: signing, notarization, privacy and release status.

## Structure

- `Sources/RescueCore/Diagnostics.swift`: bounded subprocess execution, private temporary files, Bluetooth report parser, redacted summary, PID verification.
- `Sources/BluetoothMouseRescue/Repair.swift`: the single fixed privileged operation, cancellation handling, relaunch observation.
- `Sources/BluetoothMouseRescue/App.swift`: Korean/English UI, persisted language, one delayed read-only launch recheck, explicit repair button, state display, user confirmation of pointer/scroll operation.
- `Tests/RescueCoreTests/Checks.swift`: standalone Swift checks, usable with Command Line Tools without XCTest.
- `scripts/build.sh`: Universal `.app`, ad hoc or supplied Developer ID signing, ZIP and SHA-256.
- `scripts/icon.swift`: vector-drawn app icon; no external image or asset dependency.

## Invariants

- No repair on launch, refresh, `--diagnose`, CI, or automatic retry.
- No shell interpolation of user/device/network data into the privileged command.
- No password text field, password logging, cached credentials, persistent root helper, launch daemon installation, sudoers edits or protection changes.
- Do not add plist/keychain deletion, blanket Bluetooth unpairing or `bluetoothd` restart to this button.
- Killing the service is not proof of relaunch; relaunch is not proof of mouse connection; connection is not proof of pointer input. Preserve these distinctions.
- A running `BTLEServer` does not prove that it is healthy. An old process alone does not prove a fault.
- The public repository must contain no original MACs, serials, local user names, computer names, raw incident logs or absolute personal workspace paths.
- Do not claim a confirmed deadlock, memory leak, Logitech software conflict or hardware failure. The initiating bug was not determined.

## Develop and verify

```sh
swift run RescueChecks
bash scripts/build.sh
"dist/Bluetooth Mouse Rescue.app/Contents/MacOS/BluetoothMouseRescue" --diagnose
codesign --verify --strict --verbose=2 "dist/Bluetooth Mouse Rescue.app"
lipo -archs "dist/Bluetooth Mouse Rescue.app/Contents/MacOS/BluetoothMouseRescue"
```

Inspect the native UI after changing layout. Test authentication cancellation and actual repair only within the user's authorized test scope, with the effect on Bluetooth input understood. Never equate a mocked repair with a real authenticated repair. Use fake/synthetic data in automated checks. Refresh the validation document when evidence changes.

## Future work

- Test the app's actual authenticated repair flow on a controlled machine (the underlying command is already proven in the incident).
- Test Intel and older supported macOS hardware.
- Test Administrator vs Standard User authorization, cancellation, service missing, Bluetooth off and delayed relaunch.
- Preserve immediate Korean/English switching and persisted selection. Korean is always the first-launch default. Explain BTLEServer as handling Bluetooth LE features, and warn in the UI and README about potential interruptions to other Bluetooth keyboards/devices.
- Public v0.2.0 uses MIT and io.github.dhckdgjs.BluetoothMouseRescue. It is ad hoc signed and must clearly disclose that it is not notarized. Future Developer ID releases need signing, notarization and a downloaded-copy test.
