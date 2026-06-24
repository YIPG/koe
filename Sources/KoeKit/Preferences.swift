import Foundation

public final class Preferences {
    private let defaults: UserDefaults
    private let keychain: KeychainStore

    private enum Key {
        static let endpoint = "koe.endpoint"
        static let deployment = "koe.deployment"
        static let apiVersion = "koe.apiVersion"
        static let language = "koe.language"
    }
    private static let apiKeyAccount = "apiKey"

    public init(defaults: UserDefaults = .standard, keychain: KeychainStore = KeychainStore()) {
        self.defaults = defaults
        self.keychain = keychain
    }

    public var endpoint: String {
        get { defaults.string(forKey: Key.endpoint) ?? "" }
        set { defaults.set(newValue, forKey: Key.endpoint) }
    }

    public var deployment: String {
        get { defaults.string(forKey: Key.deployment) ?? "gpt-4o-transcribe" }
        set { defaults.set(newValue, forKey: Key.deployment) }
    }

    public var apiVersion: String {
        get { defaults.string(forKey: Key.apiVersion) ?? "2025-03-01-preview" }
        set { defaults.set(newValue, forKey: Key.apiVersion) }
    }

    public var language: String {
        get { defaults.string(forKey: Key.language) ?? "ja" }
        set { defaults.set(newValue, forKey: Key.language) }
    }

    public var apiKey: String? {
        get { keychain.get(Self.apiKeyAccount) }
        set {
            if let value = newValue, !value.isEmpty {
                try? keychain.set(value, for: Self.apiKeyAccount)
            } else {
                keychain.delete(Self.apiKeyAccount)
            }
        }
    }

    public var isConfigured: Bool {
        !endpoint.isEmpty && !deployment.isEmpty && (apiKey?.isEmpty == false)
    }
}
