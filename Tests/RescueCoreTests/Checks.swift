import Foundation
import RescueCore

struct CheckFailure: Error, CustomStringConvertible { let description: String }
func expect(_ value: @autoclosure () -> Bool, _ detail: String) throws {
    if !value() { throw CheckFailure(description: detail) }
}
func expectThrows(_ action: () throws -> Void) throws {
    do { try action() } catch { return }
    throw CheckFailure(description: "Expected an error, but operation succeeded")
}

@main
enum Checks {
    @MainActor
    static func main() async throws {
        let tests: [(String, () throws -> Void)] = [
            ("mouse filtering, connection, battery and privacy", {
                let json = #"{"SPBluetoothDataType":[{"controller_properties":{"controller_state":"attrib_on"},"device_connected":[{"Example Mouse":{"device_minorType":"Mouse","device_batteryLevelMain":"100%","device_address":"PRIVATE","device_serialNumber":"PRIVATE"}},{"Private headphones":{"device_minorType":"Headphones"}}],"device_not_connected":[{"MX Anywhere 3S":{}}]}]}"#
                let report = try BluetoothReport.parse(Data(json.utf8))
                try expect(report.poweredOn == true, "power state")
                try expect(report.mice.count == 2, "filter excludes headphones")
                try expect(report.mice.first?.battery == "100%", "battery")
                try expect(report.mice.first?.connected == true, "connected")
                try expect(report.mice.last?.connected == false, "disconnected")
                let state = Snapshot(date: Date(), servicePIDs: [123], bluetooth: report, errors: [])
                for privateValue in ["PRIVATE", "Example Mouse", "Private headphones"] {
                    try expect(!state.shareableSummary.contains(privateValue), "summary leaks private fields")
                }
            }),
            ("powered off, unknown and invalid reports", {
                let off = Data(#"{"SPBluetoothDataType":[{"controller_properties":{"controller_state":"attrib_off"}}]}"#.utf8)
                let unknown = Data(#"{"SPBluetoothDataType":[{}]}"#.utf8)
                let offReport = try BluetoothReport.parse(off)
                let unknownReport = try BluetoothReport.parse(unknown)
                try expect(offReport.poweredOn == false, "off")
                try expect(unknownReport.poweredOn == nil, "unknown must not become off")
                try expectThrows { _ = try BluetoothReport.parse(Data("{}".utf8)) }
                try expectThrows { _ = try BluetoothReport.parse(Data("not json".utf8)) }
            }),
            ("missing battery", {
                let json = #"{"SPBluetoothDataType":[{"device_connected":[{"Mouse":{"device_minorType":"Mouse"}}]}]}"#
                let report = try BluetoothReport.parse(Data(json.utf8))
                try expect(report.mice.count == 1 && report.mice[0].battery == nil, "optional battery")
            }),
            ("PID replacement versus command completion", {
                try expect(RestartVerification.evaluate(before: [1], after: [2]) == .restarted, "new PID")
                try expect(RestartVerification.evaluate(before: [1], after: []) == .waitingForService, "not running")
                try expect(RestartVerification.evaluate(before: [1, 2], after: [2, 3]) == .oldProcessRemains, "old PID survives")
                try expect(Diagnostics.parsePIDs("123\n456\n0\nno\n-5") == [123,456], "PID parsing")
            }),
            ("child output and failed exit", {
                let output = try CommandRunner.run("/usr/bin/printf", ["hello"])
                let failed = try CommandRunner.run("/usr/bin/false", [])
                try expect(output.text == "hello" && output.status == 0, "stdout")
                try expect(failed.status == 1, "failed exit")
            }),
            ("bounded child lifetime", {
                try expectThrows { _ = try CommandRunner.run("/bin/sleep", ["10"], timeout: 0.05) }
            })
        ]
        for (name, body) in tests { try body(); print("PASS: \(name)") }
        var events: [String] = []
        let launch = LaunchStatusCheck()
        await launch.run(refresh: { events.append("read") }, wait: { events.append("wait") })
        await launch.run(refresh: { events.append("unexpected") }, wait: {})
        try expect(events == ["read", "wait", "read"], "one delayed recheck per session")
        print("PASS: initial read, delayed fresh read, no duplicate launch reads")

        events = []
        await LaunchStatusCheck().run(refresh: { events.append("read") }, wait: {}, shouldRecheck: { false })
        try expect(events == ["read"], "manual action supersedes delayed read")
        print("PASS: user action suppresses automatic recheck")

        events = []
        await LaunchStatusCheck().run(refresh: { events.append("read") }, wait: { throw CancellationError() })
        try expect(events == ["read"], "cancelled delay must not refresh")
        print("PASS: cancelled launch task does not recheck")

        let stale = Data(#"{"SPBluetoothDataType":[{"device_not_connected":[{"MX Anywhere 3S":{}}]}]}"#.utf8)
        let fresh = Data(#"{"SPBluetoothDataType":[{"device_connected":[{"MX Anywhere 3S":{}}]}]}"#.utf8)
        var reports = [stale, fresh]
        var states: [Bool] = []
        await LaunchStatusCheck().run(refresh: {
            let report = try! BluetoothReport.parse(reports.removeFirst())
            states.append(report.mice[0].connected)
        }, wait: {})
        try expect(states == [false, true], "recheck must consume a new status, not cached pairing")
        print("PASS: first disconnected report becomes connected on fresh recheck")

        try expect(AppLanguage.initialDefault == .korean, "first launch must default to Korean regardless of system language")
        for (source, translation) in L10n.english {
            try expect(!translation.isEmpty && !translation.contains(where: { $0 >= "가" && $0 <= "힣" }), "English translation missing: \(source)")
            try expect(L10n.text(source, language: .korean) == source, "Korean text changed")
            try expect(L10n.text(source, language: .english) == translation, "English lookup failed")
        }
        print("PASS: language defaults and all \(L10n.english.count) translations")
        print("\(tests.count + 5) check groups passed. No Bluetooth services changed.")
    }
}
