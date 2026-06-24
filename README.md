# koe（声）

Minimal macOS menu-bar dictation app. Press a global hotkey, speak, press
again — your speech is transcribed (Azure OpenAI `gpt-4o-transcribe`, high
Japanese accuracy) and inserted at the cursor of whatever app is focused.

Built in the spirit of [Maccy](https://maccy.app) / Magnet: single-purpose,
minimal, hotkey-driven, out of your way.

## Requirements

- macOS 13+ (Apple Silicon)
- Swift toolchain (Xcode **or** Command Line Tools — `xcode-select --install`)
- An Azure OpenAI resource with a `gpt-4o-transcribe` deployment (BYO key)

## Build & run

```bash
make run      # build koe.app and launch it (menu-bar mic icon)
make app      # just build koe.app
make test     # run the logic test suite (swift run KoeTests)
```

`koe` is a menu-bar agent (no Dock icon). It ships **no API key**; each user
brings their own Azure key.

## Azure setup (one-time)

You need your **own** Azure subscription (a personal one — don't use a work
subscription for a personal app).

```bash
az login                       # sign in to the subscription you want billed
./scripts/setup-azure.sh       # creates RG + Azure OpenAI + gpt-4o-transcribe
                               # deployment, writes endpoint/key to .koe.env
source .koe.env && ./scripts/smoke-test.sh   # optional: verify the path
```

Then open **koe → Preferences…** and paste:

- **Endpoint** — `KOE_ENDPOINT`
- **Deployment** — `gpt-4o-transcribe`
- **API Version** — `2025-03-01-preview`
- **API Key** — `KOE_API_KEY` (stored in your Keychain, never on disk in clear)
- **Language** — `ja` (or `auto`)
- **Hotkey** — default `⌃⌥Space`

## Permissions

On first use macOS will ask for:

- **Microphone** — to record your voice.
- **Accessibility** — to paste transcribed text into the focused app.
  Grant `koe.app` in System Settings → Privacy & Security → Accessibility.

## Usage

1. Put the cursor in any text field.
2. Press the hotkey (`⌃⌥Space`). The menu-bar icon fills in and a small
   "● 録音中…" HUD appears.
3. Speak.
4. Press the hotkey again. The text is transcribed and inserted at the cursor.
   Your previous clipboard contents are preserved.

## Architecture

- `KoeKit` — library with all logic + AppKit classes (unit-tested).
  - `TranscriptionService` is a protocol (`AzureOpenAITranscriptionService`
    today) so the engine can be swapped (local whisper, Azure AI Speech, …).
- `koe` — thin executable that boots the menu-bar agent.
- Design + plan: `docs/superpowers/specs/` and `docs/superpowers/plans/`.

## Notes

- The test suite uses a tiny custom harness (`Tests/KoeTests/`) instead of
  XCTest, so it runs under Command Line Tools without full Xcode.
- `KeyboardShortcuts` is pinned `1.10.0..<1.16.0` (1.16+ needs a SwiftUI macro
  plugin that ships only with full Xcode).
