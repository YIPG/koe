# Contributing to koe

Thanks for your interest! koe is a small, focused project — contributions that
keep it minimal and single-purpose are very welcome.

## Prerequisites

- macOS 13+ on Apple Silicon
- Swift toolchain — Xcode **or** Command Line Tools (`xcode-select --install`)
- For end-to-end testing: an Azure OpenAI `gpt-4o-transcribe` deployment (BYO key)

You do **not** need full Xcode. The project is set up to build and test under
Command Line Tools alone.

## Build & test

```bash
make signing-cert   # once: stable self-signed signing identity
make test           # logic test suite  (swift run KoeTests)
make app            # build koe.app
make run            # build + launch
```

### Tests

XCTest only ships with full Xcode, so the suite is a plain executable target
(`Tests/KoeTests/`) with a minimal assertion harness (`T.eq`, `T.isTrue`, …).
Add a test as a function and register it in `Tests/KoeTests/TestMain.swift`.

Test the **logic** layer (Keychain, Preferences, Azure request building, the
state machine). GUI/hardware/permission code (audio, hotkey, text insertion,
status item) is verified manually.

## Code layout

All code lives in `Sources/KoeKit/` (one responsibility per file) with a thin
`Sources/koe/main.swift` entry point. See [ARCHITECTURE.md](ARCHITECTURE.md).

Conventions:
- One clear responsibility per file; keep files small.
- Keep the GUI thin; put logic behind protocols so it stays testable.
- Match the surrounding style.

## Adding a transcription engine

Implement `TranscriptionService` and wire it up in `AppDelegate`. Nothing else
needs to change — the coordinator depends only on the protocol.

## Commits & PRs

- Use clear, conventional commit messages (`feat:`, `fix:`, `docs:`, `chore:`).
- Keep PRs focused; describe what and why.
- Run `make test` before opening a PR.

## Security

Never commit secrets. The API key belongs in the Keychain; `.koe.env` is
git-ignored. If you add config, follow the same pattern — no keys in
`UserDefaults`, source, or the bundle.
