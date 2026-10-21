## Bluetooth Mouse Rescue v0.2.0

### 한국어

- 기본 언어는 시스템 언어와 관계없이 한국어입니다. 화면에서 한국어 / English를 즉시 선택하고 다음 실행에도 유지합니다. 상태·안내·복구 오류 메시지와 창 제목도 전환됩니다.
- 첫 상태 조회 완료 2초 뒤, 연결 상태를 자동으로 한 번 더 확인합니다. 수동 확인·복구를 시작하면 예약된 재조회는 생략하며 자동 복구는 하지 않습니다.
- 진단 실패를 연결 실패로 단정하지 않고 불완전한 조회로 안내합니다.
- README에 MX Anywhere 3S에서 증상을 심하게 겪은 사례, 일시적 재부팅 효과, 재페어링 실패, 전체 기기 삭제·plist 초기화의 불편함, `BTLEServer` 재시작 결과를 정리했습니다.
- BTLEServer를 Bluetooth LE 기능 처리 프로세스로 설명하고, 다른 Bluetooth 키보드·기기의 연결/작동에도 일시적 영향이 있음을 앱과 README에 명시합니다.
- MIT 라이선스로 소스를 공개합니다.

**다운로드:** `Bluetooth-Mouse-Rescue-0.2.0.zip` (macOS 13+ 빌드 대상, Apple Silicon + Intel Universal). `Bluetooth-Mouse-Rescue-0.2.0-SHA256SUMS.txt`는 ZIP 검증용입니다.

**배포 제한:** ad hoc 서명이며 Developer ID 서명·Apple 공증은 없습니다. 다른 Mac에서 Gatekeeper가 실행을 차단할 수 있습니다. Intel 실기기, 모든 지원 대상 macOS, 다른 Mac 최초 실행은 아직 실기기 검증하지 않았습니다. 실제 복구는 Bluetooth 연결을 잠시 끊을 수 있으며, 버튼을 누르고 macOS 관리자 인증을 완료해야 실행됩니다.

### English

- Korean is the default, regardless of the system language. Switch between Korean and English immediately; the selection persists across launches.
- Read status once more, automatically, two seconds after the initial check completes. Manual actions supersede the delayed read. No automatic repair.
- Report incomplete diagnostics separately from an absent connection.
- Document the severe MX Anywhere 3S incident, temporary benefit from rebooting, ineffective re-pairing, inconvenience of broad resets, and successful targeted `BTLEServer` restart.
- Describe BTLEServer as a process handling Bluetooth LE features and warn in the app and README that other Bluetooth keyboards/devices may also be interrupted.
- Publish source under the MIT License.

**Download:** the Universal app ZIP and its SHA-256 checksum. **Ad hoc signed; no Developer ID signature or Apple notarization.** Gatekeeper may block downloaded copies. Intel hardware, every targeted macOS version, and first launch on another Mac have not been verified. Repair can briefly interrupt Bluetooth accessories and requires an explicit click plus macOS administrator authentication.
