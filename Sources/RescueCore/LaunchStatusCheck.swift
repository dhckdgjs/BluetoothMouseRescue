import Foundation

/// One initial read followed by one delayed read per app session. Never performs a repair.
/// A user action during the delay supersedes the automatic second read.
@MainActor
public final class LaunchStatusCheck {
    public private(set) var started = false
    public init() {}

    public func run(
        refresh: () async -> Void,
        wait: () async throws -> Void = { try await Task.sleep(nanoseconds: 2_000_000_000) },
        shouldRecheck: () -> Bool = { true }
    ) async {
        guard !started else { return }
        started = true
        await refresh()
        do { try await wait() } catch { return }
        guard !Task.isCancelled, shouldRecheck() else { return }
        await refresh()
    }
}
