import AppKit

public final class RecordingIndicator {
    private var panel: NSPanel?

    public init() {}

    public func show(_ text: String) {
        hide()
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.alignment = .center
        label.frame = NSRect(x: 16, y: 12, width: 160, height: 20)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 192, height: 44),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered, defer: false)
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.backgroundColor = NSColor.black.withAlphaComponent(0.8)
        panel.hasShadow = true
        panel.ignoresMouseEvents = true
        panel.contentView?.addSubview(label)
        if let screen = NSScreen.main {
            let f = screen.visibleFrame
            panel.setFrameOrigin(NSPoint(x: f.midX - 96, y: f.maxY - 80))
        }
        panel.orderFrontRegardless()
        self.panel = panel
    }

    public func hide() {
        panel?.orderOut(nil)
        panel = nil
    }
}
