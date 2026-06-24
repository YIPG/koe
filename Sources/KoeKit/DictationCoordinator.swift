import Foundation

public protocol AudioRecording: AnyObject {
    func start() throws
    func stop() -> URL?
}

public protocol TextInserting {
    func insert(_ text: String)
}

public enum DictationState: Equatable {
    case idle, recording, transcribing
}

@MainActor
public final class DictationCoordinator {
    private let recorder: AudioRecording
    private let transcriber: TranscriptionService
    private let inserter: TextInserting
    private let language: () -> String?

    public private(set) var state: DictationState = .idle {
        didSet { onStateChange?(state) }
    }
    public var onStateChange: ((DictationState) -> Void)?
    public var onError: ((Error) -> Void)?

    public init(recorder: AudioRecording,
                transcriber: TranscriptionService,
                inserter: TextInserting,
                language: @escaping () -> String?) {
        self.recorder = recorder
        self.transcriber = transcriber
        self.inserter = inserter
        self.language = language
    }

    public func toggle() {
        switch state {
        case .idle: startRecording()
        case .recording: stopAndTranscribe()
        case .transcribing: break   // busy; ignore
        }
    }

    private func startRecording() {
        do {
            try recorder.start()
            state = .recording
        } catch {
            onError?(error)
            state = .idle
        }
    }

    private func stopAndTranscribe() {
        guard let url = recorder.stop() else { state = .idle; return }
        state = .transcribing
        let lang = language()
        Task { @MainActor in
            do {
                let text = try await transcriber.transcribe(audioURL: url, language: lang)
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { inserter.insert(trimmed) }
            } catch {
                onError?(error)
            }
            try? FileManager.default.removeItem(at: url)
            state = .idle
        }
    }
}
