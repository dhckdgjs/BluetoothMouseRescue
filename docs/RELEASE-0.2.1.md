## Bluetooth Mouse Rescue v0.2.1

### 한국어

- 정상 작동 자기 확인 체크박스를 제거하고 **앱 닫기** 버튼으로 교체했습니다. 조회나 복구 중에는 종료 버튼이 비활성화됩니다.
- 한국어가 기본이며 한국어 / English 선택은 즉시 적용되고 다음 실행에도 유지됩니다.
- 첫 조회 완료 2초 뒤 연결 상태를 자동으로 한 번 더 확인합니다. 자동 복구는 하지 않습니다.
- 앱과 README에 `BTLEServer`가 Bluetooth LE 기능을 처리하는 프로세스임을 명시하고, 다른 Bluetooth 키보드·기기도 연결 또는 작동이 일시 중단될 수 있음을 안내합니다.
- README에 MX Anywhere 3S의 심한 증상 사례, 재부팅의 일시적 효과, 재페어링의 무효과, 전체 기기 삭제·plist 초기화의 불편함, 서비스 재시작으로 복구된 결과를 정리했습니다.
- MIT 라이선스. Apple Silicon + Intel Universal, macOS 13+ 빌드 대상.

**다운로드:** `Bluetooth-Mouse-Rescue-0.2.1.zip`과 검증용 `Bluetooth-Mouse-Rescue-0.2.1-SHA256SUMS.txt`.

**배포 제한:** ad hoc 서명이며 Developer ID 서명·Apple 공증은 없습니다. 다른 Mac에서 Gatekeeper가 차단할 수 있습니다. Intel 실기기, 모든 지원 대상 macOS, 다른 Mac 최초 실행 및 앱의 실제 관리자 인증 복구는 미검증입니다.

### English

- Replace the self-reported operation checkbox with **Quit app**, disabled during a status check or repair.
- Korean by default; immediate Korean/English switching with a saved preference.
- One automatic status recheck two seconds after the first read finishes; no automatic repair.
- Explain the Bluetooth LE scope of `BTLEServer` and warn in both the app and README about possible interruptions to other Bluetooth keyboards/devices.
- Document the MX Anywhere 3S incident, temporary benefit from rebooting, ineffective re-pairing, inconvenience of broad resets and successful targeted service restart.
- MIT license; Universal arm64 + x86_64; macOS 13+ deployment target.

**Ad hoc signed; no Developer ID signature or Apple notarization.** Gatekeeper may block the download. Intel hardware, all targeted macOS versions, first launch on another Mac and the app's authenticated repair flow remain unverified.
