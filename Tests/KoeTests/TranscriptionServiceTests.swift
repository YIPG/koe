import Foundation
import KoeKit

private func makeAudioFile() -> URL {
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent("koe-test-\(UUID().uuidString).wav")
    try? Data("fake-wav-bytes".utf8).write(to: url)
    return url
}

func transcriptionServiceTests() {
    let config = AzureConfig(
        endpoint: "https://koe-tx.openai.azure.com/",  // trailing slash on purpose
        deployment: "gpt-4o-transcribe",
        apiVersion: "2025-03-01-preview",
        apiKey: "SECRET"
    )
    let svc = AzureOpenAITranscriptionService(config: config)
    let audio = makeAudioFile()
    defer { try? FileManager.default.removeItem(at: audio) }

    // URL has no double slash, correct method + headers
    guard let req = try? svc.makeRequest(audioURL: audio, language: "ja", boundary: "B") else {
        T.check(false, "makeRequest threw"); return
    }
    T.eq(req.url?.absoluteString ?? "<nil>",
         "https://koe-tx.openai.azure.com/openai/deployments/gpt-4o-transcribe/audio/transcriptions?api-version=2025-03-01-preview",
         "request URL")
    T.eq(req.httpMethod ?? "<nil>", "POST", "method")
    T.eq(req.value(forHTTPHeaderField: "api-key") ?? "<nil>", "SECRET", "api-key header")
    T.isTrue(req.value(forHTTPHeaderField: "Content-Type")?.contains("boundary=B") ?? false, "boundary in content-type")

    // multipart body contains the parts
    let body = String(data: req.httpBody ?? Data(), encoding: .utf8) ?? ""
    T.contains(body, "name=\"file\"; filename=\"audio.wav\"", "file part")
    T.contains(body, "name=\"language\"", "language part")
    T.contains(body, "name=\"response_format\"", "response_format part")
    T.contains(body, "--B--", "closing boundary")

    // language omitted when nil
    guard let req2 = try? svc.makeRequest(audioURL: audio, language: nil, boundary: "B") else {
        T.check(false, "makeRequest(nil) threw"); return
    }
    let body2 = String(data: req2.httpBody ?? Data(), encoding: .utf8) ?? ""
    T.isFalse(body2.contains("name=\"language\""), "language omitted when nil")
}
