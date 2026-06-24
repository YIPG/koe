import Foundation

public protocol TranscriptionService {
    func transcribe(audioURL: URL, language: String?) async throws -> String
}

public struct AzureConfig {
    public let endpoint: String
    public let deployment: String
    public let apiVersion: String
    public let apiKey: String

    public init(endpoint: String, deployment: String, apiVersion: String, apiKey: String) {
        self.endpoint = endpoint
        self.deployment = deployment
        self.apiVersion = apiVersion
        self.apiKey = apiKey
    }
}

public enum TranscriptionError: Error, Equatable {
    case notConfigured
    case http(Int, String)
    case badResponse
}

public struct AzureOpenAITranscriptionService: TranscriptionService {
    let config: AzureConfig
    let session: URLSession

    public init(config: AzureConfig, session: URLSession = .shared) {
        self.config = config
        self.session = session
    }

    public func makeRequest(audioURL: URL, language: String?, boundary: String) throws -> URLRequest {
        let base = config.endpoint.hasSuffix("/") ? String(config.endpoint.dropLast()) : config.endpoint
        let urlString = "\(base)/openai/deployments/\(config.deployment)/audio/transcriptions?api-version=\(config.apiVersion)"
        guard let url = URL(string: urlString) else { throw TranscriptionError.badResponse }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(config.apiKey, forHTTPHeaderField: "api-key")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = try multipartBody(audioURL: audioURL, language: language, boundary: boundary)
        return request
    }

    private func multipartBody(audioURL: URL, language: String?, boundary: String) throws -> Data {
        var body = Data()
        func append(_ string: String) { body.append(Data(string.utf8)) }

        let audio = try Data(contentsOf: audioURL)
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.wav\"\r\n")
        append("Content-Type: audio/wav\r\n\r\n")
        body.append(audio)
        append("\r\n")

        if let language, !language.isEmpty {
            append("--\(boundary)\r\n")
            append("Content-Disposition: form-data; name=\"language\"\r\n\r\n")
            append("\(language)\r\n")
        }

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"response_format\"\r\n\r\n")
        append("json\r\n")

        append("--\(boundary)--\r\n")
        return body
    }

    public func transcribe(audioURL: URL, language: String?) async throws -> String {
        let boundary = "koe-\(UUID().uuidString)"
        let request = try makeRequest(audioURL: audioURL, language: language, boundary: boundary)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw TranscriptionError.badResponse }
        guard (200..<300).contains(http.statusCode) else {
            throw TranscriptionError.http(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }
        struct Result: Decodable { let text: String }
        guard let result = try? JSONDecoder().decode(Result.self, from: data) else {
            throw TranscriptionError.badResponse
        }
        return result.text
    }
}
