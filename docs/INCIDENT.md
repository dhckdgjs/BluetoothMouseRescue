# Incident: paired BLE mouse does not become a usable input device

Date: 2026-10-21 (Asia/Seoul). Host: Apple Silicon MacBook Pro, macOS 26.6.2. Device identified by the system: Logitech MX Anywhere 3S (initially described by the user as MX Anywhere 3).

## Plain-language explanation

맥이 마우스와 BLE 통신은 할 수 있었지만 실제 입력은 되지 않았습니다. Bluetooth LE 기능을 처리하는 BTLEServer를 재시작하자 복구됐습니다. BTLEServer는 마우스 전용 서비스가 아니며 다른 Bluetooth 키보드와 기기도 영향을 받을 수 있습니다.

## Service scope

The Apple-supplied macOS manual (`man BTLEServer`, `/usr/share/man/man1/BTLEServer.1`) describes the process as handling Bluetooth LE features. The scope is broader than mouse input. The observations below narrow this incident to BLE/HID state; they do not define the full service implementation or imply that every Bluetooth connection is managed by BTLEServer. Restarting it may temporarily interrupt other Bluetooth keyboards and devices.

## Observed symptoms

- A previously working mouse stopped working unexpectedly.
- Forget/re-pair failed; the device was visible but Connect could disappear or pairing would not complete.
- Another mouse of the same model, known to work on another Mac, showed the same symptoms on this host.
- Bluetooth scanning still worked and the mouse signal was strong.
- `bluetoothd` restarts, radio off/on, different channels, user-side Bluetooth service restart, settings relaunch and a temporary Handoff test did not restore normal operation.
- A direct CoreBluetooth diagnostic established a BLE link. Reading the protected battery characteristic triggered the native pairing dialog. Accepting the dialog produced `Pairing succeeded`, encryption enabled, and a successful battery read.
- That temporary diagnostic connection was not a usable, persistent mouse connection; after the diagnostic ended, the mouse was disconnected. This distinction corrected an earlier overly broad interpretation of “Connected”.

## Additional user-reported experience

The user describes the symptoms as severe with the Logitech MX Anywhere 3S. Rebooting provided only temporary relief; pairing again and forgetting/re-pairing the mouse did not resolve the recurring problem. Deleting every Bluetooth device or resetting preference plists would impose an inconvenient reconfiguration burden, so broad resets are deliberately excluded from this app. These are the user's reported observations and preferences, not a controlled comparison across all Macs or MX Anywhere 3S units.

## Evidence that narrowed the issue

The IORegistry showed an old MX Anywhere input-device entry for a different channel address. Its owner was `BTLEServer`, a separate root-owned process that had not restarted with `bluetoothd`. The service label was `com.apple.BTServer.le`, with executable `/usr/sbin/BTLEServer`.

Read-only checks used:

```sh
ps -axo pid,lstart,command
launchctl print system/com.apple.BTServer.le
hidutil list --matching '{"VendorID":1133}'
ioreg -a -r -c IOHIDResource -l
system_profiler SPBluetoothDataType -json
```

Raw outputs are intentionally not stored in this public-ready repository. They can contain personal device names, addresses and serial numbers.

## Successful intervention

With the mouse kept on its selected channel and its pairing retained, the user ran:

```sh
sudo killall -9 BTLEServer
```

The service restarted automatically. Verification immediately afterward showed:

- a new `BTLEServer` process starting at 09:17:29;
- MX Anywhere 3S under Connected, battery 100%;
- a new Bluetooth Low Energy HID input-device/service registration;
- the user's confirmation that the mouse worked.

No Mac reboot or USB receiver was used. No Bluetooth database/keychain deletion was required. Handoff was restored after the earlier test. The temporary third-party CLI used during diagnosis was uninstalled. The one-off CoreBluetooth program was stopped; it is not part of this app and does not need to remain running.

## Confidence and limitations

The evidence strongly supports a stale or unresponsive BLE input-service state as the failure point. The service's exact internal defect was not established: no privileged stack sample or root-cause analysis of Apple code was performed. Do not call it a proven deadlock, memory leak, hardware failure, or Logitech Options conflict.

If the symptom returns, inspect the current service and connection state before reusing the targeted restart. Do not repeat all the unsuccessful diagnosis steps first. Do not automatically unpair a mouse that already has valid pairing keys.

The original command recovered this host. The app is a newly authored wrapper around that command; its separate validation status is in `VALIDATION.md`.
