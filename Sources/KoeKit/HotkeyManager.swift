import KeyboardShortcuts

public extension KeyboardShortcuts.Name {
    static let toggleDictation = Self(
        "toggleDictation",
        default: .init(.space, modifiers: [.control, .option])
    )
}

public final class HotkeyManager {
    public static let shortcutName = KeyboardShortcuts.Name.toggleDictation
    public var onToggle: (() -> Void)?

    public init() {}

    public func activate() {
        KeyboardShortcuts.onKeyDown(for: .toggleDictation) { [weak self] in
            self?.onToggle?()
        }
    }
}
