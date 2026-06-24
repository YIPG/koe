import AppKit
import KoeKit

// main.swift runs on the main thread at process start, but its top-level code
// is a nonisolated context. AppKit + AppDelegate are @MainActor-isolated, so we
// assert main-actor isolation to call them.
MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory)
    app.run()
}
