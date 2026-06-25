import AppKit

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    public let statusItem = StatusItemController()

    private let preferences = Preferences()
    private let hotkey = HotkeyManager()
    private let indicator = RecordingIndicator()
    private let textInserter = TextInserter()
    private lazy var prefsWindow = PreferencesWindow(preferences: preferences)
    private var coordinator: DictationCoordinator?

    public override init() { super.init() }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        MainMenu.install()  // enables ⌘C/⌘V/⌘A in the Preferences window

        let coordinator = DictationCoordinator(
            recorder: AudioRecorder(),
            transcriber: PreferencesTranscriptionService(configProvider: { [preferences] in
                guard preferences.isConfigured else { return nil }
                return AzureConfig(
                    endpoint: preferences.endpoint,
                    deployment: preferences.deployment,
                    apiVersion: preferences.apiVersion,
                    apiKey: preferences.apiKey ?? "")
            }),
            inserter: textInserter,
            language: { [preferences] in
                let lang = preferences.language
                return lang == "auto" ? nil : lang
            })
        self.coordinator = coordinator

        coordinator.onStateChange = { [weak self] state in
            self?.statusItem.render(state: state)
            switch state {
            case .recording:    self?.indicator.show("● Recording…")
            case .transcribing: self?.indicator.show("Transcribing…")
            case .idle:         self?.indicator.hide()
            }
        }
        coordinator.onError = { [weak self] error in
            self?.indicator.hide()
            self?.notify("koe error", String(describing: error))
        }

        textInserter.onAccessibilityMissing = { [weak self] in
            self?.notify("koe needs Accessibility",
                         "The transcription is on your clipboard — press ⌘V to paste it. "
                         + "To auto-insert, enable koe in System Settings → Privacy & Security → Accessibility.")
            TextInserter.promptAccessibilityPermission()
        }

        statusItem.onToggle = { [weak self] in self?.handleToggle() }
        statusItem.onOpenPreferences = { [weak self] in self?.prefsWindow.show() }
        statusItem.onQuit = { NSApp.terminate(nil) }

        hotkey.onToggle = { [weak self] in self?.handleToggle() }
        hotkey.activate()

        if !TextInserter.hasAccessibilityPermission() {
            TextInserter.promptAccessibilityPermission()
        }
    }

    private func handleToggle() {
        guard preferences.isConfigured else {
            notify("koe is not configured", "Add your Azure endpoint and API key in Preferences.")
            prefsWindow.show()
            return
        }
        coordinator?.toggle()
    }

    private func notify(_ title: String, _ body: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = body
        alert.alertStyle = .warning
        alert.runModal()
    }
}
