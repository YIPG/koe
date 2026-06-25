import AppKit

private final class LevelMeterView: NSView {
    var level: Float = 0 { didSet { needsDisplay = true } }
    private let barCount = 5

    override func draw(_ dirtyRect: NSRect) {
        let spacing: CGFloat = 3
        let barWidth = (bounds.width - spacing * CGFloat(barCount - 1)) / CGFloat(barCount)
        NSColor.systemRed.setFill()
        for i in 0..<barCount {
            // deterministic per-bar shape so the row reads like a meter, not a block
            let phase = Float(i) / Float(max(1, barCount - 1))
            let scale = 0.4 + 0.6 * sinf((phase + 0.15) * .pi)
            let h = max(0.18, min(1, level * scale * 1.8))
            let barHeight = max(barWidth, bounds.height * CGFloat(h))
            let x = CGFloat(i) * (barWidth + spacing)
            let rect = NSRect(x: x, y: (bounds.height - barHeight) / 2, width: barWidth, height: barHeight)
            NSBezierPath(roundedRect: rect, xRadius: barWidth / 2, yRadius: barWidth / 2).fill()
        }
    }
}

public final class RecordingIndicator {
    private var panel: NSPanel?
    private var timer: Timer?
    private var meter: LevelMeterView?
    private var levelProvider: (() -> Float)?

    public init() {}

    public func showRecording(level: @escaping () -> Float) {
        levelProvider = level
        let icon = symbolView("mic.fill", color: .systemRed)
        let title = label("Recording")
        let meter = LevelMeterView()
        meter.translatesAutoresizingMaskIntoConstraints = false
        meter.widthAnchor.constraint(equalToConstant: 34).isActive = true
        meter.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.meter = meter
        present([icon, title, meter])
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 20.0, repeats: true) { [weak self] _ in
            self?.meter?.level = self?.levelProvider?() ?? 0
        }
    }

    public func showTranscribing() {
        stopTimer()
        let spinner = NSProgressIndicator()
        spinner.style = .spinning
        spinner.controlSize = .small
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.widthAnchor.constraint(equalToConstant: 18).isActive = true
        spinner.heightAnchor.constraint(equalToConstant: 18).isActive = true
        spinner.startAnimation(nil)
        present([spinner, label("Transcribing")])
    }

    public func hide() {
        stopTimer()
        guard let panel else { return }
        self.panel = nil
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.15
            panel.animator().alphaValue = 0
        }, completionHandler: {
            panel.orderOut(nil)
        })
    }

    // MARK: - building

    private func symbolView(_ name: String, color: NSColor) -> NSImageView {
        let conf = NSImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
            .applying(.init(paletteColors: [color]))
        let image = NSImage(systemSymbolName: name, accessibilityDescription: nil)?
            .withSymbolConfiguration(conf)
        let view = NSImageView(image: image ?? NSImage())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func label(_ text: String) -> NSTextField {
        let l = NSTextField(labelWithString: text)
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .labelColor
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func present(_ views: [NSView]) {
        stopPanel()
        let stack = NSStackView(views: views)
        stack.orientation = .horizontal
        stack.spacing = 9
        stack.alignment = .centerY
        stack.edgeInsets = NSEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stack.translatesAutoresizingMaskIntoConstraints = false

        let size = NSSize(width: 188, height: 52)
        let blur = NSVisualEffectView(frame: NSRect(origin: .zero, size: size))
        blur.material = .hudWindow
        blur.state = .active
        blur.blendingMode = .behindWindow
        blur.wantsLayer = true
        blur.layer?.cornerRadius = 16
        blur.layer?.masksToBounds = true
        blur.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: blur.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: blur.centerYAnchor),
        ])

        let panel = NSPanel(contentRect: NSRect(origin: .zero, size: size),
                            styleMask: [.borderless, .nonactivatingPanel],
                            backing: .buffered, defer: false)
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.ignoresMouseEvents = true
        panel.isReleasedWhenClosed = false
        panel.contentView = blur
        if let screen = NSScreen.main {
            let vf = screen.visibleFrame
            panel.setFrameOrigin(NSPoint(x: vf.midX - size.width / 2, y: vf.minY + 96))
        }
        panel.alphaValue = 0
        panel.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            panel.animator().alphaValue = 1
        }
        self.panel = panel
    }

    private func stopTimer() { timer?.invalidate(); timer = nil }
    private func stopPanel() { panel?.orderOut(nil); panel = nil }
}
