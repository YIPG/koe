import AppKit

public final class StatusItemController {
    private let item: NSStatusItem
    private let menu = NSMenu()
    private let toggleItem = NSMenuItem(title: "Start Dictation", action: nil, keyEquivalent: "")

    public var onToggle: (() -> Void)?
    public var onOpenPreferences: (() -> Void)?
    public var onQuit: (() -> Void)?

    public init() {
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = NSImage(systemSymbolName: "mic", accessibilityDescription: "koe")

        toggleItem.target = self
        toggleItem.action = #selector(toggleTapped)
        menu.addItem(toggleItem)
        menu.addItem(.separator())

        let prefs = NSMenuItem(title: "Preferences…", action: #selector(prefsTapped), keyEquivalent: ",")
        prefs.target = self
        menu.addItem(prefs)

        let quit = NSMenuItem(title: "Quit koe", action: #selector(quitTapped), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        item.menu = menu
        render(state: .idle)
    }

    public func render(state: DictationState) {
        let symbol: String
        switch state {
        case .idle:         symbol = "mic"; toggleItem.title = "Start Dictation"
        case .recording:    symbol = "mic.fill"; toggleItem.title = "Stop & Transcribe"
        case .transcribing: symbol = "ellipsis.circle"; toggleItem.title = "Transcribing…"
        }
        item.button?.image = NSImage(systemSymbolName: symbol, accessibilityDescription: "koe")
    }

    @objc private func toggleTapped() { onToggle?() }
    @objc private func prefsTapped() { onOpenPreferences?() }
    @objc private func quitTapped() { onQuit?() }
}
