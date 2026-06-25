import AppKit
import SwiftUI

@MainActor
public final class PreferencesWindow: NSObject {
    private let model: PreferencesViewModel
    private var window: NSWindow?

    public init(preferences: Preferences) {
        self.model = PreferencesViewModel(preferences)
        super.init()
    }

    public func show() {
        if window == nil {
            let host = NSHostingController(rootView: PreferencesView(model: model))
            let win = NSWindow(contentViewController: host)
            win.title = "koe Preferences"
            win.styleMask = [.titled, .closable]
            win.isReleasedWhenClosed = false
            window = win
        }
        window?.center()
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
