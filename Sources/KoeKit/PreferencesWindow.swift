import AppKit
import KeyboardShortcuts

public final class PreferencesWindow: NSObject, NSTextFieldDelegate {
    private let preferences: Preferences
    private var window: NSWindow?

    private let endpointField = NSTextField()
    private let deploymentField = NSTextField()
    private let apiVersionField = NSTextField()
    private let apiKeyField = NSSecureTextField()
    private let languagePopup = NSPopUpButton()

    public init(preferences: Preferences) {
        self.preferences = preferences
        super.init()
    }

    public func show() {
        if window == nil { window = buildWindow() }
        loadValues()
        window?.center()
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    private func row(_ title: String, _ field: NSView, y: CGFloat) -> [NSView] {
        let label = NSTextField(labelWithString: title)
        label.frame = NSRect(x: 20, y: y, width: 110, height: 22)
        label.alignment = .right
        field.frame = NSRect(x: 140, y: y, width: 300, height: 24)
        return [label, field]
    }

    private func buildWindow() -> NSWindow {
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 260),
            styleMask: [.titled, .closable], backing: .buffered, defer: false)
        // We cache and reuse this window, so AppKit must NOT release it on close —
        // otherwise reopening messages a freed object (intermittent crash).
        win.isReleasedWhenClosed = false
        win.title = "koe Preferences"
        let content = win.contentView!

        [endpointField, deploymentField, apiVersionField, apiKeyField].forEach {
            $0.delegate = self
        }
        languagePopup.addItems(withTitles: ["ja", "en", "auto"])
        languagePopup.target = self
        languagePopup.action = #selector(languageChanged)

        var views: [NSView] = []
        views += row("Endpoint", endpointField, y: 210)
        views += row("Deployment", deploymentField, y: 178)
        views += row("API Version", apiVersionField, y: 146)
        views += row("API Key", apiKeyField, y: 114)
        views += row("Language", languagePopup, y: 82)

        let hotkeyLabel = NSTextField(labelWithString: "Hotkey")
        hotkeyLabel.frame = NSRect(x: 20, y: 46, width: 110, height: 22)
        hotkeyLabel.alignment = .right
        let recorder = KeyboardShortcuts.RecorderCocoa(for: HotkeyManager.shortcutName)
        recorder.frame = NSRect(x: 140, y: 44, width: 300, height: 26)
        views += [hotkeyLabel, recorder]

        views.forEach { content.addSubview($0) }
        return win
    }

    private func loadValues() {
        endpointField.stringValue = preferences.endpoint
        deploymentField.stringValue = preferences.deployment
        apiVersionField.stringValue = preferences.apiVersion
        apiKeyField.stringValue = preferences.apiKey ?? ""
        languagePopup.selectItem(withTitle: preferences.language)
    }

    public func controlTextDidChange(_ obj: Notification) {
        preferences.endpoint = endpointField.stringValue
        preferences.deployment = deploymentField.stringValue
        preferences.apiVersion = apiVersionField.stringValue
        preferences.apiKey = apiKeyField.stringValue
    }

    @objc private func languageChanged() {
        preferences.language = languagePopup.titleOfSelectedItem ?? "ja"
    }
}
