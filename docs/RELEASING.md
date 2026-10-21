# Preparing a GitHub release

## Current state

- Public repository: https://github.com/dhckdgjs/BluetoothMouseRescue
- Version: 0.2.1. Bundle identifier: `io.github.dhckdgjs.BluetoothMouseRescue`.
- MIT license explicitly selected by the maintainer on 2026-10-21.
- No valid Developer ID signing identity is installed on the build machine. The v0.2.1 release uses ad hoc signing and is not notarized. Gatekeeper may block a downloaded copy.

## Build and validate

```sh
swift run RescueChecks
bash scripts/build.sh
codesign --verify --strict --verbose=2 "dist/Bluetooth Mouse Rescue.app"
lipo -archs "dist/Bluetooth Mouse Rescue.app/Contents/MacOS/BluetoothMouseRescue"
"dist/Bluetooth Mouse Rescue.app/Contents/MacOS/BluetoothMouseRescue" --diagnose
```

`scripts/build.sh` creates a Universal app, ZIP and checksum. `.github/workflows/build.yml` repeats read-only checks and creates an artifact on pushes/PRs after publication. That workflow does **not** notarize or publish Releases.

## Developer ID signing and notarization

The maintainer must own an Apple Developer ID Application certificate and configure notarization credentials locally. Do not commit credentials, signing certificates or passwords.

```sh
SIGNING_IDENTITY='Developer ID Application: YOUR ACTUAL IDENTITY' bash scripts/build.sh
xcrun notarytool submit dist/Bluetooth-Mouse-Rescue-0.2.1.zip \
  --keychain-profile YOUR_LOCAL_NOTARY_PROFILE --wait
xcrun stapler staple "dist/Bluetooth Mouse Rescue.app"
xcrun stapler validate "dist/Bluetooth Mouse Rescue.app"
codesign --verify --strict --verbose=2 "dist/Bluetooth Mouse Rescue.app"
spctl --assess --type execute --verbose=2 "dist/Bluetooth Mouse Rescue.app"
ditto -c -k --sequesterRsrc --keepParent "dist/Bluetooth Mouse Rescue.app" dist/Bluetooth-Mouse-Rescue-0.2.1.zip
shasum -a 256 dist/Bluetooth-Mouse-Rescue-0.2.1.zip > dist/Bluetooth-Mouse-Rescue-0.2.1-SHA256SUMS.txt
```

These are templates, not a claim that signing or notarization has happened. Submit only after the user authorizes publication/upload. Inspect the notary log if any step fails. Rebuild/re-sign after source or plist changes; regenerate the ZIP after stapling. Test a downloaded copy on a different Mac, not just the development checkout.

Apple references: [Developer ID](https://developer.apple.com/developer-id/) · [Notarization](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution).

## GitHub publication

Publication of the public repository and release was explicitly requested by the user. Keep `dist/` and `.build/` out of source control. Attach only the versioned app ZIP and its matching SHA-256 file to the release. The README and release notes must retain the signing and hardware-verification limitations until those checks actually happen.

Build artifacts must not overwrite each other's architecture outputs: `scripts/build.sh` gives arm64 and x86_64 separate SwiftPM scratch paths, then merges their binaries. Versioned ZIP/checksum files preserve previous releases.

Before upload, inspect source and packaged assets for private device identifiers, raw logs, credentials and local user/workspace paths. Automated fixtures must be synthetic. Enable GitHub private vulnerability reporting for sensitive security reports.
