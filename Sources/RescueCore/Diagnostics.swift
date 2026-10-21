import Foundation

public struct MouseDevice: Equatable, Sendable {
    public let name: String
    public let connected: Bool
    public let battery: String?
}

public struct BluetoothReport: Equatable, Sendable {
    public let poweredOn: Bool?
    public let mice: [MouseDevice]

    public static func parse(_ data: Data) throws -> BluetoothReport {
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let entries = root["SPBluetoothDataType"] as? [[String: Any]],
              let entry = entries.first else { throw DiagnosticError.unrecognizedReport }
        let controller = entry["controller_properties"] as? [String: Any]
        let state = controller?["controller_state"] as? String
        let on: Bool? = state == "attrib_on" ? true : (state == "attrib_off" ? false : nil)
        var mice: [MouseDevice] = []
        for (key, connected) in [("device_connected", true), ("device_not_connected", false)] {
            for group in entry[key] as? [[String: Any]] ?? [] {
                for (name, raw) in group {
                    guard let fields = raw as? [String: Any] else { continue }
                    let type = (fields["device_minorType"] as? String ?? "").lowercased()
                    let appearance = (fields["device_appearance"] as? String ?? "").lowercased()
                    // Avoid collecting unrelated phones, headsets, addresses or serial numbers.
                    guard type.contains("mouse") || appearance.contains("mouse") ||
                            name.lowercased().contains("mx anywhere") || name.lowercased().contains("mx master")
                    else { continue }
                    mice.append(MouseDevice(name: name, connected: connected,
                                            battery: fields["device_batteryLevelMain"] as? String))
                }
            }
        }
        return BluetoothReport(poweredOn: on, mice: mice.sorted { $0.name < $1.name })
    }
}

public enum DiagnosticError: LocalizedError {
    case unrecognizedReport
    case timeout
    case commandFailed(String)
    public var errorDescription: String? {
        switch self {
        case .unrecognizedReport: return "이 macOS의 Bluetooth 상태 형식을 읽지 못했습니다. 시스템 설정에서 확인해 주세요."
        case .timeout: return "상태 확인 또는 인증 대기 시간이 초과됐습니다. 다시 시도해 주세요."
        case .commandFailed(let detail): return detail
        }
    }
}

public struct CommandResult: Sendable {
    public let status: Int32
    public let output: Data
    public let error: String
    public var text: String { String(decoding: output, as: UTF8.self) }
}

public enum CommandRunner {
    /// Run off the main thread. Redirect to a private temporary file to avoid pipe-buffer deadlocks.
    public static func run(_ executable: String, _ arguments: [String], timeout: TimeInterval = 20) throws -> CommandResult {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: false,
                                               attributes: [.posixPermissions: 0o700])
        defer { try? FileManager.default.removeItem(at: folder) }
        let outURL = folder.appendingPathComponent("stdout")
        let errURL = folder.appendingPathComponent("stderr")
        FileManager.default.createFile(atPath: outURL.path, contents: nil, attributes: [.posixPermissions: 0o600])
        FileManager.default.createFile(atPath: errURL.path, contents: nil, attributes: [.posixPermissions: 0o600])
        let out = try FileHandle(forWritingTo: outURL)
        let err = try FileHandle(forWritingTo: errURL)
        defer { try? out.close(); try? err.close() }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardInput = FileHandle.nullDevice
        process.standardOutput = out
        process.standardError = err
        let done = DispatchSemaphore(value: 0)
        process.terminationHandler = { _ in done.signal() }
        try process.run()
        if done.wait(timeout: .now() + timeout) == .timedOut {
            process.terminate()
            if done.wait(timeout: .now() + 2) == .timedOut, process.isRunning {
                kill(process.processIdentifier, SIGKILL)
                _ = done.wait(timeout: .now() + 2)
            }
            throw DiagnosticError.timeout
        }
        return CommandResult(status: process.terminationStatus,
                             output: try Data(contentsOf: outURL),
                             error: String(decoding: try Data(contentsOf: errURL), as: UTF8.self))
    }
}

public struct Snapshot: Sendable {
    public let date: Date
    public let servicePIDs: Set<Int32>
    public let bluetooth: BluetoothReport?
    public let errors: [String]

    public init(date: Date, servicePIDs: Set<Int32>, bluetooth: BluetoothReport?, errors: [String]) {
        self.date = date
        self.servicePIDs = servicePIDs
        self.bluetooth = bluetooth
        self.errors = errors
    }

    public var connectedMice: [MouseDevice] { bluetooth?.mice.filter(\.connected) ?? [] }
    public var shareableSummary: String {
        // Deliberately omit local user/device names, MACs, serials and raw system logs.
        let power = bluetooth?.poweredOn.map { $0 ? "on" : "off" } ?? "unknown"
        return """
        Bluetooth Mouse Rescue 0.2.1
        macOS: \(ProcessInfo.processInfo.operatingSystemVersionString)
        Bluetooth: \(power)
        BTLEServer running: \(!servicePIDs.isEmpty)
        Paired/listed mice: \(bluetooth?.mice.count ?? 0)
        Connected mice: \(connectedMice.count)
        Diagnostics complete: \(errors.isEmpty)
        Actual pointer/scroll operation: requires user confirmation
        """
    }
}

public enum Diagnostics {
    public static func parsePIDs(_ text: String) -> Set<Int32> {
        Set(text.split(whereSeparator: \.isWhitespace).compactMap { Int32($0) }.filter { $0 > 0 })
    }
    public static func servicePIDs() throws -> Set<Int32> {
        let result = try CommandRunner.run("/usr/bin/pgrep", ["-x", "BTLEServer"])
        guard result.status == 0 || result.status == 1 else {
            throw DiagnosticError.commandFailed("BTLEServer 실행 여부를 확인하지 못했습니다.")
        }
        return parsePIDs(result.text)
    }
    public static func collect() -> Snapshot {
        var errors: [String] = []
        var pids: Set<Int32> = []
        var bluetooth: BluetoothReport?
        do { pids = try servicePIDs() } catch {
            errors.append((error as? DiagnosticError)?.localizedDescription ?? "BTLEServer 실행 여부를 확인하지 못했습니다.")
        }
        do {
            let result = try CommandRunner.run("/usr/sbin/system_profiler", ["SPBluetoothDataType", "-json"], timeout: 25)
            guard result.status == 0 else { throw DiagnosticError.commandFailed("Bluetooth 정보를 읽지 못했습니다.") }
            bluetooth = try BluetoothReport.parse(result.output)
        } catch {
            errors.append((error as? DiagnosticError)?.localizedDescription ?? "Bluetooth 정보를 읽지 못했습니다.")
        }
        return Snapshot(date: Date(), servicePIDs: pids, bluetooth: bluetooth, errors: errors)
    }
}

public enum RestartVerification: Equatable, Sendable {
    case restarted, oldProcessRemains, waitingForService
    public static func evaluate(before: Set<Int32>, after: Set<Int32>) -> RestartVerification {
        if !before.intersection(after).isEmpty { return .oldProcessRemains }
        return after.isEmpty ? .waitingForService : .restarted
    }
}
