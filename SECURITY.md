# Security and privacy

## Privileged operation

The only administrator command is the literal `/usr/bin/killall -9 BTLEServer`. It is passed to the system AppleScript interpreter using `do shell script ... with administrator privileges`, only after the user presses the repair button. User input and device data are never embedded into this command. macOS handles the credential prompt; the app does not collect or retain credentials.

The app itself runs as a normal user. It is intentionally not App Sandbox-enabled because it invokes system diagnostics and a user-authorized administrator operation. There is no persistent privileged helper or automatic repair. Normal status refreshes are read-only.

BTLEServer handles Bluetooth LE features; it is not a mouse-only service. Other Bluetooth keyboards and devices may also be affected: restarting it can temporarily interrupt connections or operation. Keep a built-in keyboard, trackpad or another way to control the Mac available. macOS controls its relaunch. Successful termination alone is never reported as successful mouse recovery.

## Data handling

No application network requests, uploads, telemetry or analytics are implemented. System diagnostics may briefly include personal device data; subprocess output is held in user-only temporary files (directory mode 0700, files 0600) and removed after the operation. Only mouse display names, connection and battery are retained for the UI. Shareable summaries omit names, addresses, serials and raw logs. The summary clipboard changes only on an explicit button click.

## Distribution

Ad hoc signing is not Developer ID signing or Apple notarization. The public v0.2.0 ZIP is an ad hoc-signed, non-notarized build; Gatekeeper may block a downloaded copy. Do not advise users to disable Gatekeeper or SIP. See `docs/RELEASING.md` for a proper public distribution process.

## Reporting

For non-sensitive bugs, use the repository Issues page. For security issues, use GitHub private vulnerability reporting if enabled; do not disclose an unpatched security issue publicly. Do not put credentials or raw personal diagnostic logs in public issues.

Reference: [AppleScript command reference](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_cmds.html).
