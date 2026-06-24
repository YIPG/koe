import AVFoundation

public final class AudioRecorder: NSObject, AudioRecording {
    private var recorder: AVAudioRecorder?
    private var currentURL: URL?

    public override init() { super.init() }

    public func start() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("koe-\(UUID().uuidString).wav")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16_000,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
        ]
        let rec = try AVAudioRecorder(url: url, settings: settings)
        guard rec.record() else { throw NSError(domain: "koe.audio", code: 1) }
        recorder = rec
        currentURL = url
    }

    public func stop() -> URL? {
        recorder?.stop()
        recorder = nil
        defer { currentURL = nil }
        return currentURL
    }
}
