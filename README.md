# Bluetooth Mouse Rescue

[한국어](#한국어) · [English](#english) · [다운로드 / Download](https://github.com/dhckdgjs/BluetoothMouseRescue/releases/latest)

Bluetooth 마우스가 보이지만 연결·입력이 되지 않을 때, macOS의 `BTLEServer`만 재시작하는 작은 SwiftUI 앱입니다.

**한국어 / English 전환 · macOS 13+ 빌드 대상 · Apple Silicon + Intel Universal · MIT 라이선스**

## 한국어

### 증상과 원인 파악

이 앱은 **Logitech MX Anywhere 3S에서 연결 불량 증상을 심하게 겪은 실제 사용 사례**에서 만들었습니다. 이 설명은 해당 사용자·Mac의 경험이며, 모든 MX Anywhere 3S의 결함이나 발생 빈도를 입증하는 것은 아닙니다.

- 잘 쓰던 마우스가 갑자기 연결되지 않거나, 기기는 검색되지만 연결·페어링이 끝나지 않았습니다.
- 사용자 경험상 **재부팅은 잠시만 효과가 있었고**, 다시 문제가 생겼습니다.
- **다시 페어링하거나 기기를 지운 뒤 재페어링해도 해결되지 않았습니다.**
- `bluetoothd` 재시작, Bluetooth 껐다 켜기, 채널 변경도 해당 진단에서는 효과가 없었습니다.
- **모든 Bluetooth 기기 삭제나 plist 초기화는 다른 기기까지 다시 설정해야 하는 부담이 커서 너무 불편합니다.** 이 앱은 이러한 전체 초기화를 하지 않습니다.

진단에서는 BLE 통신·보호된 배터리 읽기·페어링은 가능했지만 실제 마우스 입력으로 이어지지 않았습니다. `bluetoothd`와 별도로 남아 있던 `BTLEServer`의 오래된 입력 장치 등록이 확인되어, `BTLEServer`와 관련된 BLE/HID 처리 상태 문제로 범위를 좁혔습니다. **정확한 내부 결함·교착·메모리 누수·Logitech 소프트웨어 충돌은 확정하지 않았습니다.**

### BTLEServer는 무엇인가요?

macOS에 포함된 `man BTLEServer`는 이를 **Bluetooth LE 기능을 처리하는 프로세스**로 설명합니다. 마우스 전용 서비스나 모든 Bluetooth 연결을 총괄하는 서비스로 단정해서는 안 됩니다. 이 사례에서는 그중 마우스의 BLE/HID 처리와 관련된 상태가 관찰됐습니다.

### 적용한 해결법과 결과

페어링과 채널을 유지한 상태에서 다음 한 가지 작업만 수행하자, 새 서비스 프로세스와 연결된 마우스가 확인됐고 사용자가 실제 포인터 작동을 확인했습니다.

```sh
sudo killall -9 BTLEServer
```

앱은 복구 버튼을 눌렀을 때만 macOS 관리자 인증으로 이 고정 명령을 실행합니다. 재실행은 macOS가 관리합니다. **재부팅, USB 수신기, 기기 전체 삭제, plist·키체인 초기화 없이 해당 사례가 복구**됐습니다. 영구 해결이나 모든 Bluetooth 문제 해결을 보장하지는 않습니다. [상세 사례 기록](docs/INCIDENT.md)

### 사용 방법

1. [최신 릴리스](https://github.com/dhckdgjs/BluetoothMouseRescue/releases/latest)의 ZIP을 풀고 앱을 실행합니다.
2. 화면 위에서 **한국어 / English**를 선택합니다. 즉시 적용되고 다음 실행에도 유지됩니다. **최초 기본 언어는 시스템 언어와 관계없이 한국어**입니다.
3. 실행 직후 상태를 읽고, **첫 조회 완료 2초 뒤 한 번 더 자동으로 상태를 확인**합니다. 다른 Mac의 첫 실행에서 연결 표시가 늦게 반영되는 경우를 고려한 재조회입니다. 자동 복구·자동 인증은 하지 않습니다.
4. `연결됨`으로 표시되면 포인터·스크롤을 직접 시험합니다. 정상이라면 복구 버튼을 누를 필요가 없습니다.
5. 문제가 계속되면 **마우스 연결 복구**를 누르고 macOS 관리자 인증을 완료합니다. 필요하면 같은 채널에서 마우스를 껐다 켠 뒤 **상태 다시 확인**을 누릅니다.

자동 재확인을 기다리는 동안 직접 상태 확인이나 복구를 시작하면 그 작업을 우선하고 예약된 재확인은 생략합니다. 페어링 여부만으로 연결됨을 표시하지 않으며, 실제 시스템 조회 결과를 사용합니다. **서비스 재시작 / Bluetooth 연결 / 실제 포인터·스크롤 작동은 별도로 확인**합니다.

**다른 Bluetooth 키보드와 기기도 영향을 받아 일시적으로 연결이 끊기거나 작동이 중단될 수 있습니다.** 복구 전에 내장 키보드·트랙패드 등 다른 조작 수단을 확보하세요. 앱을 계속 켜 둘 필요는 없으며 상주 도우미나 자동 실행 항목을 설치하지 않습니다.

### 배포와 검증 범위

현재 **v0.2.0은 ad hoc 서명된 미공증 빌드**입니다. Developer ID 서명과 Apple 공증은 없어 다른 Mac에서 Gatekeeper가 실행을 차단하거나 별도 실행 승인을 요구할 수 있습니다. macOS 보안 기능을 끄는 방식은 권장하지 않습니다.

Apple Silicon에서 빌드·진단·UI를 확인했습니다. Intel 바이너리는 크로스 빌드했으며 Intel 실기기, macOS 13 이상 모든 버전, 다른 Mac의 최초 실행 문제 해소는 아직 실기기 검증하지 않았습니다. 기존 명령의 복구 성공과 앱 내부 관리자 인증을 통한 복구 검증은 구분합니다. [검증 기록](docs/VALIDATION.md)

## English

### Why this exists

This app grew out of a user's **severe recurring connection problems with a Logitech MX Anywhere 3S**. This is an account of that user's Mac and devices, not evidence of a defect or failure rate across all units.

The mouse was discoverable but would not become a usable input device. The user reports that **rebooting helped only temporarily**, and **pairing again, including forgetting the device and re-pairing, did not resolve the problem**. Restarting `bluetoothd`, toggling Bluetooth and changing channels also failed during diagnosis. Deleting every Bluetooth device or resetting preference plists is inconvenient because of the setup it disrupts; this app avoids those broad resets.

BLE communication, pairing and a protected battery read succeeded while mouse input did not. An old input-device registration remained under the separate `BTLEServer` process. Restarting that service restored the connection and the user confirmed mouse operation. The exact underlying Apple bug was not established, and this is not a guaranteed permanent fix. [Incident details](docs/INCIDENT.md)

The macOS `man BTLEServer` manual describes it as a process handling Bluetooth LE features. It is not a mouse-only service, and this app does not claim it manages every Bluetooth connection. The incident specifically involved observed BLE/HID mouse behavior.

### Use

1. Download the ZIP from [Releases](https://github.com/dhckdgjs/BluetoothMouseRescue/releases/latest), extract it and open the app.
2. Select **한국어 / English** at the top. The choice applies immediately and persists between launches. **The first-launch default is Korean, regardless of the system language.**
3. The app reads status, then **automatically reads it once more two seconds after the first check finishes**. This accommodates a connection report that may arrive late on another Mac. It never repairs automatically. A manual refresh or repair supersedes the delayed read.
4. If the mouse is connected, test the pointer and scrolling. Otherwise, use **Repair connection** and authenticate through macOS when the problem persists.

The only privileged operation is `/usr/bin/killall -9 BTLEServer`. macOS manages the service's relaunch. Pairing data is preserved. **Other Bluetooth keyboards and devices may also be affected: connections or operation may be interrupted temporarily.** Have a built-in keyboard, trackpad or another way to control your Mac available before repairing. Service restart, Bluetooth connection and working pointer input are separate confirmations.

**v0.2.0 is ad hoc signed, without Developer ID signing or Apple notarization.** Gatekeeper may block a downloaded copy. The app targets macOS 13+ and includes arm64 and x86_64; Intel hardware, all older macOS versions and first launch on another Mac remain unverified. See [validation](docs/VALIDATION.md) and [release guidance](docs/RELEASING.md).

## Build from source / 소스 빌드

Requires macOS and Xcode or Command Line Tools with Swift 5.9+. Run:

```sh
swift run RescueChecks
bash scripts/build.sh
```

Outputs:

```text
dist/Bluetooth Mouse Rescue.app
dist/Bluetooth-Mouse-Rescue-0.2.0.zip
dist/Bluetooth-Mouse-Rescue-0.2.0-SHA256SUMS.txt
```

Default: Universal arm64 + x86_64. For arm64 only: `ARCHS=arm64 bash scripts/build.sh`.

Read-only diagnostics (no administrator prompt or repair):

```sh
"dist/Bluetooth Mouse Rescue.app/Contents/MacOS/BluetoothMouseRescue" --diagnose
```

## Privacy and license / 개인정보·라이선스

No app network requests, analytics, password collection or persistent root helper. The UI displays mouse names, connection and battery. Copied diagnostics omit names, MAC addresses, serial numbers and raw logs; their stable technical format is English in both UI languages. The clipboard changes only when **Copy diagnostics / 진단 요약 복사** is clicked. [Security and privacy](SECURITY.md)

[MIT License](LICENSE) · [Changes in v0.2.0](docs/RELEASE-0.2.0.md)
