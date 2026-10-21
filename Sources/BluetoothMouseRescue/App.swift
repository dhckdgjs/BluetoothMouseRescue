import SwiftUI
import AppKit
import RescueCore

@MainActor
final class RescueModel: ObservableObject {
    @Published var snapshot: Snapshot?
    @Published var busy = false
    @Published var message = "먼저 현재 연결 상태를 확인하세요."
    @Published var messageIsError = false
    @Published var hasRestarted = false
    @Published var launchRecheckPending = false
    @Published var launchRechecking = false
    private let launchCheck = LaunchStatusCheck()
    private var userActionRevision = 0

    func start() async {
        guard !launchCheck.started else { return }
        launchRecheckPending = true
        let revision = userActionRevision
        var reads = 0
        await launchCheck.run(refresh: {
            reads += 1
            self.launchRechecking = reads == 2
            await self.refresh(automatic: true)
        }, shouldRecheck: { !self.busy && self.userActionRevision == revision })
        launchRecheckPending = false
        launchRechecking = false
    }

    func refresh(automatic: Bool = false) async {
        guard !busy else { return }
        if !automatic { userActionRevision += 1 }
        busy = true
        let result = await Task.detached { Diagnostics.collect() }.value
        snapshot = result
        busy = false
        if !messageIsError {
            if !result.errors.isEmpty {
                message = "상태를 완전히 확인하지 못했습니다. 상태 다시 확인을 누르거나 시스템 설정의 Bluetooth에서 확인해 주세요."
            } else if hasRestarted {
                message = result.connectedMice.isEmpty
                    ? "서비스를 재시작했습니다. 아직 연결된 마우스는 확인되지 않습니다. 같은 채널에서 마우스 전원을 껐다 켠 뒤 다시 확인하세요."
                    : "서비스를 재시작했고 마우스 연결이 확인됐습니다. 포인터와 스크롤도 시험해 주세요."
            } else {
                message = result.connectedMice.isEmpty
                    ? "연결된 마우스가 확인되지 않습니다. 마우스 전원과 채널을 확인하고, 증상이 계속되면 복구를 시도하세요."
                    : "마우스 연결이 확인됐습니다. 포인터와 스크롤도 직접 시험해 주세요."
            }
        }
    }

    func repair() async {
        guard !busy else { return }
        userActionRevision += 1
        busy = true
        hasRestarted = false
        messageIsError = false
        message = "macOS 관리자 인증을 기다립니다. 인증 뒤 연결 상태를 확인합니다."
        let result = await Task.detached { () -> Result<(RestartVerification, Snapshot), Error> in
            Result { try Repair.perform() }
        }.value
        switch result {
        case .success(let (verification, state)):
            snapshot = state
            switch verification {
            case .restarted:
                hasRestarted = true
                message = state.connectedMice.isEmpty
                    ? "서비스를 재시작했습니다. 아직 연결된 마우스는 확인되지 않습니다. 같은 채널에서 마우스 전원을 껐다 켠 뒤 다시 확인하세요."
                    : "서비스를 재시작했고 마우스 연결이 확인됐습니다. 포인터와 스크롤도 시험해 주세요."
            case .oldProcessRemains:
                messageIsError = true
                message = "기존 서비스가 남아 있어 재시작을 확인하지 못했습니다."
            case .waitingForService:
                message = "기존 서비스는 종료됐지만 새 서비스 시작은 아직 확인되지 않습니다. 마우스를 켜고 상태를 다시 확인하세요."
            }
        case .failure(let error):
            messageIsError = true
            message = (error is RepairError || error is DiagnosticError) ? error.localizedDescription : "상태 확인 중 오류가 발생했습니다."
        }
        busy = false
    }
}

/// SwiftUI's Window title is initialized once on some macOS releases.
private struct LocalizedWindowTitle: NSViewRepresentable {
    let title: String
    func makeNSView(context: Context) -> NSView { NSView() }
    func updateNSView(_ view: NSView, context: Context) {
        DispatchQueue.main.async { view.window?.title = title }
    }
}

struct ContentView: View {
    @ObservedObject var model: RescueModel
    @AppStorage("appLanguage") private var language = AppLanguage.initialDefault
    private func t(_ source: String) -> String { L10n.text(source, language: language) }
    private var mice: [MouseDevice] { model.snapshot?.bluetooth?.mice ?? [] }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(spacing: 15) {
                Image(systemName: "computermouse.fill")
                    .font(.system(size: 32)).foregroundStyle(.blue)
                    .frame(width: 64, height: 64)
                    .background(Color.blue.opacity(0.10), in: RoundedRectangle(cornerRadius: 18))
                VStack(alignment: .leading, spacing: 5) {
                    Text(t("블루투스 마우스 복구")).font(.system(size: 25, weight: .bold))
                    Text(t("작업을 이어가면서, 마우스 연결을 다시.")).foregroundStyle(.secondary)
                }
            }
            HStack {
                Spacer()
                Picker(t("언어"), selection: $language) {
                    ForEach(AppLanguage.allCases, id: \.rawValue) { value in
                        Text(value.displayName).tag(value)
                    }
                }.pickerStyle(.segmented).frame(width: 245)
            }
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Label(t("현재 상태"), systemImage: "wave.3.right").font(.headline)
                    Spacer()
                    if model.busy { ProgressView().controlSize(.small) }
                    else if let date = model.snapshot?.date {
                        Text(date, style: .time).font(.caption).foregroundStyle(.secondary)
                    }
                }
                if model.launchRecheckPending {
                    Text(t(model.launchRechecking ? "실행 후 자동 재확인 중…" : "실행 후 자동 재확인을 기다립니다…"))
                        .font(.caption).foregroundStyle(.secondary)
                }
                statusRow("Bluetooth", value: bluetoothStatus)
                statusRow(t("Bluetooth LE 서비스 (BTLEServer)"), value: serviceStatus)
                Divider()
                if mice.isEmpty {
                    Text(t(model.snapshot == nil ? "상태를 확인하고 있습니다…" : "확인된 Bluetooth 마우스가 없습니다."))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(mice.enumerated()), id: \.offset) { _, mouse in
                        HStack {
                            Image(systemName: "computermouse").foregroundStyle(.secondary)
                            Text(mouse.name).lineLimit(1)
                            Spacer()
                            if let battery = mouse.battery { Text(battery).foregroundStyle(.secondary) }
                            Label(t(mouse.connected ? "연결됨" : "연결 안 됨"),
                                  systemImage: mouse.connected ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(mouse.connected ? Color.green : Color.secondary)
                        }
                    }
                }
                if let errors = model.snapshot?.errors, !errors.isEmpty {
                    Text(errors.map { t($0) }.joined(separator: "\n")).font(.caption).foregroundStyle(.orange)
                }
            }
            .padding(20)
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 8) {
                Text(t("연결이 갑자기 안 될 때")).font(.headline)
                Text(t("Bluetooth LE 기능을 처리하는 macOS 서비스(BTLEServer)를 다시 시작합니다. 관리자 인증이 필요하며, 페어링 정보는 지우지 않습니다."))
                    .font(.callout).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
            Label(t("다른 Bluetooth 키보드와 기기도 영향을 받아 일시적으로 연결이 끊기거나 작동이 중단될 수 있습니다. 복구 전에 내장 키보드·트랙패드 등 다른 조작 수단을 확보하세요."), systemImage: "exclamationmark.triangle")
                .font(.callout).foregroundStyle(.orange)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 12) {
                Button { Task { await model.repair() } } label: {
                    Label(t("마우스 연결 복구"), systemImage: "arrow.clockwise")
                        .frame(minWidth: 165).padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent).controlSize(.large)
                .disabled(model.busy || model.snapshot == nil || model.snapshot?.servicePIDs.isEmpty == true)
                Button(t("상태 다시 확인")) { Task { await model.refresh() } }
                    .disabled(model.busy)
                Spacer()
            }
            HStack(alignment: .top, spacing: 9) {
                Image(systemName: "info.circle")
                Text(t(model.message))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .font(.callout)
            .foregroundStyle(model.messageIsError ? Color.orange : Color.secondary)
            Divider()
            HStack {
                Text("0.2.1 · " + t("macOS 13 이상")).font(.caption).foregroundStyle(.tertiary)
                Spacer()
                Button(t("진단 요약 복사")) {
                    guard let state = model.snapshot else { return }
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(state.shareableSummary, forType: .string)
                }.buttonStyle(.link).disabled(model.snapshot == nil || model.busy)
                Button(t("앱 닫기")) { NSApplication.shared.terminate(nil) }
                    .disabled(model.busy)
            }
        }
        .padding(28).frame(width: 650)
        .background(LocalizedWindowTitle(title: t("블루투스 마우스 복구")))
        .environment(\.locale, Locale(identifier: language.rawValue))
        .task { await model.start() }
    }
    private var bluetoothStatus: String {
        guard let on = model.snapshot?.bluetooth?.poweredOn else { return t("확인 중 또는 알 수 없음") }
        return t(on ? "켜짐" : "꺼짐")
    }
    private var serviceStatus: String {
        guard let snapshot = model.snapshot else { return t("확인 중") }
        return t(snapshot.servicePIDs.isEmpty ? "실행 중인 서비스 없음 / 확인 불가" : "실행 중")
    }
    private func statusRow(_ title: String, value: String) -> some View {
        HStack { Text(title).foregroundStyle(.secondary); Spacer(); Text(value) }
    }
}

@main
struct BluetoothMouseRescueApp: App {
    @StateObject private var model = RescueModel()
    @AppStorage("appLanguage") private var language = AppLanguage.initialDefault

    init() {
        // Safe CLI smoke check for builds/CI. Never accepts a CLI repair flag.
        if CommandLine.arguments.contains("--diagnose") {
            let state = Diagnostics.collect()
            print(state.shareableSummary)
            exit(state.errors.isEmpty ? 0 : 1)
        }
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    var body: some Scene {
        Window(Text(L10n.text("블루투스 마우스 복구", language: language)), id: "main") { ContentView(model: model) }
            .windowResizability(.contentSize)
            .commands { CommandGroup(replacing: .newItem) {} }
    }
}
