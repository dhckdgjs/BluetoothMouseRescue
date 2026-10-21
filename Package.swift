// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BluetoothMouseRescue",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "BluetoothMouseRescue", targets: ["BluetoothMouseRescue"])],
    targets: [
        .target(name: "RescueCore"),
        .executableTarget(name: "BluetoothMouseRescue", dependencies: ["RescueCore"]),
        .executableTarget(name: "RescueChecks", dependencies: ["RescueCore"], path: "Tests/RescueCoreTests")
    ]
)
