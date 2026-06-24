// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "koe",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "koe", targets: ["koe"]),
        .library(name: "KoeKit", targets: ["KoeKit"]),
    ],
    dependencies: [
        // Pinned below 1.16.0: that release added `#Preview` macros which require
        // the SwiftUI macro plugin shipped only with full Xcode (not Command Line
        // Tools). 1.10.x has the APIs we use (Name, onKeyDown, RecorderCocoa) and
        // builds cleanly under CLT.
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", "1.10.0" ..< "1.16.0"),
    ],
    targets: [
        .target(
            name: "KoeKit",
            dependencies: [.product(name: "KeyboardShortcuts", package: "KeyboardShortcuts")]
        ),
        .executableTarget(name: "koe", dependencies: ["KoeKit"]),
        // XCTest ships only with full Xcode; this machine has Command Line Tools
        // only. KoeTests is a plain executable test harness (run: `swift run
        // KoeTests`) so the logic suite runs under CLT without Xcode.
        .executableTarget(name: "KoeTests", dependencies: ["KoeKit"], path: "Tests/KoeTests"),
    ]
)
