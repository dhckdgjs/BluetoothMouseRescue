#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p dist
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Resources/Info.plist)
APP="dist/Bluetooth Mouse Rescue.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
bins=()
for arch in ${ARCHS:-arm64 x86_64}; do
  triple="$arch-apple-macosx13.0"
  swift build -c release --product BluetoothMouseRescue --triple "$triple" --scratch-path ".build/release-$arch"
  bindir=$(swift build -c release --product BluetoothMouseRescue --triple "$triple" --scratch-path ".build/release-$arch" --show-bin-path)
  bins+=("$bindir/BluetoothMouseRescue")
done
if [ "${#bins[@]}" -gt 1 ]; then
  /usr/bin/lipo -create "${bins[@]}" -output "$APP/Contents/MacOS/BluetoothMouseRescue"
else
  cp "${bins[0]}" "$APP/Contents/MacOS/BluetoothMouseRescue"
fi
# Do not ship debug-map entries containing the build machine's home directory.
/usr/bin/strip -S "$APP/Contents/MacOS/BluetoothMouseRescue"
cp Resources/Info.plist "$APP/Contents/Info.plist"
cp LICENSE "$APP/Contents/Resources/LICENSE.txt"
swift scripts/icon.swift .build/AppIcon.iconset
/usr/bin/iconutil -c icns .build/AppIcon.iconset -o "$APP/Contents/Resources/AppIcon.icns"
if [ -n "${SIGNING_IDENTITY:-}" ]; then
  /usr/bin/codesign --force --options runtime --timestamp --sign "$SIGNING_IDENTITY" "$APP"
else
  /usr/bin/codesign --force --sign - "$APP"
fi
/usr/bin/codesign --verify --strict --verbose=2 "$APP"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$APP" "dist/Bluetooth-Mouse-Rescue-${VERSION}.zip"
(cd dist && /usr/bin/shasum -a 256 "Bluetooth-Mouse-Rescue-${VERSION}.zip" > "Bluetooth-Mouse-Rescue-${VERSION}-SHA256SUMS.txt")
echo "Built: $APP"
