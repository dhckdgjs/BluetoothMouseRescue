import Foundation
import RescueCore

enum RepairError: LocalizedError {
    case cancelled, serviceMissing, authorizationFailed
    var errorDescription: String? {
        switch self {
        case .cancelled: return "관리자 인증을 취소했습니다. 복구 명령은 실행되지 않았습니다."
        case .serviceMissing: return "BTLEServer가 실행 중이지 않습니다. Bluetooth를 켠 뒤 상태를 다시 확인해 주세요."
        case .authorizationFailed: return "관리자 인증 또는 서비스 종료에 실패했습니다. 상태 확인 후 다시 시도해 주세요."
        }
    }
}

enum Repair {
    // A fixed, auditable command. Never insert device names, user input, paths or remote content here.
    // Authentication is handled by macOS; the app never asks for, receives or stores the password.
    static let authorizationScript = """
    do shell script "/usr/bin/killall -9 BTLEServer" with administrator privileges
    """

    static func perform() throws -> (RestartVerification, Snapshot) {
        let before = try Diagnostics.servicePIDs()
        guard !before.isEmpty else { throw RepairError.serviceMissing }
        let result = try CommandRunner.run("/usr/bin/osascript", ["-e", authorizationScript], timeout: 180)
        if result.status != 0 {
            if result.error.contains("(-128)") { throw RepairError.cancelled }
            throw RepairError.authorizationFailed
        }
        // Relaunch is managed by macOS and may be demand-driven. A completed kill is not recovery proof.
        var after: Set<Int32> = []
        for _ in 0..<12 {
            Thread.sleep(forTimeInterval: 1)
            after = try Diagnostics.servicePIDs()
            if RestartVerification.evaluate(before: before, after: after) == .restarted { break }
        }
        return (RestartVerification.evaluate(before: before, after: after), Diagnostics.collect())
    }
}
