import AppKit
import KeyboardShortcuts

public final class StatusItemController {
    private let item: NSStatusItem
    private let menu = NSMenu()
    private let statusHeader = NSMenuItem(title: "Ready", action: nil, keyEquivalent: "")
    private let toggleItem = NSMenuItem(title: "Start Dictation", action: nil, keyEquivalent: "")
    private let spinner = NSProgressIndicator()

    public var onToggle: (() -> Void)?
    public var onOpenPreferences: (() -> Void)?
    public var onQuit: (() -> Void)?

    public init() {
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        spinner.style = .spinning
        spinner.controlSize = .small
        spinner.isDisplayedWhenStopped = false

        statusHeader.isEnabled = false
        menu.addItem(statusHeader)
        menu.addItem(.separator())

        toggleItem.target = self
        toggleItem.action = #selector(toggleTapped)
        toggleItem.setShortcut(for: .toggleDictation)   // shows the current hotkey, kept in sync
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
        switch state {
        case .idle:
            stopSpinner()
            setSymbol("mic", color: nil)
            statusHeader.title = "Ready"
            toggleItem.title = "Start Dictation"
        case .recording:
            stopSpinner()
            setSymbol("mic.fill", color: .systemRed)
            statusHeader.title = "Recording…"
            toggleItem.title = "Stop & Transcribe"
        case .transcribing:
            statusHeader.title = "Transcribing…"
            toggleItem.title = "Transcribing…"
            startSpinner()
        }
    }

    private func setSymbol(_ name: String, color: NSColor?) {
        guard let button = item.button else { return }
        if let color {
            let conf = NSImage.SymbolConfiguration(paletteColors: [color])
            let image = NSImage(systemSymbolName: name, accessibilityDescription: "koe")?
                .withSymbolConfiguration(conf)
            image?.isTemplate = false
            button.image = image
        } else {
            let image = NSImage(systemSymbolName: name, accessibilityDescription: "koe")
            image?.isTemplate = true
            button.image = image
        }
    }

    private func startSpinner() {
        guard let button = item.button else { return }
        button.image = nil
        if spinner.superview == nil {
            spinner.frame = NSRect(x: 4, y: 2, width: 16, height: 16)
            button.addSubview(spinner)
        }
        spinner.startAnimation(nil)
    }

    private func stopSpinner() {
        spinner.stopAnimation(nil)
        spinner.removeFromSuperview()
    }

    @objc private func toggleTapped() { onToggle?() }
    @objc private func prefsTapped() { onOpenPreferences?() }
    @objc private func quitTapped() { onQuit?() }
}
