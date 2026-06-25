import AppKit

/// A menu-bar agent (`.accessory`) has no main menu, so the standard
/// ⌘X/⌘C/⌘V/⌘A key equivalents — which AppKit routes through the Edit menu —
/// don't reach text fields. Installing a (never-displayed) main menu with an
/// Edit submenu restores copy/paste in the Preferences window.
enum MainMenu {
    @MainActor
    static func install() {
        let mainMenu = NSMenu()

        // Application menu.
        let appItem = NSMenuItem()
        mainMenu.addItem(appItem)
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Quit koe",
                        action: #selector(NSApplication.terminate(_:)),
                        keyEquivalent: "q")
        appItem.submenu = appMenu

        // Edit menu — enables ⌘Z/⌘X/⌘C/⌘V/⌘A in text fields via the responder chain.
        let editItem = NSMenuItem()
        mainMenu.addItem(editItem)
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        editMenu.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
        editMenu.addItem(.separator())
        editMenu.addItem(withTitle: "Cut", action: Selector(("cut:")), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: Selector(("copy:")), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: Selector(("paste:")), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: Selector(("selectAll:")), keyEquivalent: "a")
        editItem.submenu = editMenu

        NSApp.mainMenu = mainMenu
    }
}
