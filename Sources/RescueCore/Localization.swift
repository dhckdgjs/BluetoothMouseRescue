import Foundation

public enum AppLanguage: String, CaseIterable, Sendable {
    case korean = "ko"
    case english = "en"

    /// Always Korean on first launch, independent of the system language.
    public static let initialDefault: AppLanguage = .korean

    public var displayName: String { self == .korean ? "한국어" : "English" }
}

public enum L10n {
    // Korean source keys keep translations auditable, including diagnostics and repair errors.
    public static let english: [String: String] = [
        "블루투스 마우스 복구": "Bluetooth Mouse Rescue",
        "작업을 이어가면서, 마우스 연결을 다시.": "Get your mouse connected. Get back to work.",
        "언어": "Language",
        "다른 Bluetooth 키보드와 기기도 영향을 받아 일시적으로 연결이 끊기거나 작동이 중단될 수 있습니다. 복구 전에 내장 키보드·트랙패드 등 다른 조작 수단을 확보하세요.": "Other Bluetooth keyboards and devices may also be affected: connections or operation may be interrupted temporarily. Before repairing, have a built-in keyboard, trackpad or another way to control your Mac available.",
        "현재 상태": "Current status",
        "Bluetooth LE 서비스 (BTLEServer)": "Bluetooth LE service (BTLEServer)",
        "상태를 확인하고 있습니다…": "Checking status…",
        "확인된 Bluetooth 마우스가 없습니다.": "No Bluetooth mice were found.",
        "연결됨": "Connected",
        "연결 안 됨": "Not connected",
        "연결이 갑자기 안 될 때": "When your mouse suddenly stops connecting",
        "Bluetooth LE 기능을 처리하는 macOS 서비스(BTLEServer)를 다시 시작합니다. 관리자 인증이 필요하며, 페어링 정보는 지우지 않습니다.": "Restarts BTLEServer, the macOS process that handles Bluetooth LE features. Administrator authentication is required. Pairing information is preserved.",
        "마우스 연결 복구": "Repair connection",
        "상태 다시 확인": "Refresh status",
        "사용자가 포인터와 스크롤의 정상 작동을 확인했습니다.": "You confirmed that the pointer and scrolling work correctly.",
        "포인터와 스크롤이 정상 작동합니다": "The pointer and scrolling work correctly",
        "macOS 13 이상": "macOS 13 or later",
        "진단 요약 복사": "Copy diagnostics",
        "확인 중 또는 알 수 없음": "Checking / unknown",
        "켜짐": "On",
        "꺼짐": "Off",
        "확인 중": "Checking",
        "실행 중인 서비스 없음 / 확인 불가": "Not running / unavailable",
        "실행 중": "Running",
        "먼저 현재 연결 상태를 확인하세요.": "Check the current connection status first.",
        "연결된 마우스가 확인되지 않습니다. 마우스 전원과 채널을 확인하고, 증상이 계속되면 복구를 시도하세요.": "No connected mouse was found. Check its power and channel. If the problem continues, try repairing the connection.",
        "마우스 연결이 확인됐습니다. 포인터와 스크롤도 직접 시험해 주세요.": "Your mouse is connected. Please also test the pointer and scrolling.",
        "macOS 관리자 인증을 기다립니다. 인증 뒤 연결 상태를 확인합니다.": "Waiting for macOS administrator authentication. Connection status will be checked afterward.",
        "서비스를 재시작했습니다. 아직 연결된 마우스는 확인되지 않습니다. 같은 채널에서 마우스 전원을 껐다 켠 뒤 다시 확인하세요.": "The service restarted, but no connected mouse was found yet. Turn your mouse off and on using the same channel, then refresh.",
        "서비스를 재시작했고 마우스 연결이 확인됐습니다. 포인터와 스크롤도 시험해 주세요.": "The service restarted and your mouse is connected. Please also test the pointer and scrolling.",
        "기존 서비스가 남아 있어 재시작을 확인하지 못했습니다.": "The previous service process is still running. A restart could not be confirmed.",
        "기존 서비스는 종료됐지만 새 서비스 시작은 아직 확인되지 않습니다. 마우스를 켜고 상태를 다시 확인하세요.": "The previous service stopped, but a new service has not been detected yet. Turn your mouse on and refresh the status.",
        "관리자 인증을 취소했습니다. 복구 명령은 실행되지 않았습니다.": "Administrator authentication was cancelled. The repair command did not run.",
        "BTLEServer가 실행 중이지 않습니다. Bluetooth를 켠 뒤 상태를 다시 확인해 주세요.": "BTLEServer is not running. Turn Bluetooth on, then refresh the status.",
        "관리자 인증 또는 서비스 종료에 실패했습니다. 상태 확인 후 다시 시도해 주세요.": "Administrator authentication or service termination failed. Check the status and try again.",
        "이 macOS의 Bluetooth 상태 형식을 읽지 못했습니다. 시스템 설정에서 확인해 주세요.": "This macOS Bluetooth report format could not be read. Check System Settings.",
        "상태 확인 또는 인증 대기 시간이 초과됐습니다. 다시 시도해 주세요.": "The status check or authentication timed out. Please try again.",
        "BTLEServer 실행 여부를 확인하지 못했습니다.": "Could not check whether BTLEServer is running.",
        "Bluetooth 정보를 읽지 못했습니다.": "Could not read Bluetooth information.",
        "상태를 완전히 확인하지 못했습니다. 상태 다시 확인을 누르거나 시스템 설정의 Bluetooth에서 확인해 주세요.": "The status check was incomplete. Refresh the status or check Bluetooth in System Settings.",
        "실행 후 자동 재확인을 기다립니다…": "Waiting for one automatic recheck after launch…",
        "실행 후 자동 재확인 중…": "Automatically rechecking status after launch…",
        "상태 확인 중 오류가 발생했습니다.": "An error occurred while checking the status.",
    ]

    public static func text(_ source: String, language: AppLanguage) -> String {
        language == .korean ? source : (english[source] ?? source)
    }
}
