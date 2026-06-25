import AppKit
import ApplicationServices

public final class TextInserter: TextInserting {
    /// Called when text could not be auto-inserted because Accessibility is not
    /// granted. The transcription is left on the clipboard for manual paste.
    public var onAccessibilityMissing: (() -> Void)?

    public init() {}

    public static func hasAccessibilityPermission() -> Bool {
        AXIsProcessTrusted()
    }

    public static func promptAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    public func insert(_ text: String) {
        let pasteboard = NSPasteboard.general
        let saved = pasteboard.string(forType: .string)

        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        guard Self.hasAccessibilityPermission() else {
            // Can't synthesize ⌘V without Accessibility. Leave the text on the
            // clipboard (don't restore) so the user can paste it manually.
            onAccessibilityMissing?()
            return
        }

        pasteCmdV()

        // Restore the previous clipboard shortly after the paste completes.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            pasteboard.clearContents()
            if let saved { pasteboard.setString(saved, forType: .string) }
        }
    }

    private func pasteCmdV() {
        let source = CGEventSource(stateID: .combinedSessionState)
        let vKey: CGKeyCode = 0x09  // 'v'
        let down = CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: true)
        down?.flags = .maskCommand
        let up = CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: false)
        up?.flags = .maskCommand
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }
}
