import Foundation
import KoeKit

private final class MockRecorder: AudioRecording {
    var started = false
    var fileToReturn: URL?
    var startError: Error?
    func start() throws { if let startError { throw startError }; started = true }
    func stop() -> URL? { started = false; return fileToReturn }
}

private struct StubTranscriber: TranscriptionService {
    let text: String
    let error: Error?
    func transcribe(audioURL: URL, language: String?) async throws -> String {
        if let error { throw error }
        return text
    }
}

private final class SpyInserter: TextInserting {
    var inserted: [String] = []
    func insert(_ text: String) { inserted.append(text) }
}

private func tempFile() -> URL {
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent("koe-coord-\(UUID().uuidString).wav")
    try? Data("x".utf8).write(to: url)
    return url
}

@MainActor
func dictationCoordinatorTests() async {
    // first toggle starts recording
    do {
        let rec = MockRecorder()
        let coord = DictationCoordinator(
            recorder: rec, transcriber: StubTranscriber(text: "", error: nil),
            inserter: SpyInserter(), language: { "ja" })
        coord.toggle()
        T.eq(coord.state, .recording, "first toggle -> recording")
        T.isTrue(rec.started, "recorder started")
    }

    // second toggle transcribes + inserts
    do {
        let rec = MockRecorder(); rec.fileToReturn = tempFile()
        let inserter = SpyInserter()
        let coord = DictationCoordinator(
            recorder: rec, transcriber: StubTranscriber(text: "こんにちは", error: nil),
            inserter: inserter, language: { "ja" })
        coord.toggle()  // start
        coord.toggle()  // stop + transcribe
        T.eq(coord.state, .transcribing, "after stop -> transcribing")
        try? await Task.sleep(nanoseconds: 300_000_000)
        T.eq(inserter.inserted.joined(), "こんにちは", "inserted transcription")
        T.eq(coord.state, .idle, "returns to idle")
    }

    // transcription error resets to idle
    do {
        let rec = MockRecorder(); rec.fileToReturn = tempFile()
        var captured: Error?
        let coord = DictationCoordinator(
            recorder: rec,
            transcriber: StubTranscriber(text: "", error: TranscriptionError.http(401, "bad key")),
            inserter: SpyInserter(), language: { "ja" })
        coord.onError = { captured = $0 }
        coord.toggle(); coord.toggle()
        try? await Task.sleep(nanoseconds: 300_000_000)
        T.eq(coord.state, .idle, "error path -> idle")
        T.notNil(captured, "error captured")
    }

    // start failure resets to idle
    do {
        let rec = MockRecorder(); rec.startError = TranscriptionError.notConfigured
        let coord = DictationCoordinator(
            recorder: rec, transcriber: StubTranscriber(text: "", error: nil),
            inserter: SpyInserter(), language: { "ja" })
        coord.toggle()
        T.eq(coord.state, .idle, "start failure -> idle")
    }
}
